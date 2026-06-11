# backend/app/movies.py
"""
movies.py — Rotas de filmes corrigidas:
- F2: /discover/movie com filtros de clássicos (vote_count.desc, vote_average>=7, até 2015)
- F4: fallback IMDB quando OMDB não disponível; badge só exibido se score != null
- F5: _enrich_movie busca Watch Providers BR com fallback US
- F1: /public-domain retorna filmes reais com streaming_link preenchido
- F3: trending renomeado para "Em Alta" (clássicos); estrutura de prateleiras no frontend
- CORREÇÃO: Pôsteres do Internet Archive passando por proxy (Weserv) para contornar erro de CORS no Flutter Web
"""
import logging
import os
import requests
import urllib.parse
from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/api/v1/movies", tags=["movies"])

TMDB_BASE = "https://api.themoviedb.org/3"
OMDB_BASE = "http://www.omdbapi.com"
IA_BASE   = "https://archive.org"

logger = logging.getLogger("genesis.movies")


def _tmdb_headers():
    token = os.getenv("TMDB_BEARER_TOKEN", "")
    if not token:
        logger.warning("TMDB_BEARER_TOKEN não configurado.")
    return {
        "accept": "application/json",
        "Authorization": f"Bearer {token}",
    }


def _omdb_key():
    return os.getenv("OMDB_API_KEY", "")


def _get_omdb_ratings(imdb_id: str) -> dict:
    """Busca ratings IMDB + Rotten Tomatoes via OMDB. Retorna dict com imdb_score e rt_score."""
    key = _omdb_key()
    if not key or not imdb_id:
        return {}
    try:
        resp = requests.get(OMDB_BASE, params={"i": imdb_id, "apikey": key}, timeout=5)
        if resp.status_code != 200:
            return {}
        d = resp.json()
        if d.get("Response") != "True":
            return {}
        result = {}
        imdb_r = d.get("imdbRating")
        if imdb_r and imdb_r != "N/A":
            try:
                result["imdb_score"] = float(imdb_r)
            except ValueError:
                pass
        for rating in d.get("Ratings", []):
            if rating.get("Source") == "Rotten Tomatoes":
                rt = rating.get("Value", "").replace("%", "")
                try:
                    result["rt_score"] = int(rt)
                except ValueError:
                    pass
        return result
    except Exception:
        return {}


def _enrich_movie(item: dict, headers: dict) -> dict | None:
    """
    Adiciona imdb_id, scores e streaming info ao item TMDB.
    F4: fallback para IMDB score do próprio TMDB se OMDB indisponível.
    F5: busca Watch Providers BR com fallback US.
    """
    tmdb_id = item.get("id")
    if not tmdb_id:
        return None

    # External IDs
    resp = requests.get(f"{TMDB_BASE}/movie/{tmdb_id}/external_ids", headers=headers, timeout=5)
    imdb_id = resp.json().get("imdb_id") if resp.status_code == 200 else None

    # F5: Watch Providers BR → US como fallback
    streaming_link = None
    streaming_name = None
    try:
        providers_resp = requests.get(
            f"{TMDB_BASE}/movie/{tmdb_id}/watch/providers", headers=headers, timeout=5
        )
        if providers_resp.status_code == 200:
            results = providers_resp.json().get("results", {})
            # Tenta BR primeiro, depois US
            br_data = results.get("BR") or results.get("US") or {}
            flatrate = br_data.get("flatrate", [])
            if flatrate:
                streaming_name = flatrate[0].get("provider_name")
            link = br_data.get("link")
            if link:
                streaming_link = link
    except Exception as e:
        logger.warning("Falha ao buscar watch providers para tmdb_id=%s: %s", tmdb_id, e)

    # F4: OMDB para RT score; fallback para IMDB do TMDB se OMDB não retornar
    omdb = _get_omdb_ratings(imdb_id) if imdb_id else {}
    tmdb_vote = item.get("vote_average")

    # imdb_score: prioriza OMDB, cai para TMDB vote_average como fallback
    imdb_score = omdb.get("imdb_score") or (round(tmdb_vote, 1) if tmdb_vote else None)
    # rt_score: só preenche se vier do OMDB
    rt_score = omdb.get("rt_score")

    return {
        "imdb_id": imdb_id,
        "tmdb_id": tmdb_id,
        "title": item.get("title"),
        "overview": item.get("overview"),
        "release_date": item.get("release_date"),
        "poster_url": f"https://image.tmdb.org/t/p/w500{item['poster_path']}" if item.get("poster_path") else None,
        "backdrop_url": f"https://image.tmdb.org/t/p/w1280{item['backdrop_path']}" if item.get("backdrop_path") else None,
        "vote_average": tmdb_vote,
        "imdb_score": imdb_score,
        "rt_score": rt_score,          # None se não tiver OMDB → badge não será exibido
        "streaming_link": streaming_link,
        "streaming_name": streaming_name,
        "public_domain": False,
    }


@router.get("/trending")
def obter_filmes_em_alta():
    """
    F2: Usa /discover/movie com filtros de clássicos:
    sort_by=vote_count.desc, vote_average>=7, release_date<=2015, language=pt-BR.
    """
    headers = _tmdb_headers()
    try:
        params = {
            "language": "pt-BR",
            "region": "BR",
            "sort_by": "vote_count.desc",
            "vote_average.gte": 7,
            "primary_release_date.lte": "2015-01-01",
            "with_original_language": "pt|en|es|fr|it|de|ja",
        }
        resp = requests.get(
            f"{TMDB_BASE}/discover/movie",
            headers=headers,
            params=params,
            timeout=10,
        )
        logger.info("TMDB discover/movie status=%s", resp.status_code)
        if resp.status_code != 200:
            logger.error("TMDB erro %s: %s", resp.status_code, resp.text[:300])
            raise HTTPException(status_code=resp.status_code, detail="Erro ao comunicar com o TMDB")

        enriched = []
        results = resp.json().get("results", [])
        logger.info("TMDB discover retornou %d filmes", len(results))
        for item in results:
            movie = _enrich_movie(item, headers)
            if movie:
                enriched.append(movie)
        return enriched
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/top-rated")
def obter_mais_bem_avaliados():
    """
    F3: Prateleira 'Mais Bem Avaliados' — filmes com maior nota, sem restrição de data.
    """
    headers = _tmdb_headers()
    try:
        params = {
            "language": "pt-BR",
            "region": "BR",
            "sort_by": "vote_average.desc",
            "vote_count.gte": 1000,
        }
        resp = requests.get(
            f"{TMDB_BASE}/discover/movie",
            headers=headers,
            params=params,
            timeout=10,
        )
        if resp.status_code != 200:
            raise HTTPException(status_code=resp.status_code, detail="Erro ao comunicar com o TMDB")

        enriched = []
        for item in resp.json().get("results", []):
            movie = _enrich_movie(item, headers)
            if movie:
                enriched.append(movie)
        return enriched
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/search")
def buscar_filmes(query: str):
    if not query:
        raise HTTPException(status_code=400, detail="O parâmetro 'query' não pode estar vazio.")
    headers = _tmdb_headers()
    try:
        resp = requests.get(
            f"{TMDB_BASE}/search/movie",
            headers=headers,
            params={"query": query, "language": "pt-BR", "region": "BR"},
            timeout=10,
        )
        if resp.status_code != 200:
            raise HTTPException(status_code=resp.status_code, detail="Erro ao comunicar com o TMDB")
        enriched = []
        for item in resp.json().get("results", [])[:10]:
            movie = _enrich_movie(item, headers)
            if movie:
                enriched.append(movie)
        return enriched
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/public-domain")
def get_public_domain_movies(q: str = "silent film classic 1920s", rows: int = 20):
    """
    F1: Busca filmes de domínio público no Internet Archive.
    streaming_link sempre preenchido com URL do Internet Archive.
    Imagens passam por proxy (wsrv.nl) para evitar bloqueios CORS.
    """
    try:
        params = {
            "q": f"({q}) AND mediatype:movies",
            "fl[]": "identifier,title,year,description,subject,thumb",
            "rows": rows,
            "output": "json",
            "sort[]": "downloads desc",
        }
        resp = requests.get(f"{IA_BASE}/advancedsearch.php", params=params, timeout=10)
        logger.info("Internet Archive status=%s q=%s", resp.status_code, q)

        if resp.status_code != 200:
            logger.error("Internet Archive erro %s", resp.status_code)
            return []

        docs = resp.json().get("response", {}).get("docs", [])
        logger.info("Internet Archive retornou %d filmes", len(docs))

        movies = []
        for doc in docs:
            identifier = doc.get("identifier")
            if not identifier:
                continue
            
            # F1: streaming_link sempre preenchido
            streaming_link = f"https://archive.org/details/{identifier}"
            
            # Construindo e "Destravando" a URL da capa com o Proxy
            raw_thumb = doc.get("thumb") or f"https://archive.org/services/img/{identifier}"
            encoded_thumb = urllib.parse.quote(raw_thumb)
            proxied_thumb_url = f"https://wsrv.nl/?url={encoded_thumb}"
            
            movies.append({
                "id": f"ia:{identifier}",
                "imdb_id": None,
                "tmdb_id": None,
                "title": doc.get("title", identifier),
                "overview": doc.get("description", "") or "",
                "release_date": str(doc.get("year", "")),
                "poster_url": proxied_thumb_url,
                "backdrop_url": proxied_thumb_url,
                "vote_average": 0,
                "imdb_score": None,
                "rt_score": None,
                "streaming_link": streaming_link,    # sempre preenchido
                "streaming_name": "Internet Archive",
                "public_domain": True,
            })
        return movies
    except Exception as e:
        logger.error("Erro Internet Archive: %s", e)
        raise HTTPException(status_code=500, detail=str(e))
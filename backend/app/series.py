# backend/app/series.py
import logging
import os
import requests
from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/api/v1/series", tags=["series"])

TMDB_BASE = "https://api.themoviedb.org/3"
logger = logging.getLogger("genesis.series")

def _tmdb_headers():
    return {
        "accept": "application/json",
        "Authorization": f"Bearer {os.getenv('TMDB_BEARER_TOKEN', '')}",
    }

def _get_watch_providers(tmdb_id: int, headers: dict) -> dict:
    """Busca onde a série está disponível no Brasil ou EUA de forma segura."""
    default = {"streaming_name": None, "streaming_link": None}
    try:
        resp = requests.get(f"{TMDB_BASE}/tv/{tmdb_id}/watch/providers", headers=headers, timeout=5)
        if resp.status_code == 200:
            data = resp.json().get("results", {})
            # Prioridade: Brasil, depois EUA, caso contrário vazio
            region_data = data.get("BR") or data.get("US") or {}
            
            # 'flatrate' contém serviços de assinatura como Netflix, Prime, etc.
            if "flatrate" in region_data and isinstance(region_data["flatrate"], list) and len(region_data["flatrate"]) > 0:
                provider = region_data["flatrate"][0]
                return {
                    "streaming_name": provider.get("provider_name"),
                    "streaming_link": region_data.get("link")
                }
    except Exception as e:
        logger.error(f"Erro ao buscar providers para a série {tmdb_id}: {e}")
    
    return default

def _build_series_item(show: dict, headers: dict) -> dict:
    """Enriquecimento de dados da série garantindo que não haja campos nulos que quebrem o app."""
    tmdb_id = show.get("id")
    providers = _get_watch_providers(tmdb_id, headers)
    
    return {
        "tmdb_id": tmdb_id,
        "title": show.get("name") or "Sem título",
        "overview": show.get("overview") or "",
        "first_air_date": show.get("first_air_date") or "",
        "poster_url": (
            f"https://image.tmdb.org/t/p/w500{show.get('poster_path')}"
            if show.get("poster_path") else None
        ),
        "backdrop_url": (
            f"https://image.tmdb.org/t/p/w1280{show.get('backdrop_path')}"
            if show.get("backdrop_path") else None
        ),
        "vote_average": show.get("vote_average") or 0.0,
        "streaming_name": providers.get("streaming_name"),
        "streaming_link": providers.get("streaming_link"),
    }

@router.get("/trending")
def obter_series_em_alta():
    headers = _tmdb_headers()
    try:
        params = {
            "language": "pt-BR",
            "sort_by": "vote_count.desc",
            "vote_average.gte": 7,
            "first_air_date.lte": "2015-01-01",
        }
        resp = requests.get(f"{TMDB_BASE}/discover/tv", headers=headers, params=params, timeout=10)
        
        if resp.status_code != 200:
            raise HTTPException(status_code=resp.status_code, detail="Erro ao comunicar com TMDB")

        results = resp.json().get("results", [])
        return [_build_series_item(show, headers) for show in results]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/search")
def buscar_series(query: str):
    if not query:
        raise HTTPException(status_code=400, detail="Query vazia")
    
    headers = _tmdb_headers()
    try:
        resp = requests.get(
            f"{TMDB_BASE}/search/tv",
            headers=headers,
            params={"query": query, "language": "pt-BR"},
            timeout=10,
        )
        
        if resp.status_code != 200:
            raise HTTPException(status_code=resp.status_code, detail="Erro ao comunicar com TMDB")

        results = resp.json().get("results", [])
        return [_build_series_item(show, headers) for show in results[:10]]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
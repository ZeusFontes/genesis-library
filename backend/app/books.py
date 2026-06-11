# backend/app/books.py

import logging
import os
import requests
import random
import sqlite3
import urllib.parse
from typing import Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from backend.app.database import get_db_connection

router = APIRouter(prefix="/api/v1/books", tags=["books"])

BOOKS_API_URL = "https://www.googleapis.com/books/v1/volumes"

logger = logging.getLogger("genesis.books")


def _books_key() -> str:
    """Lê a chave da API em tempo de execução."""
    key = os.getenv("GOOGLE_BOOKS_API_KEY", "").strip()
    if not key:
        logger.warning("Aviso: GOOGLE_BOOKS_API_KEY não está definida.")
    return key


def _fix_thumbnail(url: Optional[str]) -> Optional[str]:
    """Força HTTPS e usa um proxy de imagem para evitar o bloqueio de CORS no Flutter Web."""
    if not url:
        return None
        
    # Transforma http em https
    url = url.replace("http://", "https://")
    
    # Codifica a URL do Google e passa pelo proxy público Weserv
    # Isso destrava a imagem no navegador e otimiza o carregamento!
    encoded_url = urllib.parse.quote(url)
    return f"https://wsrv.nl/?url={encoded_url}"

def _parse_book(item: dict) -> dict:
    volume_info = item.get("volumeInfo", {})
    image_links = volume_info.get("imageLinks", {})
    
    # Tenta pegar a melhor qualidade de capa possível
    thumbnail = _fix_thumbnail(
        image_links.get("extraLarge")
        or image_links.get("large")
        or image_links.get("medium")
        or image_links.get("thumbnail")
        or image_links.get("smallThumbnail")
    )
    
    preview_link = volume_info.get("previewLink")
    if preview_link:
        preview_link = preview_link.replace("http://", "https://")
        
    return {
        "id": item.get("id"),
        "title": volume_info.get("title", "Sem título"),
        "authors": volume_info.get("authors", ["Desconhecido"]),
        "published_date": volume_info.get("publishedDate"),
        "description": volume_info.get("description"),
        "thumbnail": thumbnail,
        "preview_link": preview_link,
        "publisher": volume_info.get("publisher"),
        "page_count": volume_info.get("pageCount"),
        "categories": volume_info.get("categories"),
        "language": volume_info.get("language"),
        "pdf_link": volume_info.get("industryIdentifiers") and _extract_pdf_link(item),
    }


def _extract_pdf_link(item: dict) -> Optional[str]:
    """Extrai link de PDF/ePub de acessInfo do Google Books."""
    access_info = item.get("accessInfo", {})
    pdf = access_info.get("pdf", {})
    epub = access_info.get("epub", {})
    
    if pdf.get("isAvailable") and pdf.get("downloadLink"):
        return pdf["downloadLink"].replace("http://", "https://")
    if epub.get("isAvailable") and epub.get("downloadLink"):
        return epub["downloadLink"].replace("http://", "https://")
    return None


def _search_google_books(params: dict) -> list:
    """Executa busca inteligente no Google Books com fallbacks de idioma."""
    try:
        response = requests.get(BOOKS_API_URL, params=params, timeout=10)
        
        if response.status_code != 200:
            logger.error(f"Google Books API erro {response.status_code}: {response.text[:200]}")
            return []

        data = response.json()
        items = data.get("items", [])

        # Fallback: Se a busca em português (langRestrict=pt) vier vazia, busca global
        if not items and "langRestrict" in params:
            logger.info(f"Sem resultados para '{params.get('q')}' em PT. Removendo restrição de idioma...")
            params.pop("langRestrict")
            
            response2 = requests.get(BOOKS_API_URL, params=params, timeout=10)
            if response2.status_code == 200:
                items = response2.json().get("items", [])

        return items

    except requests.exceptions.RequestException as exc:
        logger.error("Erro de conexão com Google Books: %s", exc)
        return []


@router.get("/search")
def search_books(q: str, max_results: int = 20):
    """Busca livros pelo título ou autor usando a API do Google Books."""
    if not q or not q.strip():
        raise HTTPException(status_code=400, detail="O parâmetro 'q' não pode estar vazio.")

    params = {
        "q": q,
        "maxResults": min(max_results, 40),
        "langRestrict": "pt",
        "printType": "books",
        "orderBy": "relevance",
    }
    
    key = _books_key()
    if key:
        params["key"] = key

    items = _search_google_books(params)
    return [_parse_book(item) for item in items]


@router.get("/library")
def get_library(max_results: int = 30):
    """
    Retorna a seção 'Toda a Biblioteca'.
    Como a API Key está configurada, mistura múltiplos gêneros reais 
    para criar um catálogo rico e moderno, não restrito a domínio público.
    """
    key = _books_key()
    if not key:
        raise HTTPException(status_code=500, detail="A API Key do Google Books não foi encontrada no servidor.")

    # Busca em 3 vertentes diferentes para garantir diversidade na estante
    themes = [
        "literatura brasileira romance", 
        "ficção cientifica fantasia", 
        "biografia desenvolvimento"
    ]
    
    all_books = []
    seen_ids = set()
    
    # Divide a quantidade de livros igualmente entre os temas
    limit_per_theme = max_results // len(themes) + 2

    for theme in themes:
        params = {
            "q": theme,
            "maxResults": limit_per_theme,
            "langRestrict": "pt",
            "printType": "books",
            "key": key
        }
        
        items = _search_google_books(params)
        for item in items:
            book_id = item.get("id")
            if book_id and book_id not in seen_ids:
                seen_ids.add(book_id)
                all_books.append(_parse_book(item))

    # Embaralha a lista para a estante ficar com visual de "Netflix" (bem misturado)
    random.shuffle(all_books)

    return all_books[:max_results]


@router.get("/public-domain")
def get_public_domain_books(q: str = "classic literature", max_results: int = 20):
    """Busca livros de domínio público via Open Library (Independente do Google)."""
    try:
        url = "https://openlibrary.org/search.json"
        
        # Filtra queries muito complexas para não bugar a Open Library
        search_query = q if len(q) < 15 else "literatura classica"
        
        params = {
            "q": search_query,
            "limit": max_results,
            "fields": "key,title,author_name,first_publish_year,cover_i,subject,ia,language",
            "language": "por",
        }
        
        response = requests.get(url, params=params, timeout=10)
        data = response.json() if response.status_code == 200 else {}
        docs = data.get("docs", [])

        # Fallback de emergência para a Open Library
        if not docs:
            params.pop("language", None)
            params["q"] = "classic literature public domain"
            response = requests.get(url, params=params, timeout=10)
            data = response.json() if response.status_code == 200 else {}
            docs = data.get("docs", [])

        books = []
        for doc in docs:
            cover_id = doc.get("cover_i")
            cover_url = f"https://covers.openlibrary.org/b/id/{cover_id}-L.jpg" if cover_id else None
            ia = doc.get("ia", [])
            read_url = f"https://archive.org/details/{ia[0]}" if ia else None
            
            books.append({
                "id": f"ol:{doc.get('key', '').replace('/works/', '')}",
                "title": doc.get("title", "Sem título"),
                "authors": doc.get("author_name", ["Desconhecido"]),
                "published_date": str(doc.get("first_publish_year", "")),
                "description": None,
                "thumbnail": cover_url,
                "preview_link": None,
                "read_url": read_url,
                "public_domain": True,
                "source": "openlibrary",
            })
            
        return books
        
    except Exception as exc:
        logger.error("Erro Open Library: %s", exc)
        return []


@router.get("/{book_id}")
def get_book(book_id: str):
    """Retorna detalhes de um livro específico pelo ID."""
    # Verificação para livros da Open Library
    if book_id.startswith("ol:"):
        ol_key = book_id[3:]
        try:
            url = f"https://openlibrary.org/works/{ol_key}.json"
            resp = requests.get(url, timeout=10)
            if resp.status_code == 200:
                d = resp.json()
                desc = d.get("description")
                if isinstance(desc, dict):
                    desc = desc.get("value")
                return {
                    "id": book_id,
                    "title": d.get("title"),
                    "authors": [],
                    "published_date": None,
                    "description": desc,
                    "thumbnail": None,
                    "preview_link": f"https://openlibrary.org/works/{ol_key}",
                    "pdf_link": None,
                    "public_domain": True,
                }
        except Exception:
            pass

    # Verificação para livros do Google Books
    params = {}
    key = _books_key()
    if key:
        params["key"] = key

    try:
        response = requests.get(f"{BOOKS_API_URL}/{book_id}", params=params, timeout=10)
        if response.status_code == 404:
            raise HTTPException(status_code=404, detail="Livro não encontrado.")
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Erro ao consultar a API de livros.")

        return _parse_book(response.json())

    except requests.exceptions.RequestException as exc:
        raise HTTPException(status_code=500, detail=f"Erro de conexão: {str(exc)}")


class FavoriteBookCreate(BaseModel):
    profile_id: int
    book_id: str
    book_title: Optional[str] = None


@router.post("/favorites", status_code=201)
def add_favorite(fav: FavoriteBookCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO favorites (profile_id, movie_id, movie_title) VALUES (?, ?, ?);",
            (fav.profile_id, f"book:{fav.book_id}", fav.book_title)
        )
        conn.commit()
        return {"message": "Adicionado aos favoritos com sucesso"}
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Este título já está nos favoritos.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


@router.delete("/favorites/{profile_id}/{book_id}")
def remove_favorite(profile_id: int, book_id: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "DELETE FROM favorites WHERE profile_id = ? AND movie_id = ?;",
        (profile_id, f"book:{book_id}")
    )
    conn.commit()
    affected = cursor.rowcount
    conn.close()
    if affected == 0:
        raise HTTPException(status_code=404, detail="Favorito não encontrado.")
    return {"message": "Removido dos favoritos com sucesso"}
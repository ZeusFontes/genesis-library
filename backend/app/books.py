import os
import requests
from typing import List, Optional
import sqlite3

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from backend.app.database import get_db_connection

router = APIRouter(prefix="/api/v1/books", tags=["books"])

BOOKS_API_URL = "https://www.googleapis.com/books/v1/volumes"
GOOGLE_BOOKS_API_KEY = "la la"


@router.get("/search")
def search_books(q: str, max_results: int = 10):
    """Busca livros pelo título ou autor usando a API pública do Google Books."""
    if not q:
        raise HTTPException(status_code=400, detail="O parâmetro de busca 'q' não pode estar vazio.")

    try:
        params = {"q": q, "maxResults": max_results}
        if GOOGLE_BOOKS_API_KEY:
            params["key"] = GOOGLE_BOOKS_API_KEY

        response = requests.get(BOOKS_API_URL, params=params)
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Erro ao consultar a API de livros.")

        data = response.json()
        books = []

        for item in data.get("items", []):
            volume_info = item.get("volumeInfo", {})
            image_links = volume_info.get("imageLinks", {})

            books.append({
                "id": item.get("id"),
                "title": volume_info.get("title"),
                "authors": volume_info.get("authors"),
                "published_date": volume_info.get("publishedDate"),
                "description": volume_info.get("description"),
                "thumbnail": image_links.get("thumbnail"),
            })

        return books

    except requests.exceptions.RequestException as exc:
        raise HTTPException(status_code=500, detail=f"Erro de conexão com o provedor: {str(exc)}")


@router.get("/{book_id}")
def get_book(book_id: str):
    """Retorna os detalhes de um livro específico pelo ID do Google Books."""
    try:
        response = requests.get(f"{BOOKS_API_URL}/{book_id}")
        if response.status_code == 404:
            raise HTTPException(status_code=404, detail="Livro não encontrado.")
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Erro ao consultar a API de livros.")

        data = response.json()
        volume_info = data.get("volumeInfo", {})
        image_links = volume_info.get("imageLinks", {})

        return {
            "id": data.get("id"),
            "title": volume_info.get("title"),
            "authors": volume_info.get("authors"),
            "published_date": volume_info.get("publishedDate"),
            "description": volume_info.get("description"),
            "publisher": volume_info.get("publisher"),
            "page_count": volume_info.get("pageCount"),
            "categories": volume_info.get("categories"),
            "thumbnail": image_links.get("thumbnail"),
            "preview_link": volume_info.get("previewLink"),
        }

    except requests.exceptions.RequestException as exc:
        raise HTTPException(status_code=500, detail=f"Erro de conexão com o provedor: {str(exc)}")


class FavoriteBookCreate(BaseModel):
    profile_id: int
    book_id: str
    book_title: Optional[str] = None


@router.post("/favorites", status_code=201)
def add_favorite(fav: FavoriteBookCreate):
    """Adiciona um livro aos favoritos de um perfil (usa a tabela `favorites`)."""
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
        raise HTTPException(status_code=400, detail="Este título já está nos favoritos deste perfil.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


@router.delete("/favorites/{profile_id}/{book_id}")
def remove_favorite(profile_id: int, book_id: str):
    """Remove um livro dos favoritos de um perfil."""
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

import sqlite3
from fastapi import HTTPException, status
from pydantic import BaseModel
from backend.app.database import get_db_connection

# Modelo Pydantic para validação
class FavoriteCreate(BaseModel):
    profile_id: int
    movie_id: str
    movie_title: str

# Listar Favoritos
def db_list_favorites(profile_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM favorites WHERE profile_id = ?;", (profile_id,))
        favoritos = cursor.fetchall()
        return [dict(favorito) for favorito in favoritos]
    except sqlite3.Error as e:
        raise HTTPException(status_code=500, detail=f"Erro no banco: {str(e)}")
    finally:
        conn.close()

# Adicionar Favorito
def db_add_favorite(fav: FavoriteCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO favorites (profile_id, movie_id, movie_title) VALUES (?, ?, ?);",
            (fav.profile_id, fav.movie_id, fav.movie_title)
        )
        conn.commit()
        return {"message": "Adicionado aos favoritos com sucesso"}
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Este título já está nos favoritos deste perfil.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

# Remover Favorito
def db_remove_favorite(profile_id: int, movie_id: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "DELETE FROM favorites WHERE profile_id = ? AND movie_id = ?;",
            (profile_id, movie_id)
        )
        conn.commit()
        colunas_afetadas = cursor.rowcount
        if colunas_afetadas == 0:
            raise HTTPException(status_code=404, detail="Favorito não encontrado.")
        return {"message": "Removido dos favoritos com sucesso"}
    except sqlite3.Error as e:
        raise HTTPException(status_code=500, detail=f"Erro no banco: {str(e)}")
    finally:
        conn.close()
import os
import sqlite3
from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr

from backend.app.database import init_db, get_db_connection
from backend.app.books import router as books_router
from backend.app.series import router as series_router
from backend.app.movies import router as movies_router
from backend.app.addons import AddonInstallRequest, db_install_addon, db_list_profile_addons
from backend.app.favorites import FavoriteCreate, db_list_favorites, db_add_favorite, db_remove_favorite

# ---------------------------------------------------------------------------
# Carrega variáveis de ambiente
# ---------------------------------------------------------------------------
_ROOT = Path(__file__).resolve().parent.parent.parent
load_dotenv(dotenv_path=_ROOT / ".env")

# ---------------------------------------------------------------------------
# Aplicação FastAPI
# ---------------------------------------------------------------------------
app = FastAPI(
    title="Genesis Library API",
    description="Backend da plataforma GÊNESIS — filmes, séries, livros e addons.",
    version="1.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(books_router)
app.include_router(series_router)
app.include_router(movies_router)


@app.on_event("startup")
def startup_event() -> None:
    init_db()


# ---------------------------------------------------------------------------
# Health-check
# ---------------------------------------------------------------------------
@app.get("/")
def read_root():
    return {"status": "online", "database": "SQLite conectado"}


# ---------------------------------------------------------------------------
# Modelos Pydantic
# ---------------------------------------------------------------------------
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password_hash: str


class UserLogin(BaseModel):
    email: EmailStr
    password_hash: str


class ProfileCreate(BaseModel):
    user_id: int
    name: str
    avatar_url: str | None = None


# ---------------------------------------------------------------------------
# Rotas de Usuários
# ---------------------------------------------------------------------------
@app.post("/api/v1/users", status_code=status.HTTP_201_CREATED)
def criar_usuario(user: UserCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?);",
            (user.username, user.email, user.password_hash),
        )
        conn.commit()
        return {
            "id": cursor.lastrowid,
            "username": user.username,
            "email": user.email,
            "message": "Usuário criado com sucesso",
        }
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Este e-mail já está cadastrado.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


@app.post("/api/v1/users/login")
def login_usuario(credentials: UserLogin):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "SELECT id, username, email FROM users WHERE email = ? AND password_hash = ?;",
            (credentials.email, credentials.password_hash),
        )
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=401, detail="E-mail ou senha incorretos.")
        return {"id": row["id"], "username": row["username"], "email": row["email"]}
    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Rotas de Perfis
# ---------------------------------------------------------------------------
@app.get("/api/v1/users/{user_id}/profiles")
def listar_perfis_do_usuario(user_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM profiles WHERE user_id = ?;", (user_id,))
    perfis = cursor.fetchall()
    conn.close()
    return [dict(p) for p in perfis]


@app.post("/api/v1/profiles", status_code=status.HTTP_201_CREATED)
def criar_perfil(profile: ProfileCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO profiles (user_id, name, avatar_url) VALUES (?, ?, ?);",
            (profile.user_id, profile.name, profile.avatar_url),
        )
        conn.commit()
        return {"id": cursor.lastrowid, "name": profile.name, "message": "Perfil criado com sucesso"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Rotas de Favoritos
# ---------------------------------------------------------------------------
@app.get("/api/v1/profiles/{profile_id}/favorites")
def listar_favoritos(profile_id: int):
    return db_list_favorites(profile_id)


@app.post("/api/v1/favorites", status_code=status.HTTP_201_CREATED)
def adicionar_favorito(fav: FavoriteCreate):
    return db_add_favorite(fav)


@app.delete("/api/v1/profiles/{profile_id}/favorites/{movie_id}")
def remover_favorito(profile_id: int, movie_id: str):
    return db_remove_favorite(profile_id, movie_id)


# ---------------------------------------------------------------------------
# Rotas de Addons
# ---------------------------------------------------------------------------
@app.post("/api/v1/addons/install", status_code=status.HTTP_201_CREATED)
def install_addon(data: AddonInstallRequest):
    return db_install_addon(data)


@app.get("/api/v1/profiles/{profile_id}/addons")
def list_profile_addons(profile_id: int):
    return db_list_profile_addons(profile_id)

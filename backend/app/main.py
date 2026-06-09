import sqlite3
import os
from pathlib import Path
from dotenv import load_dotenv
import requests  # <-- Importado para fazer as requisições ao TMDB
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from backend.app.database import init_db, get_db_connection
from backend.app.books import router as books_router

base_dir = Path(__file__).resolve().parent
dotenv_path = base_dir / ".env"
if not dotenv_path.exists():
    dotenv_path = base_dir.parent.parent / ".env"
load_dotenv(dotenv_path=dotenv_path)

app = FastAPI(title="Genesis Library API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(books_router)

@app.on_event("startup")
def startup_event():
    init_db()

@app.get("/")
def read_root():
    return {"status": "online", "database": "SQLite conectado"}


# -----------------------------------------------------------------------------
# MODELOS DE DADOS (Pydantic) - Para validar o que o Flutter envia no corpo (Body)
# -----------------------------------------------------------------------------
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password_hash: str  # Depois podemos aplicar criptografia aqui (como bcrypt)

class ProfileCreate(BaseModel):
    user_id: int
    name: str
    avatar_url: str = None

class FavoriteCreate(BaseModel):
    profile_id: int
    movie_id: str  # Guardando como TEXT conforme o SQL
    movie_title: str = None


# -----------------------------------------------------------------------------
# ROTAS DE USUÁRIOS 
# -----------------------------------------------------------------------------
@app.post("/api/v1/users", status_code=status.HTTP_201_CREATED)
def criar_usuario(user: UserCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?);",
            (user.username, user.email, user.password_hash)
        )
        conn.commit()
        user_id = cursor.lastrowid
        return {"id": user_id, "username": user.username, "email": user.email, "message": "Usuário criado com sucesso"}
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Este e-mail já está cadastrado.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro interno: {str(e)}")
    finally:
        conn.close()


# -----------------------------------------------------------------------------
# ROTAS DE PERFIS 
# -----------------------------------------------------------------------------
@app.get("/api/v1/users/{user_id}/profiles")
def listar_perfis_do_usuario(user_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM profiles WHERE user_id = ?;", (user_id,))
    perfis = cursor.fetchall()
    conn.close()
    return [dict(perfil) for perfil in perfis]

@app.post("/api/v1/profiles", status_code=status.HTTP_201_CREATED)
def criar_perfil(profile: ProfileCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO profiles (user_id, name, avatar_url) VALUES (?, ?, ?);",
            (profile.user_id, profile.name, profile.avatar_url)
        )
        conn.commit()
        return {"id": cursor.lastrowid, "name": profile.name, "message": "Perfil criado com sucesso"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


# -----------------------------------------------------------------------------
# ROTAS DE FAVORITOS 
# -----------------------------------------------------------------------------
@app.get("/api/v1/profiles/{profile_id}/favorites")
def listar_favoritos_do_perfil(profile_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM favorites WHERE profile_id = ?;", (profile_id,))
    favoritos = cursor.fetchall()
    conn.close()
    return [dict(favorito) for favorito in favoritos]

@app.post("/api/v1/favorites", status_code=status.HTTP_201_CREATED)
def adicionar_favorito(fav: FavoriteCreate):
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

@app.delete("/api/v1/profiles/{profile_id}/favorites/{movie_id}")
def remover_favorito(profile_id: int, movie_id: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "DELETE FROM favorites WHERE profile_id = ? AND movie_id = ?;",
        (profile_id, movie_id)
    )
    conn.commit()
    colunas_afetadas = cursor.rowcount
    conn.close()
    
    if colunas_afetadas == 0:
        raise HTTPException(status_code=404, detail="Favorito não encontrado.")
    
    return {"message": "Removido dos favoritos com sucesso"}


# -----------------------------------------------------------------------------
# ROTAS DE FILMES (Catálogo conectado ao TMDB com compatibilidade Stremio)
# -----------------------------------------------------------------------------

# TODO: # TOKEN do TMDB (ele já existe, só não está aqui por segurança)
TMDB_BEARER_TOKEN = os.getenv("TMDB_BEARER_TOKEN")

@app.get("/api/v1/movies/trending")
def obter_filmes_em_alta():
    """Busca os filmes populares e injeta o ID do IMDb para compatibilidade com Addons do Stremio."""
    url_trending = "https://api.themoviedb.org/3/trending/movie/week?language=pt-BR"
    
    headers = {
        "accept": "application/json",
        "Authorization": f"Bearer {TMDB_BEARER_TOKEN}"
    }
    
    try:
        resposta = requests.get(url_trending, headers=headers)
        if resposta.status_code != 200:
            raise HTTPException(status_code=resposta.status_code, detail="Erro ao se comunicar com o TMDB")
            
        dados_tmdb = resposta.json()
        filmes_compatíveis = []
        
        for filme in dados_tmdb.get("results", []):
            tmdb_id = filme.get("id")
            
            # Sub-requisição rápida para capturar o ID do IMDb
            url_external_ids = f"https://api.themoviedb.org/3/movie/{tmdb_id}/external_ids"
            resp_ids = requests.get(url_external_ids, headers=headers)
            
            imdb_id = None
            if resp_ids.status_code == 200:
                imdb_id = resp_ids.json().get("imdb_id")
            
            # Só adicionamos se o filme tiver o ID universal do IMDb estruturado
            if imdb_id:
                filmes_compatíveis.append({
                    "imdb_id": imdb_id,  # Chave usada pelos Addons da comunidade do Stremio
                    "tmdb_id": tmdb_id,
                    "title": filme.get("title"),
                    "overview": filme.get("overview"),
                    "release_date": filme.get("release_date"),
                    "poster_url": f"https://image.tmdb.org/t/p/w500{filme.get('poster_path')}" if filme.get("poster_path") else None,
                    "backdrop_url": f"https://image.tmdb.org/t/p/w1280{filme.get('backdrop_path')}" if filme.get("backdrop_path") else None,
                    "vote_average": filme.get("vote_average")
                })
            
        return filmes_compatíveis

    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Erro de conexão com o provedor: {str(e)}")
    
# -----------------------------------------------------------------------------
# ROTAS DE BUSCA DE FILMES 
# -----------------------------------------------------------------------------

@app.get("/api/v1/movies/search")
def buscar_filmes(query: str):
    """Busca filmes no TMDB pelo nome e injeta o ID do IMDb para compatibilidade."""
    if not query:
        raise HTTPException(status_code=400, detail="O parâmetro de busca 'query' não pode estar vazio.")
        
    # Formatamos a URL do TMDB para incluir o termo de busca codificado
    url_search = f"https://api.themoviedb.org/3/search/movie?query={requests.utils.quote(query)}&language=pt-BR"
    
    headers = {
        "accept": "application/json",
        "Authorization": f"Bearer {TMDB_BEARER_TOKEN}"
    }
    
    try:
        resposta = requests.get(url_search, headers=headers)
        if resposta.status_code != 200:
            raise HTTPException(status_code=resposta.status_code, detail="Erro ao se comunicar com o TMDB")
            
        dados_tmdb = resposta.json()
        resultados_compatíveis = []
        
        # Vamos varrer os resultados encontrados (limitando aos 10 primeiros para performance)
        for filme in dados_tmdb.get("results", [])[:10]:
            tmdb_id = filme.get("id")
            
            # Sub-requisição para capturar o ID do IMDb do filme encontrado
            url_external_ids = f"https://api.themoviedb.org/3/movie/{tmdb_id}/external_ids"
            resp_ids = requests.get(url_external_ids, headers=headers)
            
            imdb_id = None
            if resp_ids.status_code == 200:
                imdb_id = resp_ids.json().get("imdb_id")
            
            # Só adicionamos se o filme tiver o ID universal do IMDb estruturado
            if imdb_id:
                resultados_compatíveis.append({
                    "imdb_id": imdb_id,
                    "tmdb_id": tmdb_id,
                    "title": filme.get("title"),
                    "overview": filme.get("overview"),
                    "release_date": filme.get("release_date"),
                    "poster_url": f"https://image.tmdb.org/t/p/w500{filme.get('poster_path')}" if filme.get("poster_path") else None,
                    "backdrop_url": f"https://image.tmdb.org/t/p/w1280{filme.get('backdrop_path')}" if filme.get("backdrop_path") else None,
                    "vote_average": filme.get("vote_average")
                })
            
        return resultados_compatíveis

    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Erro de conexão com o provedor: {str(e)}")
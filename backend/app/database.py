import sqlite3
import os
from pathlib import Path


# Esse comando descobre a pasta raiz 'genesis-library' de forma absoluta,
# subindo 3 níveis a partir deste arquivo (database.py -> app -> backend -> raiz)
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Define o caminho exato apontando para a pasta 'database' na raiz
DB_PATH = os.path.join(BASE_DIR, "database", "app.db")
INIT_SQL = "../database/init_sqlite.sql"
SEED_SQL = "../database/seed_sqlite.sql"

def get_db_connection():
    """Cria uma conexão com o banco de dados SQLite."""
    conn = sqlite3.connect(DB_PATH)
    # Permite acessar as colunas pelos nomes (ex: linha['titulo']) em vez de índices (linha[0])
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Cria as tabelas e popula o banco caso o arquivo .db não exista."""
    if not os.path.exists(DB_PATH):
        print("Banco de dados não encontrado. Inicializando...")
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Executa o script de criação de tabelas
        if os.path.exists(INIT_SQL):
            with open(INIT_SQL, 'r', encoding='utf-8') as f:
                cursor.executescript(f.read())
        
        # Executa o script de sementes (dados iniciais), se houver
        if os.path.exists(SEED_SQL):
            with open(SEED_SQL, 'r', encoding='utf-8') as f:
                cursor.executescript(f.read())
                
        conn.commit()
        conn.close()
        print("Banco de dados inicializado com sucesso!")
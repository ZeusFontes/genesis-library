import sqlite3
import os
from pathlib import Path

# Raiz do projeto: sobe 3 níveis a partir de backend/app/database.py
BASE_DIR = Path(__file__).resolve().parent.parent.parent

DB_PATH  = BASE_DIR / "database" / "app.db"
INIT_SQL = BASE_DIR / "database" / "init_sqlite.sql"
SEED_SQL = BASE_DIR / "database" / "seed_sqlite.sql"


def get_db_connection() -> sqlite3.Connection:
    """Cria e retorna uma conexão com o banco de dados SQLite."""
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn


def init_db() -> None:
    """Cria as tabelas e popula o banco caso o arquivo .db ainda não exista."""
    if DB_PATH.exists():
        return

    print(f"[db] Banco não encontrado em '{DB_PATH}'. Inicializando...")
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    conn = get_db_connection()
    cursor = conn.cursor()

    if INIT_SQL.exists():
        cursor.executescript(INIT_SQL.read_text(encoding="utf-8"))
        print("[db] Schema criado com sucesso.")
    else:
        print(f"[db] AVISO: script de init não encontrado em '{INIT_SQL}'.")

    if SEED_SQL.exists():
        cursor.executescript(SEED_SQL.read_text(encoding="utf-8"))
        print("[db] Seed aplicado com sucesso.")

    conn.commit()
    conn.close()
    print("[db] Banco de dados pronto.")

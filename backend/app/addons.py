import sqlite3
from fastapi import HTTPException, status
from pydantic import BaseModel
from backend.app.database import get_db_connection

# Modelo de validação para o corpo da requisição (Body)
class AddonInstallRequest(BaseModel):
    profile_id: int
    addon_name: str
    addon_url: str
    manifest_url: str

# Função para instalar o Addon no banco de dados
def db_install_addon(addon: AddonInstallRequest):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            """
            INSERT INTO profile_addons (profile_id, addon_name, addon_url, manifest_url)
            VALUES (?, ?, ?, ?);
            """,
            (addon.profile_id, addon.addon_name, addon.addon_url, addon.manifest_url)
        )
        conn.commit()
        return {"message": f"Addon '{addon.addon_name}' instalado com sucesso!"}
    except sqlite3.IntegrityError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Este perfil já possui este addon instalado."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

# Função para listar os Addons de um perfil específico
def db_list_profile_addons(profile_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM profile_addons WHERE profile_id = ?;", (profile_id,))
        addons = cursor.fetchall()
        return [dict(row) for row in addons]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()
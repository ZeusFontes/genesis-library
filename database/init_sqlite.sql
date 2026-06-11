PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS profile_addons;
DROP TABLE IF EXISTS addon_catalogs;
DROP TABLE IF EXISTS addons;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE profiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    profile_id INTEGER NOT NULL,
    movie_id TEXT NOT NULL,
    movie_title TEXT,
    added_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (profile_id, movie_id),
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- Tabela de addons instalados por perfil.
-- Armazena dados do addon diretamente para compatibilidade com POST /api/v1/addons/install.
CREATE TABLE profile_addons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    profile_id INTEGER NOT NULL,
    addon_name TEXT NOT NULL,
    addon_url TEXT NOT NULL,
    manifest_url TEXT NOT NULL,
    installed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (profile_id, manifest_url),
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- Catálogo global de addons conhecidos pela plataforma (referência)
CREATE TABLE addons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    manifest_url TEXT NOT NULL UNIQUE,
    transport_url TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    version TEXT NOT NULL DEFAULT '0.0.1',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE addon_catalogs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    addon_id INTEGER NOT NULL,
    type TEXT NOT NULL,
    catalog_id TEXT NOT NULL,
    name TEXT NOT NULL,
    UNIQUE (addon_id, type, catalog_id),
    FOREIGN KEY (addon_id) REFERENCES addons(id) ON DELETE CASCADE
);

CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_favorites_profile_id ON favorites(profile_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_profile_addons_profile_id ON profile_addons(profile_id);
CREATE INDEX idx_addon_catalogs_addon_id ON addon_catalogs(addon_id);

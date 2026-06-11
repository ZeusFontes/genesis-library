# GÊNESIS — Plataforma de Filmes, Séries e Livros

> Catálogo inteligente mobile com backend Python/FastAPI e frontend Flutter.  
> Integrado com TMDB (filmes e séries) e Google Books (livros).

---

## Estrutura do Projeto

```
genesis-library/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py          ← Aplicação FastAPI (rotas principais)
│   │   ├── database.py      ← Conexão e inicialização do SQLite
│   │   ├── books.py         ← Rotas de livros (Google Books API)
│   │   ├── series.py        ← Rotas de séries (TMDB)
│   │   ├── addons.py        ← Rotas de addons (Stremio-compatible)
│   │   └── favorites.py     ← Lógica de favoritos
│   └── requirements.txt
├── database/
│   ├── init_sqlite.sql      ← Criação das tabelas
│   └── seed_sqlite.sql      ← Dados iniciais para desenvolvimento
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── services/
│   │   │   └── api_service.dart   ← Todas as chamadas HTTP ao backend
│   │   ├── screens/
│   │   │   ├── auth/              ← Login, Cadastro, Esqueci Senha
│   │   │   ├── home/              ← Telas de filmes, séries e livros
│   │   │   ├── busca/             ← Busca unificada
│   │   │   └── ...
│   │   └── ...
│   └── pubspec.yaml
├── .env.example             ← Template das variáveis de ambiente
├── .gitignore
└── start_backend.sh         ← Script de inicialização do backend
```

---

## Pré-requisitos

| Ferramenta        | Versão mínima | Link                                        |
|-------------------|---------------|---------------------------------------------|
| Python            | 3.10+         | https://python.org                          |
| Flutter SDK       | 3.0+          | https://docs.flutter.dev/get-started/install|
| Android Studio    | —             | Com emulador API 21+                        |
| Conta TMDB        | —             | https://www.themoviedb.org/settings/api     |
| Conta Google Cloud| —             | https://console.cloud.google.com            |

---

## Guia de Execução (Checklist)

### 1. Clonar / extrair o projeto
- [ ] Extraia o ZIP do projeto em uma pasta de sua preferência.
- [ ] Abra o terminal na raiz do projeto (`genesis-library/`).

### 2. Configurar variáveis de ambiente
- [ ] Copie o arquivo de exemplo: `cp .env.example .env`
- [ ] Abra o `.env` e substitua os placeholders pelas suas chaves reais:
  - `TMDB_BEARER_TOKEN` → acesse https://www.themoviedb.org/settings/api e copie o **API Read Access Token (Bearer)**.
  - `GOOGLE_BOOKS_API_KEY` → acesse https://console.cloud.google.com, ative a **Books API** e gere uma chave de API.
- [ ] Salve o arquivo `.env`.

### 3. Configurar e rodar o Backend (Python/FastAPI)
- [ ] Na raiz do projeto, crie um ambiente virtual Python:
  ```bash
  python -m venv .venv
  ```
- [ ] Ative o ambiente virtual:
  - **Linux / macOS:** `source .venv/bin/activate`
  - **Windows (CMD):** `.venv\Scripts\activate.bat`
  - **Windows (PowerShell):** `.venv\Scripts\Activate.ps1`
- [ ] Instale as dependências:
  ```bash
  pip install -r backend/requirements.txt
  ```
- [ ] Inicie o servidor:
  ```bash
  # Opção A — script pronto
  bash start_backend.sh

  # Opção B — comando direto
  uvicorn backend.app.main:app --reload --host 127.0.0.1 --port 8000
  ```
- [ ] Verifique se o servidor está rodando abrindo no navegador:  
  http://127.0.0.1:8000 → deve retornar `{"status":"online","database":"SQLite conectado"}`
- [ ] A documentação interativa da API estará em:  
  http://127.0.0.1:8000/docs

> **Nota sobre o banco de dados:** Na primeira execução o arquivo `database/app.db`  
> será criado automaticamente com as tabelas e dados de seed.

### 4. Configurar e rodar o Frontend (Flutter)
- [ ] Abra o Android Studio e inicie um emulador Android (API 21 ou superior).
- [ ] No terminal, acesse o diretório do frontend:
  ```bash
  cd frontend
  ```
- [ ] Instale as dependências Flutter:
  ```bash
  flutter pub get
  ```
- [ ] Verifique se o ambiente está correto:
  ```bash
  flutter doctor
  ```
  Resolva qualquer ❌ indicado antes de prosseguir.
- [ ] Confirme que o backend está rodando e liste os dispositivos disponíveis:
  ```bash
  flutter devices
  ```
- [ ] Execute o app no emulador:
  ```bash
  flutter run
  ```

### 5. Testar a integração
- [ ] Na tela de Login, crie uma conta usando "Cadastre-se".
- [ ] Após o cadastro, você será redirecionado para a seleção de perfis.
- [ ] Navegue pelas abas de Filmes, Séries e Livros — os dados virão do backend em tempo real.
- [ ] Use a busca para procurar conteúdo nas três categorias simultaneamente.

---

## Contas de teste (seed)

| E-mail              | Senha (texto)  |
|---------------------|----------------|
| ana@example.com     | senha123       |
| bruno@example.com   | senha456       |

> As senhas acima são exemplos. Como o seed usa hashes bcrypt fixos, o login  
> de usuários seed só funciona se o backend validar bcrypt. Para testar o fluxo  
> completo, **cadastre um novo usuário** pelo app.

---

## Endpoints da API

| Método | Rota                                          | Descrição                        |
|--------|-----------------------------------------------|----------------------------------|
| GET    | /                                             | Health-check                     |
| POST   | /api/v1/users                                 | Criar usuário                    |
| POST   | /api/v1/users/login                           | Login                            |
| GET    | /api/v1/users/{user_id}/profiles              | Listar perfis do usuário         |
| POST   | /api/v1/profiles                              | Criar perfil                     |
| GET    | /api/v1/movies/trending                       | Filmes em alta (TMDB)            |
| GET    | /api/v1/movies/search?query=...               | Buscar filmes (TMDB)             |
| GET    | /api/v1/series/trending                       | Séries em alta (TMDB)            |
| GET    | /api/v1/series/search?query=...               | Buscar séries (TMDB)             |
| GET    | /api/v1/books/search?q=...                    | Buscar livros (Google Books)     |
| GET    | /api/v1/books/{book_id}                       | Detalhes de um livro             |
| GET    | /api/v1/profiles/{profile_id}/favorites       | Listar favoritos                 |
| POST   | /api/v1/favorites                             | Adicionar favorito               |
| DELETE | /api/v1/profiles/{profile_id}/favorites/{id}  | Remover favorito                 |
| POST   | /api/v1/addons/install                        | Instalar addon em perfil         |
| GET    | /api/v1/profiles/{profile_id}/addons          | Listar addons do perfil          |

---

## Solução de Problemas

**`Connection refused` no Flutter:**  
Verifique se o backend está rodando. No emulador Android, o endereço do host é `10.0.2.2` (já configurado em `api_service.dart`). Em dispositivo físico, altere `kBaseUrl` para o IP local da sua máquina.

**`ModuleNotFoundError: backend`:**  
Certifique-se de executar o uvicorn **a partir da raiz do projeto** (`genesis-library/`), não de dentro da pasta `backend/`.

**`TMDB: Unauthorized`:**  
Confirme que usou o **Bearer Token** (API Read Access Token), não a chave de API v3. São tokens diferentes no painel do TMDB.

**Banco de dados corrompido:**  
Delete o arquivo `database/app.db` e reinicie o backend — ele será recriado automaticamente.

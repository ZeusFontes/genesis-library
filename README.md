# GÊNESIS LIBRARY

> Catálogo inteligente de filmes, séries e livros para mobile. Otimiza a descoberta de conteúdo com redirecionamento para streamings oficiais e player integrado para obras de domínio público. Desenvolvido com foco em UX e alta performance.

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=flat&logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat&logo=sqlite)
![License](https://img.shields.io/badge/status-em%20desenvolvimento-yellow?style=flat)

---

## Índice

- [Sobre](#sobre)
- [Equipe](#equipe)
- [Tecnologias](#tecnologias)
- [Estrutura do Repositório](#estrutura-do-repositório)
- [Guia de Execução Local](#guia-de-execução-local)
- [Frontend (Flutter)](#frontend-flutter)
- [Banco de Dados (SQLite)](#banco-de-dados-sqlite)

---

## Sobre

O GÊNESIS é uma plataforma mobile que centraliza a descoberta de filmes, séries e livros. Obras de domínio público são reproduzidas diretamente no aplicativo via player integrado; conteúdos modernos redirecionam o usuário para a plataforma de streaming onde estão disponíveis.

---

## Equipe

| Nome | RGM |
|---|---|
| Brenno Lucas Sabino da Silva | — |
| Daniel Costa Carvalho Martins | 37196201 |
| Gabriel Pereira Ho | — |
| Zeus Fontes Barbosa | 37300873 |

---

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Frontend | Flutter / Dart |
| Backend | Python / FastAPI |
| Banco de dados local | SQLite |

---

## Estrutura do Repositório

```text
genesis-library/
├── frontend/        → Aplicativo Flutter (Mobile e Web)
├── backend/         → API REST (Python/FastAPI)
└── database/        → Scripts SQL do banco de dados local

```

---

## Guia de Execução Local

⚠️ **Aviso Importante sobre o fluxo de inicialização:** Para que a API e a interface funcionem corretamente em conjunto sem travar os processos locais, é fundamental **seguir a ordem exata dos passos abaixo**.

### ⚙️ Passo 1: Preparando o Frontend (Primeira Etapa)

Antes de iniciar qualquer servidor, precisamos preparar os arquivos base do Flutter. Abra o terminal na pasta raiz do projeto e execute:

```powershell
# 1. Navegue até a pasta do frontend:
cd frontend

# 2. Garanta que o suporte web está configurado:
flutter create . --platforms web

# 3. Baixe e atualize as dependências do Flutter:
flutter pub get

```

### 🛑 Passo 2: REINICIE O SEU EDITOR (VS CODE)

**ATENÇÃO:** É obrigatório reiniciar o seu editor de código neste momento. Extensões do Flutter/Dart podem "segurar" processos em segundo plano. Feche o VS Code completamente e abra a pasta raiz do projeto novamente. **Se este passo for ignorado, o backend não conseguirá ser iniciado corretamente no próximo passo.**

### ⚙️ Passo 3: Configurando e Rodando o Backend (API)

Com o VS Code reaberto, abra um **novo terminal** na pasta raiz do projeto e siga os passos abaixo para iniciar o servidor:

```powershell
# 1. Crie o ambiente virtual (caso ainda não exista):
python -m venv .venv

# 2. Ative o ambiente virtual no PowerShell (Windows):
.\.venv\Scripts\Activate.ps1
# (Nota: Se houver um erro vermelho de permissão, execute `Set-ExecutionPolicy Unrestricted -Scope Process` e tente novamente).

# 3. Navegue até a pasta do backend e instale as dependências:
cd backend
pip install -r requirements.txt

# 4. Inicie o servidor da API:
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

```

✅ A API estará rodando em `http://127.0.0.1:8000`. **Deixe este terminal aberto e rodando.**

### 💻 Passo 4: Rodando o Frontend (Web)

Agora vamos iniciar a interface. Abra um **segundo terminal** (mantendo o terminal do backend rodando no fundo) e siga os passos:

```powershell
# 1. Navegue até a pasta do frontend:
cd frontend

# 2. Inicie a aplicação web (modo profile recomendado para testar performance):
flutter run -d web-server --web-port 8080 --profile

```

✅ **Pronto!** O frontend estará rodando e acessível através do seu navegador, já conectado com o backend.

---

## Frontend (Flutter)

### Pré-requisitos

| Ferramenta | Versão mínima | Link |
| --- | --- | --- |
| Flutter SDK | `>= 3.0.0` | [Instalação](https://docs.flutter.dev/get-started/install) |
| Dart SDK | `>= 3.0.0` | Incluso no Flutter |
| Android Studio / VS Code | — | Com extensão Flutter instalada |
| Dispositivo ou emulador | API 21+ | Android |

### Comandos de Build (Mobile)

```bash
# Gerar APK em modo debug
flutter build apk --debug

# Gerar APK em modo release
flutter build apk --release

```

O arquivo APK gerado será alocado no diretório: `build/app/outputs/flutter-apk/app-release.apk`.

### Dependências Principais

| Pacote | Versão | Aplicação |
| --- | --- | --- |
| `go_router` | ^16.0.0 | Navegação declarativa |
| `flutter_riverpod` | ^3.0.0 | Gerenciamento de estado |
| `cached_network_image` | ^3.4.1 | Armazenamento de imagens em cache |
| `carousel_slider` | ^5.0.0 | Implementação de hero banner rotativo |
| `google_fonts` | ^6.2.1 | Tipografia da interface |
| `flutter_animate` | ^4.5.0 | Transições e animações |
| `video_player` | ^2.10.0 | Player de vídeo integrado |
| `url_launcher` | ^6.3.1 | Redirecionamento para links externos |
| `shimmer` | ^3.0.0 | Efeito visual de carregamento (skeleton) |

### Paleta de Cores (Design System)

| Token | Hex | Aplicação |
| --- | --- | --- |
| `background` | `#000000` | Fundo principal da aplicação |
| `surface` | `#121212` | Barra de navegação inferior e superfícies com elevação |
| `secondary` | `#333333` | Botões de filtro e elementos estruturais secundários |
| `softAccent` | `#B3B3B3` | Tipografia inativa, bordas e ícones não selecionados |
| `primaryAccent` | `#D9AD00` | Botões de ação principal (CTA) e elementos ativos |
| `white` | `#FFFFFF` | Tipografia de destaque |
| `grey` | `#808080` | Tipografia de descrição e subtítulos |

### Solução de Problemas Comuns

* **Erros do tipo "Target of URI doesn't exist" no VS Code:** A IDE pode estar abrindo a raiz do repositório. Abra especificamente o diretório `frontend/`, que contém o arquivo `pubspec.yaml`.
* **Emulador não listado ao executar `flutter devices`:** Inicie um emulador através do Device Manager no Android Studio ou conecte um dispositivo físico garantindo que a depuração USB esteja ativada.
* **Falha de compilação com erro do Gradle (Mobile):** Limpe os arquivos temporários do Android executando `cd android && ./gradlew clean && cd .. && flutter run`.

---

## Banco de Dados (SQLite)

Os scripts iniciais estruturam a base do sistema local da aplicação.

### Instruções de Execução

```bash
# A partir do diretório raiz do projeto
sqlite3 app.db < database/init_sqlite.sql
sqlite3 app.db < database/seed_sqlite.sql

```

Este procedimento cria o banco de dados com a estrutura base e insere os dados de exemplo necessários para o ambiente de desenvolvimento.

### Scripts de Banco de Dados

| Arquivo | Finalidade |
| --- | --- |
| `database/init_sqlite.sql` | Estruturação do schema e criação das tabelas `users`, `profiles`, `favorites`, `addons`, `profile_addons` e `addon_catalogs`. |
| `database/seed_sqlite.sql` | Inserção de dados iniciais para validação de fluxos de cadastro, autenticação, listagens e addons. |

### Schema Relacional

**Tabela: `users**`

| Coluna | Tipo | Descrição |
| --- | --- | --- |
| `id` | INTEGER | Chave primária |
| `username` | TEXT | Nome de registro do usuário |
| `email` | TEXT | Identificador único |
| `password_hash` | TEXT | Credencial criptografada |
| `created_at` | DATETIME | Data de registro |

**Tabela: `profiles**`

| Coluna | Tipo | Descrição |
| --- | --- | --- |
| `id` | INTEGER | Chave primária |
| `user_id` | INTEGER | Chave estrangeira (Referência: `users.id`) |
| `name` | TEXT | Nome de exibição do perfil |
| `avatar_url` | TEXT | Endereço da imagem do avatar |
| `created_at` | DATETIME | Data de criação |

**Tabela: `favorites**`

| Coluna | Tipo | Descrição |
| --- | --- | --- |
| `id` | INTEGER | Chave primária |
| `profile_id` | INTEGER | Chave estrangeira (Referência: `profiles.id`) |
| `movie_id` | TEXT | Identificador interno da mídia |
| `movie_title` | TEXT | Título da mídia favoritada |
| `added_at` | DATETIME | Data de inserção na lista |

**Tabela: `addons**`

| Coluna | Tipo | Descrição |
| --- | --- | --- |
| `id` | INTEGER | Chave primária |
| `manifest_url` | TEXT | URL do manifesto JSON do addon (único) |
| `transport_url` | TEXT | Endpoint base para requisições ao addon |
| `name` | TEXT | Nome de exibição do addon |
| `description` | TEXT | Descrição do addon |
| `version` | TEXT | Versão do addon |
| `created_at` | DATETIME | Data de registro |

**Tabela: `profile_addons**`

| Coluna | Tipo | Descrição |
| --- | --- | --- |
| `id` | INTEGER | Chave primária |
| `profile_id` | INTEGER | Chave estrangeira (Referência: `profiles.id`) |
| `addon_id` | INTEGER | Chave estrangeira (Referência: `addons.id`) |
| `installed_at` | DATETIME | Data de instalação do addon no perfil |

**Tabela: `addon_catalogs**`

| Coluna | Tipo | Descrição |
| --- | --- | --- |
| `id` | INTEGER | Chave primária |
| `addon_id` | INTEGER | Chave estrangeira (Referência: `addons.id`) |
| `type` | TEXT | Tipo de conteúdo (`movie`, `series`, `anime`) |
| `catalog_id` | TEXT | Identificador interno do catálogo no addon |
| `name` | TEXT | Nome de exibição do catálogo |

### Regras de Negócio Estabelecidas

1. A autenticação do sistema exige estritamente `email` e `senha` (esta última validada via hash).
2. O `username` é capturado e fixado no momento do cadastro inicial.
3. A arquitetura de contas suporta múltiplos perfis vinculados a um único usuário raiz.
4. As listas de favoritos mantêm relação de dependência com a tabela `profiles`, garantindo isolamento de dados entre os diferentes usuários de uma mesma conta.
5. Cada perfil possui sua própria lista de addons instalados, permitindo configurações independentes por perfil (ex: perfil infantil com addons diferentes do perfil adulto).
6. Os catálogos disponíveis em cada addon são armazenados localmente na tabela `addon_catalogs`, evitando consultas repetidas ao manifesto remoto.

```

```

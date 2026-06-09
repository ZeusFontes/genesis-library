```md
# GÊNESIS

> Catálogo inteligente de filmes, séries e livros para mobile. Otimiza a descoberta de conteúdo com redirecionamento para streamings oficiais e player integrado para obras de domínio público.

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=flat&logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat&logo=sqlite)
![License](https://img.shields.io/badge/status-em%20desenvolvimento-yellow?style=flat)

---

## Índice

- [Sobre](#sobre)
- [Equipe](#equipe)
- [Tecnologias](#tecnologias)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Frontend](#frontend)
- [Banco de dados](#banco-de-dados)
- [Contribuindo](#contribuindo)

---

## Sobre

O GÊNESIS é uma plataforma mobile que centraliza a descoberta de filmes, séries e livros. Obras de domínio público são reproduzidas diretamente no app via player integrado; conteúdos modernos redirecionam o usuário para a plataforma de streaming onde estão disponíveis.

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
| Banco de dados local | SQLite |

---

## Estrutura do repositório

```
genesis-library/
├── frontend/        → Aplicativo Flutter (mobile Android)
└── database/        → Scripts SQL do banco de dados local
```

---

## Frontend

### Pré-requisitos

| Ferramenta | Versão mínima | |
|---|---|---|
| Flutter SDK | `>= 3.0.0` | [Instalação](https://docs.flutter.dev/get-started/install) |
| Dart SDK | `>= 3.0.0` | Incluso no Flutter |
| Android Studio ou VS Code | — | Com extensão Flutter instalada |
| Dispositivo ou emulador Android | API 21+ | — |

Antes de continuar, verifique se o ambiente está configurado corretamente:

```bash
flutter doctor
```

### Instalação

```bash
# Clone o repositório
git clone https://github.com/ZeusFontes/genesis-library.git
cd genesis-library

# Acesse a branch do frontend
git checkout front

# Entre na pasta
cd frontend

# Instale as dependências
flutter pub get
```

### Execução

```bash
# Listar dispositivos disponíveis
flutter devices

# Rodar em modo debug
flutter run

# Rodar em dispositivo específico
flutter run -d <device_id>

# Rodar em modo release
flutter run --release
```

### Build

```bash
# APK debug
flutter build apk --debug

# APK release
flutter build apk --release
```

O APK gerado fica em:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Estrutura

```
frontend/
├── assets/
│   └── logo/
├── lib/
│   ├── main.dart                        → Entrada do app e registro de rotas
│   ├── core/
│   │   ├── constants/                   → AppColors, AppRoutes, AppAssets
│   │   └── theme/                       → ThemeData escuro customizado
│   ├── models/                          → MediaContent, Profile, Addon, CastMember
│   ├── mocks/                           → Dados fictícios para desenvolvimento
│   ├── navigation/                      → BottomNavigationBar principal
│   ├── screens/
│   │   ├── auth/                        → Login, Cadastro, Esqueci senha
│   │   ├── profiles/                    → Seleção de perfil
│   │   ├── home/                        → Filmes, Séries, Livros
│   │   ├── busca/                       → Busca global
│   │   ├── details/                     → Detalhe de filme e livro
│   │   ├── downloads/                   → Conteúdos baixados
│   │   ├── historico/                   → Histórico de visualização
│   │   ├── notificacoes/                → Notificações
│   │   ├── addons/                      → Extensões do app
│   │   ├── profile/                     → Perfil do usuário
│   │   └── configuracoes/               → Configurações e subpáginas
│   └── widgets/                         → Componentes reutilizáveis
└── pubspec.yaml
```

### Dependências

| Pacote | Versão | Uso |
|---|---|---|
| `go_router` | `^16.0.0` | Navegação declarativa |
| `flutter_riverpod` | `^3.0.0` | Gerenciamento de estado |
| `cached_network_image` | `^3.4.1` | Imagens com cache |
| `carousel_slider` | `^5.0.0` | Hero banner rotativo |
| `google_fonts` | `^6.2.1` | Tipografia |
| `flutter_animate` | `^4.5.0` | Animações |
| `video_player` | `^2.10.0` | Player de vídeo |
| `url_launcher` | `^6.3.1` | Links de streaming externo |
| `shimmer` | `^3.0.0` | Loading skeleton |

### Paleta de cores

| Token | Hex | Uso |
|---|---|---|
| `background` | `#000000` | Fundo principal |
| `surface` | `#121212` | Bottom nav e superfícies elevadas |
| `secondary` | `#333333` | Botões de filtro e elementos secundários |
| `softAccent` | `#B3B3B3` | Textos inativos, bordas, ícones não selecionados |
| `primaryAccent` | `#D9AD00` | Botões principais e seleções ativas |
| `white` | `#FFFFFF` | Textos principais |
| `grey` | `#808080` | Textos descritivos |

### Solução de problemas

**Erros de "Target of URI doesn't exist" no VS Code**
O VS Code está abrindo a pasta errada. Abra especificamente a pasta `frontend/`, que contém o `pubspec.yaml`.

**Emulador não aparece em `flutter devices`**
Abra o Android Studio → Device Manager e inicie um emulador, ou conecte um dispositivo físico com depuração USB ativada.

**Build falha com erro do Gradle**
```bash
cd android && ./gradlew clean && cd .. && flutter run
```

---

## Banco de dados

### Scripts

| Arquivo | Descrição |
|---|---|
| `database/init_sqlite.sql` | Criação do schema com as tabelas `users`, `profiles` e `favorites` |
| `database/seed_sqlite.sql` | Inserts iniciais para desenvolvimento e teste |

### Como executar

```bash
sqlite3 app.db < database/init_sqlite.sql
sqlite3 app.db < database/seed_sqlite.sql
```

### Schema

**users**

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | INTEGER | Chave primária |
| `username` | TEXT | Nome de usuário |
| `email` | TEXT | Único |
| `password_hash` | TEXT | Senha armazenada como hash |
| `created_at` | DATETIME | — |

**profiles**

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | INTEGER | Chave primária |
| `user_id` | INTEGER | Referência para `users.id` |
| `name` | TEXT | Nome do perfil |
| `avatar_url` | TEXT | — |
| `created_at` | DATETIME | — |

**favorites**

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | INTEGER | Chave primária |
| `profile_id` | INTEGER | Referência para `profiles.id` |
| `movie_id` | TEXT | — |
| `movie_title` | TEXT | — |
| `added_at` | DATETIME | — |

### Observações

- O login utiliza `email` e senha armazenada como hash.
- Cada conta pode ter múltiplos perfis, seguindo o modelo Netflix.
- Os favoritos são vinculados ao perfil, não à conta, permitindo listas independentes por perfil.

---

## Contribuindo

```bash
# Crie uma branch a partir de front
git checkout front
git checkout -b feat/nome-da-feature

# Após as alterações, verifique se não há erros
flutter analyze

# Envie e abra um Pull Request para a branch front
git push origin feat/nome-da-feature
```
```

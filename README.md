# genesis-library
Catálogo inteligente de filmes, séries e livros para mobile. Otimiza a descoberta de conteúdo com redirecionamento para streamings oficiais e player integrado para obras de domínio público. Desenvolvido com foco em UX e alta performance.

## Equipe

- Brenno
- Daniel Costa Carvalho Martins | RGM: 37196201
- Gabriel Pereira Ho
- Zeus Fontes Barbosa

## Tecnologias

- SQLite | banco de dados

## Banco de dados SQLite

Foram adicionados os scripts iniciais para a base do sistema de streaming mobile:

- `database/init_sqlite.sql`: criação do schema do banco com as tabelas `users` e `favorites`.
- `database/seed_sqlite.sql`: inserts iniciais de desenvolvimento e teste para validar cadastro, login e favoritos.

### Estrutura implementada

- `users`
  - `id`
  - `username`
  - `email` (único)
  - `password_hash`
  - `created_at`

- `favorites`
  - `id`
  - `user_id` (referência para `users.id`)
  - `movie_id`
  - `movie_title`
  - `added_at`

### Observações

- O login utiliza apenas `email` e `senha` (armazenada como hash).
- O nome de usuário é armazenado no cadastro.
- Cada usuário pode ter uma lista de filmes favoritos associada.

Esses arquivos são o ponto inicial para a camada local do app em SQLite.

### Como executar

```sh
sqlite3 app.db < database/init_sqlite.sql
sqlite3 app.db < database/seed_sqlite.sql
```

Assim, o banco é criado com a estrutura base e já recebe os dados de exemplo para desenvolvimento.

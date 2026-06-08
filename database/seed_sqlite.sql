-- Seed de desenvolvimento e testes
-- Este script insere dados iniciais para validar cadastro, login, perfis e favoritos.

INSERT INTO users (id, username, email, password_hash) VALUES
    (1, 'Ana Silva', 'ana@example.com', '$2a$12$Q7Z1x3Y3m1Q3p9CwP9Q6FuM0Gv4W2Yj1K5jQ8cU2C4mPjR9L2o8e'),
    (2, 'Bruno Costa', 'bruno@example.com', '$2a$12$H8k3fP0QhQ7dJ7u8N9rU7u9a1tO4YhE4mX6r2A3kQv6L1n9Y6m2');

-- Ana tem dois perfis: um adulto e um kids
-- Bruno tem um perfil principal com PIN
INSERT INTO profiles (id, user_id, name, avatar_url) VALUES
    (1, 1, 'Ana',      'avatars/ana.png'),
    (2, 1, 'Crianças', 'avatars/kids.png'),
    (3, 2, 'Bruno',    'avatars/bruno.png');

INSERT INTO favorites (id, profile_id, movie_id, movie_title) VALUES
    (1, 1, 'mv_001', 'Inception'),
    (2, 1, 'mv_002', 'Interstellar'),
    (3, 2, 'mv_003', 'Moana'),
    (4, 3, 'mv_001', 'Inception');

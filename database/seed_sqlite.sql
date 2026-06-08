-- Seed de desenvolvimento e testes
-- Este script insere dados iniciais para validar cadastro, login e favoritos.

INSERT INTO users (id, username, email, password_hash) VALUES
    (1, 'Ana Silva', 'ana@example.com', '$2a$12$Q7Z1x3Y3m1Q3p9CwP9Q6FuM0Gv4W2Yj1K5jQ8cU2C4mPjR9L2o8e'),
    (2, 'Bruno Costa', 'bruno@example.com', '$2a$12$H8k3fP0QhQ7dJ7u8N9rU7u9a1tO4YhE4mX6r2A3kQv6L1n9Y6m2');

INSERT INTO favorites (id, user_id, movie_id, movie_title) VALUES
    (1, 1, 'mv_001', 'Inception'),
    (2, 1, 'mv_002', 'Interstellar'),
    (3, 2, 'mv_001', 'Inception');

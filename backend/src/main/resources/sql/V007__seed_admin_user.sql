-- V007: 관리자 초기 계정
-- BCrypt hash of 'admin1234!' (strength 10)
INSERT INTO users (email, password_hash, name, role, branch_name, is_active)
VALUES (
    N'admin@jobmoa.kr',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    N'시스템관리자',
    'MANAGER',
    N'본부',
    1
);

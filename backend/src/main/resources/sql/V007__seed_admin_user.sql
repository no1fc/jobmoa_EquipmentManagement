-- V007: 관리자 초기 계정
-- BCrypt hash of 'admin1234!' (strength 10)
INSERT INTO users (email, password_hash, name, role, branch_name, is_active)
VALUES (
    N'admin@jobmoa.com',
    '$2a$10$rYtnlLX7bXSvp0vZ6HHobOoIqeZjxKYJ4.BgllkTHLVvCJgfbrAEq',
    N'시스템관리자',
    'MANAGER',
    N'본부',
    1
);
-- password: admin1234!

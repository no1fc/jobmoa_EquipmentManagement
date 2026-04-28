-- V001: 사용자 테이블
CREATE TABLE users (
    user_id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    email           NVARCHAR(255) NOT NULL,
    password_hash   NVARCHAR(255) NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    role            NVARCHAR(20)  NOT NULL DEFAULT 'COUNSELOR',
    branch_name     NVARCHAR(100),
    phone           NVARCHAR(20),
    fcm_token       NVARCHAR(500),
    is_active       BIT NOT NULL DEFAULT 1,
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_users_email UNIQUE (email),
    CONSTRAINT CK_users_role CHECK (role IN ('COUNSELOR', 'MANAGER'))
);

CREATE INDEX IX_users_email ON users(email);
CREATE INDEX IX_users_role ON users(role);
CREATE INDEX IX_users_is_active ON users(is_active);

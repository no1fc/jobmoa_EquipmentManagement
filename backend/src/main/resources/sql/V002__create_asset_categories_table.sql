-- V002: 장비 카테고리 테이블 (계층 구조: 대/중/소분류)
CREATE TABLE asset_categories (
    category_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    parent_id       BIGINT NULL,
    category_name   NVARCHAR(100) NOT NULL,
    category_level  INT NOT NULL,
    description     NVARCHAR(500),
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_categories_parent FOREIGN KEY (parent_id)
        REFERENCES asset_categories(category_id),
    CONSTRAINT CK_categories_level CHECK (category_level IN (1, 2, 3))
);

CREATE INDEX IX_asset_categories_parent ON asset_categories(parent_id);
CREATE INDEX IX_asset_categories_level ON asset_categories(category_level);

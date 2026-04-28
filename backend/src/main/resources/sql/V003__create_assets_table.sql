-- V003: 장비/자산 테이블
CREATE TABLE assets (
    asset_id        BIGINT IDENTITY(1,1) PRIMARY KEY,
    asset_code      NVARCHAR(64)  NOT NULL,
    category_id     BIGINT        NOT NULL,
    asset_name      NVARCHAR(200) NOT NULL,
    serial_number   NVARCHAR(128),
    manufacturer    NVARCHAR(100),
    model_number    NVARCHAR(128),
    purchase_date   DATE,
    location        NVARCHAR(200),
    status          NVARCHAR(20)  NOT NULL DEFAULT 'IN_USE',
    condition_rating INT          DEFAULT 5,
    technical_specs NVARCHAR(MAX),
    image_path      NVARCHAR(500),
    ai_classified   BIT           DEFAULT 0,
    notes           NVARCHAR(MAX),
    registered_by   BIGINT        NOT NULL,
    created_at      DATETIME2     NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2     NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_assets_code UNIQUE (asset_code),
    CONSTRAINT FK_assets_category FOREIGN KEY (category_id)
        REFERENCES asset_categories(category_id),
    CONSTRAINT FK_assets_registered_by FOREIGN KEY (registered_by)
        REFERENCES users(user_id),
    CONSTRAINT CK_assets_status CHECK (status IN ('IN_USE', 'RENTED', 'BROKEN', 'IN_STORAGE', 'DISPOSED')),
    CONSTRAINT CK_assets_condition CHECK (condition_rating BETWEEN 1 AND 5)
);

CREATE INDEX IX_assets_code ON assets(asset_code);
CREATE INDEX IX_assets_category ON assets(category_id);
CREATE INDEX IX_assets_status ON assets(status);
CREATE INDEX IX_assets_location ON assets(location);
CREATE INDEX IX_assets_registered_by ON assets(registered_by);

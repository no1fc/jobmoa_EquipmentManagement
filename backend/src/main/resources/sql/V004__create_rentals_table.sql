-- V004: 대여/반납 테이블
CREATE TABLE rentals (
    rental_id        BIGINT IDENTITY(1,1) PRIMARY KEY,
    asset_id         BIGINT        NOT NULL,
    borrower_id      BIGINT        NOT NULL,
    approver_id      BIGINT,
    rental_reason    NVARCHAR(500),
    borrower_name    NVARCHAR(100),
    rental_date      DATETIME2     NOT NULL DEFAULT GETDATE(),
    due_date         DATETIME2     NOT NULL,
    return_date      DATETIME2,
    status           NVARCHAR(20)  NOT NULL DEFAULT 'RENTED',
    extension_count  INT           NOT NULL DEFAULT 0,
    return_condition NVARCHAR(500),
    created_at       DATETIME2     NOT NULL DEFAULT GETDATE(),
    updated_at       DATETIME2     NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_rentals_asset FOREIGN KEY (asset_id)
        REFERENCES assets(asset_id),
    CONSTRAINT FK_rentals_borrower FOREIGN KEY (borrower_id)
        REFERENCES users(user_id),
    CONSTRAINT FK_rentals_approver FOREIGN KEY (approver_id)
        REFERENCES users(user_id),
    CONSTRAINT CK_rentals_status CHECK (status IN ('RENTED', 'RETURNED', 'OVERDUE', 'CANCELLED')),
    CONSTRAINT CK_rentals_extension CHECK (extension_count BETWEEN 0 AND 1)
);

CREATE INDEX IX_rentals_asset ON rentals(asset_id);
CREATE INDEX IX_rentals_borrower ON rentals(borrower_id);
CREATE INDEX IX_rentals_status ON rentals(status);
CREATE INDEX IX_rentals_due_date ON rentals(due_date);

-- V005: 알림 테이블
CREATE TABLE notifications (
    notification_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id         BIGINT        NOT NULL,
    type            NVARCHAR(50)  NOT NULL,
    title           NVARCHAR(200) NOT NULL,
    message         NVARCHAR(MAX),
    is_read         BIT           NOT NULL DEFAULT 0,
    channel         NVARCHAR(20)  NOT NULL DEFAULT 'IN_APP',
    reference_id    BIGINT,
    sent_at         DATETIME2     NOT NULL DEFAULT GETDATE(),
    read_at         DATETIME2,

    CONSTRAINT FK_notifications_user FOREIGN KEY (user_id)
        REFERENCES users(user_id),
    CONSTRAINT CK_notifications_type CHECK (type IN ('RENTAL_DUE', 'RENTAL_OVERDUE', 'SYSTEM')),
    CONSTRAINT CK_notifications_channel CHECK (channel IN ('IN_APP', 'EMAIL', 'PUSH'))
);

CREATE INDEX IX_notifications_user ON notifications(user_id);
CREATE INDEX IX_notifications_read ON notifications(user_id, is_read);
CREATE INDEX IX_notifications_type ON notifications(type);

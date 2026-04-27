# DB 스키마 설계 (MSSQL)

> PRD Phase 1 MVP 기준 핵심 테이블

## ER 다이어그램 (개요)

```
┌──────────┐     ┌──────────────┐     ┌──────────┐
│  users   │────<│   rentals    │>────│  assets  │
└──────────┘     └──────────────┘     └──────────┘
                                           │
                                      ┌────┴─────┐
                                      │ asset_   │
                                      │categories│
                                      └──────────┘

┌──────────────┐     ┌──────────────────────┐
│ consumables  │────<│ consumable_withdrawals│
└──────────────┘     └──────────────────────┘

┌──────────────┐
│notifications │
└──────────────┘
```

## 테이블 정의

### 1. users (사용자)

```sql
CREATE TABLE users (
    user_id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    email           NVARCHAR(255) NOT NULL UNIQUE,
    password_hash   NVARCHAR(255) NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    role            NVARCHAR(20) NOT NULL DEFAULT 'COUNSELOR',
        -- COUNSELOR: 상담사, MANAGER: 지점관리자
    branch_name     NVARCHAR(100),          -- 소속 지점명
    phone           NVARCHAR(20),
    is_active       BIT NOT NULL DEFAULT 1,
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE INDEX IX_users_email ON users(email);
CREATE INDEX IX_users_role ON users(role);
```

### 2. asset_categories (장비 카테고리)

```sql
CREATE TABLE asset_categories (
    category_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    parent_id       BIGINT NULL REFERENCES asset_categories(category_id),
    category_name   NVARCHAR(100) NOT NULL,
    category_level  INT NOT NULL,
        -- 1: 대분류 (IT장비, 가구, 소모품)
        -- 2: 중분류 (PC, 프린터, 올문장 등)
        -- 3: 소분류 (데스크탑, 노트북, 5단장, 3단장 등)
    description     NVARCHAR(500),
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE INDEX IX_asset_categories_parent ON asset_categories(parent_id);
```

### 3. assets (장비/자산)

```sql
CREATE TABLE assets (
    asset_id        BIGINT IDENTITY(1,1) PRIMARY KEY,
    asset_code      NVARCHAR(64) NOT NULL UNIQUE,   -- 자산 관리 번호
    category_id     BIGINT NOT NULL REFERENCES asset_categories(category_id),
    asset_name      NVARCHAR(200) NOT NULL,          -- 장비명
    serial_number   NVARCHAR(128),                   -- 시리얼 넘버
    manufacturer    NVARCHAR(100),                   -- 제조사
    model_number    NVARCHAR(128),                   -- 모델명
    purchase_date   DATE,                            -- 구매일자
    location        NVARCHAR(200),                   -- 보관 위치 (ex. 제1상담실)
    status          NVARCHAR(20) NOT NULL DEFAULT 'IN_USE',
        -- IN_USE: 사용중, RENTED: 대여중, BROKEN: 고장,
        -- IN_STORAGE: 보관중, DISPOSED: 폐기
    condition_rating INT DEFAULT 5,                  -- 상태 등급 (1~5)
    technical_specs NVARCHAR(MAX),                   -- JSON 형태 스펙 정보
    image_path      NVARCHAR(500),                   -- 장비 사진 경로
    ai_classified   BIT DEFAULT 0,                   -- AI로 분류되었는지 여부
    notes           NVARCHAR(MAX),                   -- 비고
    registered_by   BIGINT NOT NULL REFERENCES users(user_id),
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE INDEX IX_assets_code ON assets(asset_code);
CREATE INDEX IX_assets_category ON assets(category_id);
CREATE INDEX IX_assets_status ON assets(status);
CREATE INDEX IX_assets_location ON assets(location);
```

### 4. rentals (대여/반납)

```sql
CREATE TABLE rentals (
    rental_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
    asset_id        BIGINT NOT NULL REFERENCES assets(asset_id),
    borrower_id     BIGINT NOT NULL REFERENCES users(user_id),  -- 대여자
    approver_id     BIGINT REFERENCES users(user_id),           -- 승인자
    rental_reason   NVARCHAR(500),                   -- 대여 사유
    borrower_name   NVARCHAR(100),                   -- 대여 대상자명 (내담자일 경우)
    rental_date     DATETIME2 NOT NULL DEFAULT GETDATE(), -- 대여일
    due_date        DATETIME2 NOT NULL,              -- 반납 예정일
    return_date     DATETIME2,                       -- 실제 반납일
    status          NVARCHAR(20) NOT NULL DEFAULT 'RENTED',
        -- RENTED: 대여중, RETURNED: 반납완료,
        -- OVERDUE: 연체, CANCELLED: 취소
    return_condition NVARCHAR(500),                  -- 반납 시 상태 메모
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE INDEX IX_rentals_asset ON rentals(asset_id);
CREATE INDEX IX_rentals_borrower ON rentals(borrower_id);
CREATE INDEX IX_rentals_status ON rentals(status);
CREATE INDEX IX_rentals_due_date ON rentals(due_date);
```

### 5. consumables (소모품) — Phase 2

```sql
CREATE TABLE consumables (
    consumable_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
    sku_code        NVARCHAR(64) NOT NULL UNIQUE,    -- 소모품 코드
    item_name       NVARCHAR(200) NOT NULL,          -- 소모품명
    category        NVARCHAR(100),                   -- 분류 (용지, 토너, 필기구 등)
    quantity        INT NOT NULL DEFAULT 0,          -- 현재 수량
    unit            NVARCHAR(20) DEFAULT 'EA',       -- 단위 (EA, BOX, PACK 등)
    reorder_threshold INT,                           -- 안전 재고 기준
    location        NVARCHAR(200),                   -- 보관 위치
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);
```

### 6. consumable_withdrawals (소모품 출고 기록) — Phase 2

```sql
CREATE TABLE consumable_withdrawals (
    withdrawal_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
    consumable_id   BIGINT NOT NULL REFERENCES consumables(consumable_id),
    quantity         INT NOT NULL,                    -- 출고 수량
    requester_id    BIGINT NOT NULL REFERENCES users(user_id),
    purpose         NVARCHAR(500),                   -- 출고 목적
    withdrawn_at    DATETIME2 NOT NULL DEFAULT GETDATE()
);
```

### 7. notifications (알림)

```sql
CREATE TABLE notifications (
    notification_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(user_id),
    type            NVARCHAR(50) NOT NULL,
        -- RENTAL_DUE: 반납 예정, RENTAL_OVERDUE: 연체,
        -- SYSTEM: 시스템 알림
    title           NVARCHAR(200) NOT NULL,
    message         NVARCHAR(MAX),
    is_read         BIT NOT NULL DEFAULT 0,
    channel         NVARCHAR(20) NOT NULL DEFAULT 'IN_APP',
        -- IN_APP, EMAIL, PUSH
    sent_at         DATETIME2 NOT NULL DEFAULT GETDATE(),
    read_at         DATETIME2
);

CREATE INDEX IX_notifications_user ON notifications(user_id);
CREATE INDEX IX_notifications_read ON notifications(is_read);
```

## 초기 데이터 (카테고리)

```sql
-- 대분류
INSERT INTO asset_categories (category_name, category_level, parent_id)
VALUES
    ('IT 장비', 1, NULL),
    ('사무용 가구', 1, NULL),
    ('소모품', 1, NULL);

-- 중분류 (IT 장비)
INSERT INTO asset_categories (category_name, category_level, parent_id)
VALUES
    ('컴퓨터', 2, 1),
    ('모니터', 2, 1),
    ('프린터', 2, 1),
    ('핸드폰', 2, 1),
    ('네트워크 장비', 2, 1);

-- 중분류 (사무용 가구)
INSERT INTO asset_categories (category_name, category_level, parent_id)
VALUES
    ('올문장', 2, 2),
    ('책상', 2, 2),
    ('의자', 2, 2),
    ('파티션', 2, 2);

-- 소분류 (컴퓨터)
INSERT INTO asset_categories (category_name, category_level, parent_id)
VALUES
    ('데스크탑', 3, 4),
    ('노트북', 3, 4);

-- 소분류 (올문장)
INSERT INTO asset_categories (category_name, category_level, parent_id)
VALUES
    ('5단장', 3, 9),
    ('3단장', 3, 9);
```

## MSSQL 참고사항

- `JSONB` 대신 `NVARCHAR(MAX)` 사용, `JSON_VALUE()` / `JSON_QUERY()` 함수로 조회
- `IDENTITY(1,1)` 로 자동증가 PK
- `DATETIME2` 는 `DATETIME` 보다 정밀도 높음 (권장)
- `BIT` 는 Boolean 대체 (0=false, 1=true)
- `NVARCHAR` 는 유니코드 지원 (한글 데이터 필수)

# MSSQL (SQL Server) 규칙

## 네이밍 컨벤션

| 대상 | 규칙 | 예시 |
|------|------|------|
| 테이블 | snake_case (복수형) | `assets`, `rentals`, `asset_categories` |
| 컬럼 | snake_case | `asset_code`, `purchase_date`, `is_active` |
| PK | 테이블_단수_id | `asset_id`, `rental_id`, `user_id` |
| FK | 참조테이블_단수_id | `category_id`, `borrower_id` |
| 인덱스 | IX_테이블_컬럼 | `IX_assets_status`, `IX_rentals_due_date` |
| 제약조건 | CK/UQ/DF_테이블_컬럼 | `CK_assets_status`, `UQ_users_email` |

## 데이터 타입 규칙

| 용도 | MSSQL 타입 | 주의사항 |
|------|-----------|----------|
| 문자열 (한글) | `NVARCHAR` | 유니코드 필수, `VARCHAR` 사용 금지 |
| 긴 텍스트/JSON | `NVARCHAR(MAX)` | JSON_VALUE(), JSON_QUERY() 함수 활용 |
| 날짜시간 | `DATETIME2` | `DATETIME` 대신 사용 (정밀도 높음) |
| 날짜만 | `DATE` | 시간 불필요 시 |
| 불리언 | `BIT` | 0=false, 1=true |
| 자동증가 PK | `BIGINT IDENTITY(1,1)` | 대용량 대비 BIGINT |
| 금액 | `DECIMAL(18,2)` | 부동소수점 오차 방지 |

## 쿼리 규칙

```sql
-- GOOD: 파라미터 바인딩 (SQL Injection 방지)
SELECT * FROM assets WHERE status = @status AND category_id = @categoryId;

-- BAD: 문자열 직접 결합
SELECT * FROM assets WHERE status = '" + status + "';

-- 페이지네이션 (OFFSET-FETCH)
SELECT a.asset_id, a.asset_name, a.status
FROM assets a
ORDER BY a.created_at DESC
OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;

-- JSON 조회
SELECT asset_id, asset_name,
       JSON_VALUE(technical_specs, '$.cpu') AS cpu,
       JSON_VALUE(technical_specs, '$.ram') AS ram
FROM assets
WHERE JSON_VALUE(technical_specs, '$.ram') >= '16GB';
```

## JPA + MSSQL 매핑

```java
// Entity에서 MSSQL 타입 매핑
@Entity
@Table(name = "assets")
public class Asset {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "asset_id")
    private Long assetId;

    @Column(name = "asset_name", nullable = false, length = 200)
    private String assetName;  // → NVARCHAR(200)

    @Column(name = "technical_specs", columnDefinition = "NVARCHAR(MAX)")
    private String technicalSpecs;  // JSON 문자열

    @Column(name = "is_active")
    private Boolean isActive;  // → BIT

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;  // → DATETIME2
}
```

## 성능 규칙

- 인덱스: WHERE, JOIN, ORDER BY에 자주 사용되는 컬럼에 생성
- N+1 문제: `@EntityGraph` 또는 `JOIN FETCH` 사용
- 대량 데이터: 페이지네이션 필수 (OFFSET-FETCH)
- 소프트 삭제: `is_active BIT` 또는 `deleted_at DATETIME2` 사용

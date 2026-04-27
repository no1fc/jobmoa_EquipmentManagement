# Java / Spring Boot 코딩 스타일

> 이 프로젝트: Java 21 LTS + Spring Boot 3.x + Jakarta EE

## 프로젝트 구조 (Layered Architecture)

```
backend/src/main/java/com/jobmoa/equipment/
├── config/          # Spring 설정 (Security, CORS, Swagger 등)
├── domain/          # 도메인 엔티티, Enum
│   ├── asset/
│   ├── rental/
│   ├── user/
│   ├── consumable/
│   └── notification/
├── repository/      # JPA Repository 인터페이스
├── service/         # 비즈니스 로직
├── controller/      # REST API 컨트롤러
├── dto/             # Request/Response DTO
│   ├── request/
│   └── response/
├── security/        # JWT, 인증/인가 관련
├── exception/       # 커스텀 예외 + GlobalExceptionHandler
└── util/            # 유틸리티 클래스
```

## 네이밍 컨벤션

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스 | PascalCase | `AssetService`, `RentalController` |
| 메서드/변수 | camelCase | `findByAssetCode`, `rentalDate` |
| 상수 | UPPER_SNAKE_CASE | `MAX_RENTAL_DAYS`, `DEFAULT_PAGE_SIZE` |
| 패키지 | lowercase | `com.jobmoa.equipment.domain.asset` |
| DTO | 접미사 Request/Response | `AssetCreateRequest`, `AssetResponse` |
| Entity | 도메인명 그대로 | `Asset`, `Rental`, `User` |
| Repository | Entity + Repository | `AssetRepository` |
| Service | 도메인 + Service | `AssetService` |
| Controller | 도메인 + Controller | `AssetController` |

## Java 21 기능 활용

```java
// Record 사용 (DTO에 적극 활용)
public record AssetResponse(
    Long assetId,
    String assetCode,
    String assetName,
    String status
) {}

// Pattern Matching (instanceof 대신)
if (exception instanceof NotFoundException e) {
    return ResponseEntity.notFound().build();
}

// Sealed Interface (상태 패턴)
public sealed interface AssetStatus permits InUse, Rented, Broken, InStorage, Disposed {}

// Text Blocks (SQL, JSON 등)
String query = """
    SELECT a.asset_id, a.asset_name
    FROM assets a
    WHERE a.status = :status
    """;
```

## Spring Boot 규칙

### 의존성 주입
```java
// GOOD: 생성자 주입 (final + @RequiredArgsConstructor)
@Service
@RequiredArgsConstructor
public class AssetService {
    private final AssetRepository assetRepository;
    private final CategoryRepository categoryRepository;
}

// BAD: 필드 주입 (@Autowired 사용 금지)
@Autowired
private AssetRepository assetRepository;
```

### REST API 설계
```java
@RestController
@RequestMapping("/api/v1/assets")
@RequiredArgsConstructor
public class AssetController {

    // GET    /api/v1/assets          - 목록 조회
    // GET    /api/v1/assets/{id}     - 상세 조회
    // POST   /api/v1/assets          - 등록
    // PUT    /api/v1/assets/{id}     - 수정
    // DELETE /api/v1/assets/{id}     - 삭제
    // PATCH  /api/v1/assets/{id}/status - 상태 변경
}
```

### 응답 형식
```java
// 통일된 API 응답 envelope
public record ApiResponse<T>(
    boolean success,
    T data,
    String message,
    LocalDateTime timestamp
) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, data, null, LocalDateTime.now());
    }

    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, null, message, LocalDateTime.now());
    }
}
```

### Entity 규칙
```java
@Entity
@Table(name = "assets")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Asset extends BaseTimeEntity {
    // Setter 사용 금지 — 비즈니스 메서드로 상태 변경
    // @Builder는 생성 시에만, 정적 팩토리 메서드 권장
}
```

## 금지 사항

- `@Autowired` 필드 주입 금지 → 생성자 주입 사용
- Entity에 `@Setter` 금지 → 비즈니스 메서드로 변경
- 컨트롤러에 비즈니스 로직 금지 → Service 레이어에 위임
- `System.out.println` 금지 → SLF4J Logger 사용
- Raw SQL String concatenation 금지 → JPA Named Parameter 또는 QueryDSL
- `Optional.get()` 직접 호출 금지 → `orElseThrow()` 사용

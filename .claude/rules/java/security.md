# Java / Spring Boot 보안 규칙

## Spring Security + JWT 설정

### JWT 구조
```
Access Token:  유효기간 30분, Authorization 헤더 전송
Refresh Token: 유효기간 7일, HttpOnly Cookie(웹) / Secure Storage(모바일)
```

### 역할 기반 접근 제어
```java
// 역할 정의
public enum Role {
    COUNSELOR,  // 상담사: 장비 조회, 등록, 대여/반납
    MANAGER     // 지점관리자: 전체 기능 + 사용자 관리 + 통계
}

// 컨트롤러에서 역할 제한
@PreAuthorize("hasRole('MANAGER')")
@DeleteMapping("/{id}")
public ResponseEntity<Void> deleteAsset(@PathVariable Long id) { ... }
```

### 필수 보안 체크리스트

- [ ] 모든 API 엔드포인트에 인증 필요 (공개 API 제외)
- [ ] 비밀번호는 BCrypt로 해싱 (strength 10 이상)
- [ ] JWT Secret은 환경변수에서 로드 (`application.yml`에 직접 기재 금지)
- [ ] CORS 설정: 허용 origin 명시 (와일드카드 * 금지)
- [ ] SQL Injection 방지: JPA Named Parameter 필수
- [ ] XSS 방지: 입력값 검증 + 출력 인코딩
- [ ] 민감 정보 로깅 금지 (비밀번호, 토큰 등)

### 환경변수 관리
```yaml
# application.yml — 시크릿은 절대 커밋하지 않음
jwt:
  secret: ${JWT_SECRET}
  access-expiration: 1800000    # 30분
  refresh-expiration: 604800000 # 7일

spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  mail:
    host: ${SMTP_HOST}
    username: ${SMTP_USERNAME}
    password: ${SMTP_PASSWORD}
```

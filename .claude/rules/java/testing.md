# Java / Spring Boot 테스팅 규칙

## 테스트 프레임워크
- **단위 테스트**: JUnit 5 + Mockito
- **통합 테스트**: @SpringBootTest + @Testcontainers (MSSQL)
- **API 테스트**: MockMvc / WebTestClient
- **커버리지**: JaCoCo (최소 80%)

## 테스트 구조

```
backend/src/test/java/com/jobmoa/equipment/
├── service/           # Service 단위 테스트 (Mockito)
├── controller/        # Controller API 테스트 (MockMvc)
├── repository/        # Repository 통합 테스트 (@DataJpaTest)
└── integration/       # 전체 통합 테스트 (@SpringBootTest)
```

## 테스트 네이밍
```java
@DisplayName("장비 등록 시 유효한 카테고리면 성공한다")
@Test
void createAsset_WithValidCategory_ShouldSucceed() {
    // Arrange
    AssetCreateRequest request = new AssetCreateRequest(...);

    // Act
    AssetResponse response = assetService.createAsset(request);

    // Assert
    assertThat(response.assetCode()).isNotNull();
    assertThat(response.status()).isEqualTo("IN_USE");
}
```

## 규칙

- 모든 Service 메서드에 단위 테스트 필수
- Controller 테스트는 인증/인가 시나리오 포함
- Repository 테스트는 커스텀 쿼리에 대해서만
- `@Transactional` 테스트에서 데이터 롤백 확인
- 테스트 데이터는 `@BeforeEach`에서 설정, 하드코딩 최소화

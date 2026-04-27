# Flutter 테스팅 규칙

## 테스트 프레임워크
- **단위 테스트**: flutter_test + mockito / mocktail
- **위젯 테스트**: flutter_test (Widget Test)
- **통합 테스트**: integration_test 패키지
- **커버리지**: 최소 80%

## 테스트 구조
```
mobile/test/
├── features/
│   ├── auth/
│   │   ├── data/        # Repository 단위 테스트
│   │   ├── domain/      # UseCase 단위 테스트
│   │   └── presentation/ # Widget 테스트
│   ├── asset/
│   └── rental/
├── core/
│   ├── network/         # API 클라이언트 테스트
│   └── storage/         # 로컬 DB 테스트
└── shared/
    └── widgets/         # 공유 위젯 테스트

mobile/integration_test/
├── auth_flow_test.dart
├── asset_register_flow_test.dart
└── rental_flow_test.dart
```

## 테스트 네이밍
```dart
group('AssetService', () {
  test('fetchAssets returns list when API call succeeds', () async {
    // Arrange
    when(() => mockApiClient.get(any()))
        .thenAnswer((_) async => Response(data: mockAssetList));

    // Act
    final result = await assetService.fetchAssets();

    // Assert
    expect(result, isA<List<Asset>>());
    expect(result.length, 3);
  });
});
```

## AI 모듈 테스트
- AI 추론 결과는 Mock으로 대체 (실제 모델 로드는 통합 테스트에서만)
- Camera 서비스는 Mock 처리
- Human-in-the-loop UI 흐름은 Widget 테스트로 검증

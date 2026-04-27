# Flutter / Dart 코딩 스타일

> 이 프로젝트: Flutter stable + Dart 3.x + Gemma 4 E2B

## 프로젝트 구조 (Feature-First)

```
mobile/lib/
├── core/                # 공통 인프라
│   ├── config/          # 앱 설정, 환경변수
│   ├── constants/       # 상수, 테마, 색상
│   ├── network/         # HTTP 클라이언트, API 인터셉터
│   ├── storage/         # 로컬 DB (Drift/Isar), Secure Storage
│   ├── router/          # 라우팅 (GoRouter)
│   └── utils/           # 유틸리티 함수
├── features/            # 기능 모듈 (Feature-First)
│   ├── auth/            # 인증 (로그인/로그아웃)
│   │   ├── data/        # Repository 구현, DataSource
│   │   ├── domain/      # Entity, Repository 인터페이스
│   │   └── presentation/ # Screen, Widget, State
│   ├── asset/           # 장비 관리
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── rental/          # 대여 관리
│   ├── ai_register/     # AI 장비 등록 (Gemma 4 E2B)
│   ├── notification/    # 알림
│   └── dashboard/       # 대시보드
├── shared/              # 공유 위젯, 모델
│   ├── widgets/         # 재사용 위젯
│   └── models/          # 공유 데이터 모델
└── main.dart
```

## 네이밍 컨벤션

| 대상 | 규칙 | 예시 |
|------|------|------|
| 파일/디렉토리 | snake_case | `asset_list_screen.dart` |
| 클래스 | PascalCase | `AssetListScreen`, `RentalService` |
| 변수/함수 | camelCase | `assetName`, `fetchAssets()` |
| 상수 | camelCase / lowerCamelCase | `defaultPageSize`, `maxRentalDays` |
| Private | _ 접두사 | `_isLoading`, `_handleSubmit()` |
| Widget | 기능 + Widget 종류 | `AssetCard`, `RentalStatusBadge` |

## Dart 3.x 기능 활용

```dart
// Sealed class (상태 패턴)
sealed class AssetState {}
class AssetLoading extends AssetState {}
class AssetLoaded extends AssetState {
  final List<Asset> assets;
  AssetLoaded(this.assets);
}
class AssetError extends AssetState {
  final String message;
  AssetError(this.message);
}

// Pattern matching
Widget build(BuildContext context) {
  return switch (state) {
    AssetLoading() => const CircularProgressIndicator(),
    AssetLoaded(:final assets) => AssetListView(assets: assets),
    AssetError(:final message) => ErrorWidget(message: message),
  };
}

// Record
(String name, String category) parseAiResult(Map<String, dynamic> json) {
  return (json['name'] as String, json['category'] as String);
}
```

## Widget 규칙

```dart
// GOOD: 작은 위젯으로 분리 (build 메서드 50줄 이하)
class AssetCard extends StatelessWidget {
  final Asset asset;
  const AssetCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildHeader(),
          _buildBody(),
          _buildActions(),
        ],
      ),
    );
  }
}

// BAD: 거대한 build 메서드
```

## 금지 사항

- `print()` 디버그 출력 금지 → `log()` 또는 `debugPrint()` 사용
- 하드코딩 문자열 금지 → constants 또는 l10n 사용
- `setState` 남용 금지 → 상태관리 라이브러리 사용
- 위젯 트리 내 직접 API 호출 금지 → Repository/Service 레이어 분리
- `dynamic` 타입 사용 최소화 → 명시적 타입 지정
- `context` across async gap 금지 → mounted 체크 필수

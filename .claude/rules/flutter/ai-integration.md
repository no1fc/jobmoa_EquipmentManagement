# Flutter AI 통합 규칙 (Gemma 4 E2B)

> 온디바이스 AI 장비 인식 모듈 전용 규칙

## 아키텍처

```
features/ai_register/
├── data/
│   ├── ai_model_service.dart      # Gemma 4 E2B 모델 로드/추론
│   ├── camera_service.dart        # 카메라 제어
│   └── ai_register_repository.dart
├── domain/
│   ├── ai_classification_result.dart  # AI 분류 결과 모델
│   └── ai_register_repository.dart    # 인터페이스
└── presentation/
    ├── ai_register_screen.dart     # 메인 화면
    ├── camera_preview_widget.dart  # 카메라 미리보기
    ├── ai_result_widget.dart       # AI 결과 표시 + Human-in-the-loop
    └── ai_register_state.dart      # 상태 관리
```

## Gemma 4 E2B 통합 규칙

### 모델 관리
```dart
// flutter_gemma 패키지 사용
// 모델 파일은 앱 번들에 포함하거나 최초 실행 시 다운로드

class AiModelService {
  // 앱 시작 시 모델 로드 (백그라운드)
  // 추론 시간: 3초 이내 목표
  // 메모리 사용: 2-3GB (4-bit 양자화)
}
```

### 보안 원칙 (Privacy-First)
- 촬영 이미지는 **절대 외부 서버로 전송하지 않음**
- AI 추론은 **기기 내부에서만** 실행
- 추론 완료 후 원본 이미지는 메모리에서 즉시 해제 (저장 선택은 사용자 결정)
- 서버로는 AI 분류 결과 텍스트 + 메타데이터만 전송

### Human-in-the-loop 흐름
```
1. 카메라 촬영
2. 온디바이스 추론 (Gemma 4 E2B)
3. 결과 표시: 대분류/중분류/소분류 추천 + 신뢰도
4. 사용자 확인/수정 (드롭다운으로 간편 수정)
5. 추가 정보 입력 (위치, 구매일 등)
6. 최종 등록 → API 호출
```

### Fallback 처리
```dart
// 기기 스펙 부족 시 수동 등록으로 전환
Future<bool> checkDeviceCapability() async {
  final availableMemory = await getAvailableMemory();
  if (availableMemory < 2048) { // 2GB 미만
    // AI 기능 비활성화, 수동 등록 화면으로 이동
    return false;
  }
  return true;
}
```

### UI 가이드
- AI 결과에 "AI의 분석 결과는 참고용입니다" 안내 문구 **상시 표시**
- 수정 UI는 드롭다운 메뉴로 **1-2탭 이내** 수정 가능하도록
- 로딩 중 "장비를 분석하고 있습니다..." 애니메이션 표시
- 한 손 조작 고려: 핵심 버튼은 화면 하단 배치

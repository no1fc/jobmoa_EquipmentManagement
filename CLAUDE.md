# 국민취업지원제도 AI 장비 관리 시스템

## 프로젝트 개요
국민취업지원제도 지점 상담사를 위한 AI 기반 장비/자산 관리 시스템 (PC/Mobile).
온디바이스 AI(Gemma 4 E2B)로 장비 촬영 → 자동 분류 → Human-in-the-loop 등록.

## 기술 스택
| 영역 | 기술 | 상세 |
|------|------|------|
| 모바일 | Flutter (Dart) | Gemma 4 E2B, Android 8.0+ (API 26) |
| 웹 | Next.js (TypeScript) | App Router, Tailwind CSS |
| 백엔드 | Spring Boot 3.x | Java 21 LTS, Jakarta EE, Gradle |
| DB | MSSQL (SQL Server) | NVARCHAR, DATETIME2, IDENTITY |
| 인증 | Spring Security + JWT | Access(30분) + Refresh(7일) |
| 알림 | FCM + Spring Mail | 인앱 푸시 + 이메일 |
| 배포 | Ubuntu 24.04 | 온프레미스, Docker 미사용 |

## 프로젝트 구조
```
jobmoa_EquipmentManagement/
├── .claude/             # Claude Code 설정
│   ├── agents/          # 에이전트 정의 (9개)
│   ├── rules/           # 프로젝트 규칙
│   │   ├── java/        # Spring Boot 규칙
│   │   ├── flutter/     # Flutter/Dart 규칙
│   │   ├── nextjs/      # Next.js 규칙
│   │   └── mssql/       # MSSQL 규칙
│   └── commands/        # 커스텀 명령어
├── docs/                # 프로젝트 문서
├── backend/             # Spring Boot API 서버
├── frontend/            # Next.js 웹 클라이언트
└── mobile/              # Flutter 모바일 앱
```

## 빌드/실행 명령어
```bash
# Backend (Spring Boot)
cd backend && ./gradlew bootRun
cd backend && ./gradlew test
cd backend && ./gradlew build

# Frontend (Next.js)
cd frontend && npm install
cd frontend && npm run dev
cd frontend && npm run build
cd frontend && npm test

# Mobile (Flutter)
cd mobile && flutter pub get
cd mobile && flutter run
cd mobile && flutter test
cd mobile && flutter build apk
cd mobile && flutter analyze
```

## 에이전트 사용 가이드

| 상황 | 에이전트 | 호출 방식 |
|------|---------|-----------|
| 새 기능 구현 계획 | `planner` | 복잡한 기능 시작 전 |
| 아키텍처 결정 | `architect` | API 설계, 모듈 분리 결정 시 |
| 새 기능/버그 수정 | `tdd-guide` | 테스트 먼저 작성 |
| 코드 작성 후 | `code-reviewer` | 코드 리뷰 (자동) |
| 보안 관련 코드 | `security-reviewer` | 인증, 입력처리, DB 쿼리 변경 시 |
| 빌드 실패 | `build-error-resolver` | 빌드 에러 진단/수정 |
| API 설계 | `api-designer` | 새 API 엔드포인트 설계 |
| DB 변경 | `db-migrator` | 스키마 변경 SQL + Entity 동기화 |
| 문서 업데이트 | `doc-updater` | 코드 변경 후 docs/ 동기화 |

## 커밋 컨벤션
```
<type>: <description>

Types: feat, fix, refactor, docs, test, chore, perf, ci
```

## 핵심 규칙

### 보안 (Privacy-First)
- AI 촬영 이미지는 **절대 외부 서버로 전송하지 않음** (온디바이스 처리)
- JWT Secret, DB Password 등 시크릿은 **환경변수**에서 로드
- SQL은 반드시 **파라미터 바인딩** 사용 (문자열 결합 금지)
- CORS origin 명시 (와일드카드 * 금지)

### 코딩
- Java: 생성자 주입, Record DTO, @Setter 금지
- Flutter: Feature-First 구조, Sealed class 상태 패턴
- Next.js: Server/Client Component 분리, any 타입 금지
- MSSQL: NVARCHAR (한글), DATETIME2, OFFSET-FETCH 페이지네이션

### 테스트
- TDD 필수 (RED → GREEN → REFACTOR)
- 커버리지 80% 이상
- AAA 패턴 (Arrange-Act-Assert)

## 외부 리소스
- **GitHub**: https://github.com/no1fc/jobmoa_EquipmentManagement
- **Notion**: 프로젝트 관리 페이지 (ID: 34f2af5a-9ceb-8174-8067-c0753266d8fc)

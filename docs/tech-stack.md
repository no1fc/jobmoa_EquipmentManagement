# 기술 스택 (Technology Stack)

> 확정일: 2026-04-27

## 전체 스택 요약

```
┌─────────────────────────────────────────────────────┐
│  Mobile App (Flutter)                               │
│  ┌───────────────────┐                              │
│  │ Gemma 4 E2B (4-bit)│  ← 온디바이스 AI 추론      │
│  └───────────────────┘                              │
├─────────────────────────────────────────────────────┤
│  Web App (Next.js)                                  │
├─────────────────────────────────────────────────────┤
│  REST API (Spring Boot 3.x / Java 21)               │
│  Spring Security + JWT                              │
├─────────────────────────────────────────────────────┤
│  MSSQL (SQL Server)                                 │
├─────────────────────────────────────────────────────┤
│  Ubuntu 24.04 Server (온프레미스)                    │
└─────────────────────────────────────────────────────┘
```

## 상세 기술 선택

### 모바일 — Flutter
| 항목 | 값 |
|------|------|
| 프레임워크 | Flutter (Dart) |
| 최소 Android | API 26 (Android 8.0) |
| AI 통합 | flutter_gemma 패키지 |
| AI 모델 | Gemma 4 E2B, 4-bit 양자화 (~2-3GB RAM) |
| 추론 런타임 | LiteRT-LM / MediaPipe |
| 오프라인 | SQLite (Drift/Isar) 로컬 DB |
| 푸시 알림 | Firebase Cloud Messaging (FCM) |

**선택 이유:** Gemma 4 E2B 온디바이스 통합 사례가 Flutter에서 가장 활발 (flutter_gemma, Reddit FlutterDev 커뮤니티 검증). Android 우선 전략으로 MVP 진행, iOS는 LiteRT-LM Swift API 출시 후 확장.

### 웹 프론트엔드 — Next.js
| 항목 | 값 |
|------|------|
| 프레임워크 | Next.js (React) |
| 언어 | TypeScript |
| 스타일링 | Tailwind CSS (예정) |
| 상태관리 | 추후 결정 (Zustand 유력) |

**선택 이유:** SSR/SSG 지원으로 대시보드 초기 로딩 최적화, React 생태계 활용.

### 백엔드 — Spring Boot
| 항목 | 값 |
|------|------|
| 프레임워크 | Spring Boot 3.x |
| 언어 | Java 21 LTS |
| API | Jakarta EE, RESTful |
| 보안 | Spring Security + JWT |
| ORM | Spring Data JPA (Hibernate) |
| 이메일 | Spring Mail (SMTP) |
| 빌드 | Gradle |

**선택 이유:** 국내 공공기관 프로젝트 표준. Flutter와의 REST API 연동은 프로덕션 검증 완료 (TeneoCast, Emergency108 등). Java 21 LTS는 2031년까지 지원, Virtual Threads 활용 가능.

### DB — MSSQL (SQL Server)
| 항목 | 값 |
|------|------|
| DBMS | Microsoft SQL Server |
| 드라이버 | mssql-jdbc |
| JSON 저장 | NVARCHAR(MAX) + JSON 함수 (SQL Server 2016+) |
| 자동증가 | IDENTITY / SEQUENCE |

**선택 이유:** 기존 인프라에서 MSSQL을 사용 중이므로 운영 일관성 유지.

### 인증 — JWT
| 항목 | 값 |
|------|------|
| 방식 | Stateless JWT (Access + Refresh Token) |
| 역할 | ROLE_COUNSELOR (상담사), ROLE_MANAGER (지점관리자) |
| 저장 | Flutter Secure Storage (모바일), HttpOnly Cookie (웹) |

### 알림
| 채널 | 기술 | 용도 |
|------|------|------|
| 모바일 푸시 | FCM | 반납 예정일, 연체 알림 |
| 이메일 | Spring Mail (SMTP) | 반납 알림, 관리자 리포트 |
| 웹 인앱 | WebSocket / SSE | 대시보드 실시간 알림 |

### 배포 환경
| 항목 | 값 |
|------|------|
| OS | Ubuntu 24.04 LTS |
| 방식 | 직접 서비스 설치 (Docker 미사용) |
| 환경 | 온프레미스 (기존 서버) |
| 기존 시스템 | 국민취업지원제도 웹 프로젝트와 동일 서버, 독립 운영 |

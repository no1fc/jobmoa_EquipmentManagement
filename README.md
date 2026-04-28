# 국민취업지원제도 AI 기반 장비 관리 시스템

국민취업지원제도 지점에서 근무하는 상담사들이 IT 장비, 사무용 가구, 소모품 등을 직관적으로 관리할 수 있도록 돕는 통합 장비/자산 관리 플랫폼입니다.

## 주요 기능

- **AI 장비 등록**: 모바일 카메라로 장비 촬영 시 온디바이스 AI(Gemma 4 E2B)가 장비를 자동 분류
- **장비 관리**: 장비 등록, 조회, 수정, 상태 관리 (사용중/대여중/수리중/고장/폐기)
- **대여 관리**: 장비 대여/반납 처리, 대여 현황 대시보드, 반납 알림, 지점별 대여 현황 달력
- **소모품 관리**: 소모품 등록, 조회, 수정, 수량 관리,
- **사용자 관리**: 사용자 등록, 조회, 수정
- **크로스 플랫폼**: PC 웹 + 모바일 앱 동시 지원

## 기술 스택

| 영역 | 기술 |
|------|------|
| 모바일 | Flutter (Android 8.0+) |
| 웹 | Next.js |
| 백엔드 | Spring Boot 3.x (Java 21) |
| DB | MSSQL (SQL Server) |
| AI | Gemma 4 E2B (4-bit, 온디바이스) |

## 프로젝트 구조

```
├── docs/       # 프로젝트 문서 (기술 스택, 아키텍처, DB 스키마 등)
├── backend/    # Spring Boot API 서버
├── frontend/   # Next.js 웹 클라이언트
├── mobile/     # Flutter 모바일 앱
```

## 문서

- [기술 스택](docs/tech-stack.md)
- [시스템 아키텍처](docs/architecture.md)
- [MVP 범위](docs/mvp-scope.md)
- [DB 스키마](docs/db-schema.md)
- [결정사항 및 누락사항](docs/gaps-and-decisions.md)

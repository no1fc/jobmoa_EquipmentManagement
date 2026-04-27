# 국민취업지원제도 AI 장비 관리 시스템

## 프로젝트 개요
국민취업지원제도 지점 상담사를 위한 AI 기반 장비/자��� 관리 시스템 (PC/Mobile)

## 기술 스택
- **모바일**: Flutter (Dart) — Gemma 4 E2B 온디바이스 AI, Android 8.0+ (API 26)
- **웹**: Next.js (React, TypeScript)
- **백엔드**: Spring Boot 3.x (Java 21 LTS)
- **DB**: MSSQL (SQL Server)
- **인증**: Spring Security + JWT
- **알림**: FCM (모바일 푸시) + Spring Mail (이메일)
- **배포**: Ubuntu 24.04 Server (온프레미스)

## 프로젝트 구조
```
jobmoa_EquipmentManagement/
├── docs/           # 프로젝트 문서
├── backend/        # Spring Boot (추후 생성)
├── frontend/       # Next.js (추후 생성)
├── mobile/         # Flutter (추후 생성)
```

## 코딩 컨벤션
- **Java**: Google Java Style Guide, camelCase
- **TypeScript/React**: ESLint + Prettier, camelCase (변수/함수), PascalCase (컴���넌트)
- **Dart/Flutter**: Effective Dart, camelCase (변수/함수), PascalCase (클래스)
- **SQL**: UPPER_SNAKE_CASE (테이블/컬럼), snake_case (인덱스)

## 빌드/실행 명령어
```bash
# Backend (Spring Boot)
cd backend && ./gradlew bootRun

# Frontend (Next.js)
cd frontend && npm run dev

# Mobile (Flutter)
cd mobile && flutter run
```

## 커밋 컨벤션
`<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci)

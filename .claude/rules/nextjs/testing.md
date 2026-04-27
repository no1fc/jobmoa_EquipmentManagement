# Next.js 테스팅 규칙

## 테스트 프레임워크
- **단위/컴포넌트**: Vitest + React Testing Library
- **E2E**: Playwright
- **커버리지**: 최소 80%

## 테스트 구조
```
frontend/
├── __tests__/
│   ├── components/    # 컴포넌트 단위 테스트
│   ├── hooks/         # 커스텀 훅 테스트
│   ├── lib/           # 유틸리티 테스트
│   └── pages/         # 페이지 통합 테스트
├── e2e/               # Playwright E2E
│   ├── auth.spec.ts
│   ├── assets.spec.ts
│   └── rentals.spec.ts
```

## 컴포넌트 테스트 패턴
```tsx
import { render, screen } from '@testing-library/react';
import { AssetCard } from '@/components/assets/AssetCard';

describe('AssetCard', () => {
  it('displays asset name and status', () => {
    // Arrange
    const asset = { assetId: 1, assetName: '노트북', status: 'IN_USE' };

    // Act
    render(<AssetCard asset={asset} />);

    // Assert
    expect(screen.getByText('노트북')).toBeInTheDocument();
    expect(screen.getByText('사용중')).toBeInTheDocument();
  });
});
```

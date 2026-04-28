import { LoginForm } from '@/components/auth/LoginForm';

export default function LoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/40">
      <div className="w-full max-w-sm space-y-6 rounded-lg border bg-background p-8 shadow-sm">
        <div className="space-y-2 text-center">
          <h1 className="text-2xl font-bold">장비 관리 시스템</h1>
          <p className="text-sm text-muted-foreground">
            국민취업지원제도 장비 관리
          </p>
        </div>
        <LoginForm />
      </div>
    </div>
  );
}

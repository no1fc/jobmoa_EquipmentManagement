'use client';

import { useRef, useMemo, useState } from 'react';
import Image from 'next/image';
import { Button } from '@/components/ui/button';

interface AssetImageUploadProps {
  value: File | null;
  onChange: (file: File | null) => void;
  existingImagePath?: string | null;
}

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const ACCEPTED_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

export function AssetImageUpload({ value, onChange, existingImagePath }: AssetImageUploadProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [error, setError] = useState<string | null>(null);

  const preview = useMemo(() => {
    if (!value) return null;
    return URL.createObjectURL(value);
  }, [value]);

  const displayUrl = preview ?? (existingImagePath && !value ? existingImagePath : null);

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0] ?? null;
    setError(null);

    if (file) {
      if (!ACCEPTED_TYPES.includes(file.type)) {
        setError('JPG, PNG, GIF, WebP 파일만 업로드할 수 있습니다.');
        return;
      }
      if (file.size > MAX_FILE_SIZE) {
        setError('파일 크기는 5MB 이하여야 합니다.');
        return;
      }
    }

    onChange(file);
  }

  function handleRemove() {
    onChange(null);
    setError(null);
    if (inputRef.current) {
      inputRef.current.value = '';
    }
  }

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-2">
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => inputRef.current?.click()}
        >
          <UploadIcon />
          <span className="ml-1.5">이미지 선택</span>
        </Button>
        {(value || existingImagePath) && (
          <Button type="button" variant="ghost" size="sm" onClick={handleRemove}>
            삭제
          </Button>
        )}
      </div>

      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={handleFileChange}
      />

      {error && <p className="text-sm text-destructive">{error}</p>}

      {displayUrl && (
        <div className="relative mt-2 h-48 w-full overflow-hidden rounded-lg border bg-muted">
          <Image
            src={displayUrl}
            alt="장비 이미지 미리보기"
            fill
            className="object-contain"
            unoptimized
          />
        </div>
      )}
    </div>
  );
}

function UploadIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="17 8 12 3 7 8" /><line x1="12" x2="12" y1="3" y2="15" />
    </svg>
  );
}

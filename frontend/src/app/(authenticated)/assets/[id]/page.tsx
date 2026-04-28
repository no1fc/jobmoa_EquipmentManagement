'use client';

import { use, useState } from 'react';
import Link from 'next/link';
import { useAsset } from '@/hooks/useAssets';
import { useAuthStore } from '@/store/authStore';
import { AssetDetailInfo } from '@/components/assets/AssetDetailInfo';
import { StatusChangeDialog } from '@/components/assets/StatusChangeDialog';
import { DeleteConfirmDialog } from '@/components/assets/DeleteConfirmDialog';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';

export default function AssetDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const assetId = Number(id);
  const { data: asset, isLoading } = useAsset(assetId);
  const { user } = useAuthStore();
  const isManager = user?.role === 'MANAGER';

  const [statusDialogOpen, setStatusDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-64" />
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <Skeleton className="h-64" />
          <Skeleton className="h-64" />
        </div>
      </div>
    );
  }

  if (!asset) {
    return (
      <div className="space-y-4">
        <Link href="/assets">
          <Button variant="ghost" size="sm">
            <ArrowLeftIcon />
            <span className="ml-1">목록으로</span>
          </Button>
        </Link>
        <div className="flex h-40 items-center justify-center text-muted-foreground">
          장비를 찾을 수 없습니다.
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* 헤더 */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link href="/assets">
            <Button variant="ghost" size="sm">
              <ArrowLeftIcon />
              <span className="ml-1">목록</span>
            </Button>
          </Link>
          <h1 className="text-2xl font-bold">{asset.assetName}</h1>
        </div>
        <div className="flex gap-2">
          <Link href={`/assets/${assetId}/edit`}>
            <Button variant="outline" size="sm">
              <EditIcon />
              <span className="ml-1">수정</span>
            </Button>
          </Link>
          <Button variant="outline" size="sm" onClick={() => setStatusDialogOpen(true)}>
            <RefreshIcon />
            <span className="ml-1">상태 변경</span>
          </Button>
          {isManager && (
            <Button
              variant="destructive"
              size="sm"
              onClick={() => setDeleteDialogOpen(true)}
            >
              <TrashIcon />
              <span className="ml-1">삭제</span>
            </Button>
          )}
        </div>
      </div>

      {/* 상세 정보 */}
      <AssetDetailInfo asset={asset} />

      {/* 다이얼로그 */}
      <StatusChangeDialog
        open={statusDialogOpen}
        onOpenChange={setStatusDialogOpen}
        assetId={assetId}
        currentStatus={asset.status}
      />
      {isManager && (
        <DeleteConfirmDialog
          open={deleteDialogOpen}
          onOpenChange={setDeleteDialogOpen}
          assetId={assetId}
          assetName={asset.assetName}
        />
      )}
    </div>
  );
}

function ArrowLeftIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="m12 19-7-7 7-7" /><path d="M19 12H5" />
    </svg>
  );
}

function EditIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z" />
    </svg>
  );
}

function RefreshIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8" /><path d="M21 3v5h-5" />
    </svg>
  );
}

function TrashIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" /><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
    </svg>
  );
}

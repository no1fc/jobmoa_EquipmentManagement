import Image from 'next/image';
import type { AssetDetail } from '@/types/asset';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import { AssetStatusBadge } from './AssetStatusBadge';

interface AssetDetailInfoProps {
  asset: AssetDetail;
}

function InfoRow({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
      <span className="min-w-[120px] text-sm font-medium text-muted-foreground">{label}</span>
      <span className="text-sm">{value || '-'}</span>
    </div>
  );
}

function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
}

function RatingDisplay({ rating }: { rating: number | null }) {
  if (rating === null) return <span>-</span>;
  return (
    <span className="text-sm">
      {'★'.repeat(rating)}{'☆'.repeat(5 - rating)} ({rating}/5)
    </span>
  );
}

export function AssetDetailInfo({ asset }: AssetDetailInfoProps) {
  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
      {/* 기본 정보 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">기본 정보</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <InfoRow label="장비코드" value={asset.assetCode} />
          <InfoRow label="장비명" value={asset.assetName} />
          <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
            <span className="min-w-[120px] text-sm font-medium text-muted-foreground">상태</span>
            <AssetStatusBadge status={asset.status} />
          </div>
          <InfoRow
            label="카테고리"
            value={asset.categoryPath?.join(' > ') ?? asset.categoryName}
          />
          <InfoRow label="등록자" value={asset.registeredByName} />
          <InfoRow label="등록일" value={formatDate(asset.createdAt)} />
          <InfoRow label="수정일" value={formatDate(asset.updatedAt)} />
        </CardContent>
      </Card>

      {/* 장비 상세 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">장비 상세</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <InfoRow label="시리얼번호" value={asset.serialNumber} />
          <InfoRow label="제조사" value={asset.manufacturer} />
          <InfoRow label="모델번호" value={asset.modelNumber} />
          <InfoRow label="구매일" value={formatDate(asset.purchaseDate)} />
          <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
            <span className="min-w-[120px] text-sm font-medium text-muted-foreground">상태등급</span>
            <RatingDisplay rating={asset.conditionRating} />
          </div>
        </CardContent>
      </Card>

      {/* 위치 / 부서 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">위치 / 부서</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <InfoRow label="위치" value={asset.location} />
          <InfoRow label="관리부서" value={asset.managingDepartment} />
          <InfoRow label="사용부서" value={asset.usingDepartment} />
        </CardContent>
      </Card>

      {/* 기술사양 / 비고 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">기술사양 / 비고</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          {asset.technicalSpecs && (
            <div>
              <span className="text-sm font-medium text-muted-foreground">기술사양</span>
              <p className="mt-1 whitespace-pre-wrap text-sm">{asset.technicalSpecs}</p>
            </div>
          )}
          {asset.technicalSpecs && asset.notes && <Separator />}
          {asset.notes && (
            <div>
              <span className="text-sm font-medium text-muted-foreground">비고</span>
              <p className="mt-1 whitespace-pre-wrap text-sm">{asset.notes}</p>
            </div>
          )}
          {!asset.technicalSpecs && !asset.notes && (
            <p className="text-sm text-muted-foreground">등록된 정보가 없습니다.</p>
          )}
        </CardContent>
      </Card>

      {/* 이미지 */}
      {asset.imagePath && (
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle className="text-base">이미지</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="relative h-80 w-full">
              <Image
                src={asset.imagePath}
                alt={asset.assetName}
                fill
                className="rounded-lg object-contain"
                unoptimized
              />
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

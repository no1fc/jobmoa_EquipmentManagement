import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/models/asset_detail.dart';
import '../data/models/asset_status.dart';
import 'asset_providers.dart';
import 'widgets/asset_status_badge.dart';

class AssetDetailScreen extends ConsumerWidget {
  final int assetId;

  const AssetDetailScreen({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(assetDetailNotifierProvider(assetId));
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final isManager = user?.isManager ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('장비 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/assets/$assetId/edit'),
          ),
          if (isManager)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: asyncDetail.when(
        data: (detail) => _buildContent(context, ref, detail),
        loading: () => const LoadingIndicator(message: '장비 정보를 불러오는 중...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref
              .read(assetDetailNotifierProvider(assetId).notifier)
              .refresh(),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, AssetDetail detail) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(assetDetailNotifierProvider(assetId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detail.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '${AppConfig.baseUrl}${detail.imagePath}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildBasicInfoCard(context, ref, detail),
            const SizedBox(height: 12),
            _buildDetailCard(detail),
            const SizedBox(height: 12),
            _buildLocationCard(detail),
            if (detail.technicalSpecs != null &&
                detail.technicalSpecs!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildTechSpecsCard(detail),
            ],
            if (detail.notes != null && detail.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNotesCard(detail),
            ],
            const SizedBox(height: 12),
            _buildMetaCard(detail),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(
      BuildContext context, WidgetRef ref, AssetDetail detail) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    detail.assetName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AssetStatusBadge(status: detail.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('장비 코드', detail.assetCode),
            _buildInfoRow(
              '카테고리',
              detail.categoryPath.isNotEmpty
                  ? detail.categoryPath.join(' > ')
                  : detail.categoryName,
            ),
            const SizedBox(height: 8),
            _buildStatusChangeButton(context, ref, detail),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChangeButton(
      BuildContext context, WidgetRef ref, AssetDetail detail) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showStatusChangeDialog(context, ref, detail),
        icon: const Icon(Icons.swap_horiz, size: 18),
        label: const Text('상태 변경'),
      ),
    );
  }

  Widget _buildDetailCard(AssetDetail detail) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '장비 상세',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(),
            if (detail.serialNumber != null)
              _buildInfoRow('시리얼번호', detail.serialNumber!),
            if (detail.manufacturer != null)
              _buildInfoRow('제조사', detail.manufacturer!),
            if (detail.modelNumber != null)
              _buildInfoRow('모델명', detail.modelNumber!),
            if (detail.purchaseDate != null)
              _buildInfoRow('구매일', AppDateUtils.formatDate(detail.purchaseDate)),
            if (detail.conditionRating != null)
              _buildInfoRow(
                '상태등급',
                '${'★' * detail.conditionRating!}${'☆' * (5 - detail.conditionRating!)}',
              ),
            if (detail.aiClassified)
              _buildInfoRow('AI 분류', 'AI가 자동 분류한 장비입니다'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(AssetDetail detail) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '위치 / 부서',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(),
            _buildInfoRow('위치', detail.location ?? '-'),
            _buildInfoRow('관리 부서', detail.managingDepartment ?? '-'),
            _buildInfoRow('사용 부서', detail.usingDepartment ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildTechSpecsCard(AssetDetail detail) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기술 사양',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(),
            Text(
              detail.technicalSpecs!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(AssetDetail detail) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '메모',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(),
            Text(
              detail.notes!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard(AssetDetail detail) {
    return Card(
      elevation: 0,
      color: AppColors.divider,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('등록자', detail.registeredByName),
            _buildInfoRow('등록일', AppDateUtils.formatDateTime(detail.createdAt)),
            _buildInfoRow('수정일', AppDateUtils.formatDateTime(detail.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog(
      BuildContext context, WidgetRef ref, AssetDetail detail) {
    final availableStatuses = AssetStatus.values
        .where((s) => s != detail.status)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('상태 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('현재 상태: ${detail.status.label}'),
            const SizedBox(height: 16),
            ...availableStatuses.map(
              (status) => ListTile(
                title: Text(status.label),
                leading: Icon(Icons.circle, color: status.color, size: 12),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(assetDetailNotifierProvider(assetId).notifier)
                      .updateStatus(status.value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('상태가 ${status.label}(으)로 변경되었습니다.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('장비 삭제'),
        content: const Text('이 장비를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(assetDetailNotifierProvider(assetId).notifier)
                    .deleteAsset();
                ref
                    .read(assetListNotifierProvider.notifier)
                    .removeAssetFromList(assetId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장비가 삭제되었습니다.')),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e')),
                  );
                }
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../data/models/rental.dart';
import '../data/models/rental_status.dart';
import 'rental_providers.dart';
import 'widgets/rental_status_badge.dart';

class RentalDetailScreen extends ConsumerWidget {
  final int rentalId;

  const RentalDetailScreen({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRental = ref.watch(rentalDetailNotifierProvider(rentalId));

    return Scaffold(
      appBar: AppBar(title: const Text('대여 상세')),
      body: asyncRental.when(
        data: (rental) => _buildContent(context, ref, rental),
        loading: () => const LoadingIndicator(message: '대여 정보를 불러오는 중...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref
              .read(rentalDetailNotifierProvider(rentalId).notifier)
              .refresh(),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Rental rental) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(rentalDetailNotifierProvider(rentalId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRentalInfoCard(rental),
            const SizedBox(height: 12),
            _buildAssetInfoCard(rental),
            const SizedBox(height: 12),
            _buildBorrowerCard(rental),
            if (rental.returnCondition != null &&
                rental.returnCondition!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildReturnConditionCard(rental),
            ],
            const SizedBox(height: 12),
            _buildMetaCard(rental),
            const SizedBox(height: 24),
            _buildActionButtons(context, ref, rental),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalInfoCard(Rental rental) {
    final isOverdue =
        rental.status == RentalStatus.overdue || rental.isOverdue;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isOverdue
              ? AppColors.error.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '대여 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                RentalStatusBadge(status: rental.status),
              ],
            ),
            const Divider(),
            _buildInfoRow('대여일', AppDateUtils.formatDate(rental.rentalDate)),
            _buildInfoRow('반납기한', AppDateUtils.formatDate(rental.dueDate)),
            if (rental.returnDate != null)
              _buildInfoRow(
                  '반납일', AppDateUtils.formatDate(rental.returnDate)),
            _buildInfoRow('연장 횟수', '${rental.extensionCount}/1회'),
            if (rental.rentalReason != null && rental.rentalReason!.isNotEmpty)
              _buildInfoRow('대여 사유', rental.rentalReason!),
            if (isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        '${rental.overdueDays}일 연체 중',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetInfoCard(Rental rental) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '장비 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Divider(),
              _buildInfoRow('장비명', rental.assetName),
              _buildInfoRow('장비 코드', rental.assetCode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBorrowerCard(Rental rental) {
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
              '대여자 정보',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(),
            _buildInfoRow('이름', rental.borrowerName),
            _buildInfoRow('이메일', rental.borrowerEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnConditionCard(Rental rental) {
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
              '반납 상태',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(),
            Text(
              rental.returnCondition!,
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

  Widget _buildMetaCard(Rental rental) {
    return Card(
      elevation: 0,
      color: AppColors.divider,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('대여 ID', '#${rental.rentalId}'),
            _buildInfoRow(
                '대여일시', AppDateUtils.formatDateTime(rental.rentalDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, Rental rental) {
    final actions = <Widget>[];

    if (rental.canReturn) {
      actions.add(
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _showReturnDialog(context, ref),
            icon: const Icon(Icons.assignment_return),
            label: const Text('반납'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
          ),
        ),
      );
    }

    if (rental.canExtend) {
      actions.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showExtendDialog(context, ref),
            icon: const Icon(Icons.date_range),
            label: const Text('연장'),
          ),
        ),
      );
    }

    if (rental.canCancel) {
      actions.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showCancelDialog(context, ref),
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            label: const Text('취소',
                style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      children: actions
          .expand((w) => [w, const SizedBox(width: 8)])
          .toList()
        ..removeLast(),
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

  void _showReturnDialog(BuildContext context, WidgetRef ref) {
    final conditionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('반납 처리'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('이 대여 건을 반납 처리하시겠습니까?'),
            const SizedBox(height: 16),
            TextField(
              controller: conditionController,
              decoration: const InputDecoration(
                labelText: '반납 상태 메모 (선택)',
                hintText: '장비 상태를 입력해주세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final updated = await ref
                    .read(rentalDetailNotifierProvider(rentalId).notifier)
                    .returnRental(
                      returnCondition: conditionController.text.isNotEmpty
                          ? conditionController.text
                          : null,
                    );
                ref
                    .read(rentalListNotifierProvider.notifier)
                    .updateRentalInList(updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('반납 처리되었습니다.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('반납 실패: $e')),
                  );
                }
              }
            },
            child: const Text('반납'),
          ),
        ],
      ),
    );
  }

  void _showExtendDialog(BuildContext context, WidgetRef ref) {
    int extensionDays = 7;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('대여 연장'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('연장 일수를 선택해주세요. (최대 14일, 1회 한정)'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: extensionDays > 1
                        ? () =>
                            setDialogState(() => extensionDays--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$extensionDays일',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: extensionDays < 14
                        ? () =>
                            setDialogState(() => extensionDays++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final updated = await ref
                      .read(
                          rentalDetailNotifierProvider(rentalId).notifier)
                      .extendRental(extensionDays);
                  ref
                      .read(rentalListNotifierProvider.notifier)
                      .updateRentalInList(updated);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('$extensionDays일 연장되었습니다.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('연장 실패: $e')),
                    );
                  }
                }
              },
              child: const Text('연장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('대여 취소'),
        content: const Text('이 대여 건을 취소하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final updated = await ref
                    .read(
                        rentalDetailNotifierProvider(rentalId).notifier)
                    .cancelRental();
                ref
                    .read(rentalListNotifierProvider.notifier)
                    .updateRentalInList(updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('대여가 취소되었습니다.')),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('취소 실패: $e')),
                  );
                }
              }
            },
            child: const Text('취소하기'),
          ),
        ],
      ),
    );
  }
}

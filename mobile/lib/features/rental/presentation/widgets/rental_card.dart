import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/models/rental.dart';
import '../../data/models/rental_status.dart';
import 'rental_status_badge.dart';

class RentalCard extends StatelessWidget {
  final Rental rental;
  final VoidCallback? onTap;

  const RentalCard({super.key, required this.rental, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        rental.status == RentalStatus.overdue || rental.isOverdue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isOverdue
              ? AppColors.error.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      color: isOverdue
          ? AppColors.error.withValues(alpha: 0.03)
          : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rental.assetName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RentalStatusBadge(status: rental.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.qr_code, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    rental.assetCode,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rental.borrowerName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${AppDateUtils.formatDate(rental.rentalDate)} ~ ${AppDateUtils.formatDate(rental.dueDate)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (isOverdue) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.warning_amber, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      '${rental.overdueDays}일 연체',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

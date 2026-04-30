import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/rental_status.dart';

class RentalFilterSheet extends StatefulWidget {
  final RentalStatus? currentStatus;
  final ValueChanged<RentalStatus?> onApply;

  const RentalFilterSheet({
    super.key,
    this.currentStatus,
    required this.onApply,
  });

  @override
  State<RentalFilterSheet> createState() => _RentalFilterSheetState();
}

class _RentalFilterSheetState extends State<RentalFilterSheet> {
  late RentalStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '필터',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedStatus = null);
                  },
                  child: const Text('초기화'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '대여 상태',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RentalStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return FilterChip(
                  label: Text(status.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                  selectedColor: status.color.withValues(alpha: 0.2),
                  checkmarkColor: status.color,
                  labelStyle: TextStyle(
                    color: isSelected ? status.color : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_selectedStatus);
                  Navigator.pop(context);
                },
                child: const Text('적용'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

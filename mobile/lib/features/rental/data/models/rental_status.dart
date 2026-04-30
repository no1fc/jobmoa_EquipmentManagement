import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum RentalStatus {
  rented('RENTED', '대여중', AppColors.rentalActive),
  returned('RETURNED', '반납완료', AppColors.rentalReturned),
  overdue('OVERDUE', '연체', AppColors.rentalOverdue),
  cancelled('CANCELLED', '취소', AppColors.rentalCancelled);

  final String value;
  final String label;
  final Color color;

  const RentalStatus(this.value, this.label, this.color);

  static RentalStatus fromValue(String value) {
    return RentalStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RentalStatus.rented,
    );
  }
}

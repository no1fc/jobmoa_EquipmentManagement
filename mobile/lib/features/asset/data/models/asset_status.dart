import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum AssetStatus {
  inUse('IN_USE', '사용중', AppColors.statusInUse),
  rented('RENTED', '대여중', AppColors.statusRented),
  broken('BROKEN', '고장', AppColors.statusBroken),
  inStorage('IN_STORAGE', '보관중', AppColors.statusInStorage),
  disposed('DISPOSED', '폐기', AppColors.statusDisposed);

  final String value;
  final String label;
  final Color color;

  const AssetStatus(this.value, this.label, this.color);

  static AssetStatus fromValue(String value) {
    return AssetStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AssetStatus.inUse,
    );
  }
}

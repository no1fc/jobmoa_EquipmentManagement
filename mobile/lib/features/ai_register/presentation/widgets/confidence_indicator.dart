import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const ConfidenceIndicator({super.key, required this.confidence});

  Color get _color {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  String get _label {
    if (confidence >= 0.8) return '높음';
    if (confidence >= 0.5) return '보통';
    return '낮음';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '신뢰도',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              color: _color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(confidence * 100).toStringAsFixed(0)}% ($_label)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _color,
          ),
        ),
      ],
    );
  }
}

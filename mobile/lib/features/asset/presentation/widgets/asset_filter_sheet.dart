import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/asset_status.dart';
import '../../data/models/category_tree.dart';
import '../asset_providers.dart';

class AssetFilterSheet extends ConsumerStatefulWidget {
  final AssetStatus? currentStatus;
  final int? currentCategoryId;
  final void Function(AssetStatus? status, int? categoryId) onApply;

  const AssetFilterSheet({
    super.key,
    this.currentStatus,
    this.currentCategoryId,
    required this.onApply,
  });

  @override
  ConsumerState<AssetFilterSheet> createState() => _AssetFilterSheetState();
}

class _AssetFilterSheetState extends ConsumerState<AssetFilterSheet> {
  AssetStatus? _selectedStatus;
  int? _selectedLevel1;
  int? _selectedLevel2;
  int? _selectedLevel3;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    final categoryTreeAsync = ref.watch(categoryTreeProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '필터',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                    _selectedLevel1 = null;
                    _selectedLevel2 = null;
                    _selectedLevel3 = null;
                  });
                },
                child: const Text('초기화'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '상태',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildStatusChip(null, '전체'),
              for (final status in AssetStatus.values)
                _buildStatusChip(status, status.label),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '카테고리',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          categoryTreeAsync.when(
            data: (tree) => _buildCategorySelectors(tree),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, _) => const Text('카테고리를 불러올 수 없습니다.'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final categoryId =
                    _selectedLevel3 ?? _selectedLevel2 ?? _selectedLevel1;
                widget.onApply(_selectedStatus, categoryId);
                Navigator.pop(context);
              },
              child: const Text('적용'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AssetStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = status),
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontSize: 13,
      ),
    );
  }

  Widget _buildCategorySelectors(List<CategoryTree> tree) {
    final level2Items = tree
        .where((c) => c.categoryId == _selectedLevel1)
        .expand((c) => c.children)
        .toList();
    final level3Items = level2Items
        .where((c) => c.categoryId == _selectedLevel2)
        .expand((c) => c.children)
        .toList();

    return Column(
      children: [
        _buildDropdown(
          label: '대분류',
          value: _selectedLevel1,
          items: tree,
          onChanged: (val) => setState(() {
            _selectedLevel1 = val;
            _selectedLevel2 = null;
            _selectedLevel3 = null;
          }),
        ),
        if (_selectedLevel1 != null && level2Items.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDropdown(
            label: '중분류',
            value: _selectedLevel2,
            items: level2Items,
            onChanged: (val) => setState(() {
              _selectedLevel2 = val;
              _selectedLevel3 = null;
            }),
          ),
        ],
        if (_selectedLevel2 != null && level3Items.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDropdown(
            label: '소분류',
            value: _selectedLevel3,
            items: level3Items,
            onChanged: (val) => setState(() => _selectedLevel3 = val),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<CategoryTree> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('전체')),
        ...items.map((c) => DropdownMenuItem(
              value: c.categoryId,
              child: Text(c.categoryName),
            )),
      ],
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/category_tree.dart';
import '../asset_providers.dart';

class CategoryPicker extends ConsumerStatefulWidget {
  final int? initialCategoryId;
  final ValueChanged<int?> onChanged;

  const CategoryPicker({
    super.key,
    this.initialCategoryId,
    required this.onChanged,
  });

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  int? _selectedLevel1;
  int? _selectedLevel2;
  int? _selectedLevel3;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final categoryTreeAsync = ref.watch(categoryTreeProvider);

    return categoryTreeAsync.when(
      data: (tree) {
        if (!_initialized && widget.initialCategoryId != null) {
          _initializeFromCategoryId(tree, widget.initialCategoryId!);
          _initialized = true;
        }

        final level2Items = tree
            .where((c) => c.categoryId == _selectedLevel1)
            .expand((c) => c.children)
            .toList();
        final level3Items = level2Items
            .where((c) => c.categoryId == _selectedLevel2)
            .expand((c) => c.children)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(
              label: '대분류 *',
              value: _selectedLevel1,
              items: tree,
              onChanged: (val) {
                setState(() {
                  _selectedLevel1 = val;
                  _selectedLevel2 = null;
                  _selectedLevel3 = null;
                });
                _emitValue();
              },
            ),
            if (_selectedLevel1 != null && level2Items.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDropdown(
                label: '중분류',
                value: _selectedLevel2,
                items: level2Items,
                onChanged: (val) {
                  setState(() {
                    _selectedLevel2 = val;
                    _selectedLevel3 = null;
                  });
                  _emitValue();
                },
              ),
            ],
            if (_selectedLevel2 != null && level3Items.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDropdown(
                label: '소분류',
                value: _selectedLevel3,
                items: level3Items,
                onChanged: (val) {
                  setState(() => _selectedLevel3 = val);
                  _emitValue();
                },
              ),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => const Text(
        '카테고리를 불러올 수 없습니다.',
        style: TextStyle(color: AppColors.error),
      ),
    );
  }

  void _emitValue() {
    final value = _selectedLevel3 ?? _selectedLevel2 ?? _selectedLevel1;
    widget.onChanged(value);
  }

  void _initializeFromCategoryId(List<CategoryTree> tree, int categoryId) {
    for (final l1 in tree) {
      if (l1.categoryId == categoryId) {
        _selectedLevel1 = categoryId;
        return;
      }
      for (final l2 in l1.children) {
        if (l2.categoryId == categoryId) {
          _selectedLevel1 = l1.categoryId;
          _selectedLevel2 = categoryId;
          return;
        }
        for (final l3 in l2.children) {
          if (l3.categoryId == categoryId) {
            _selectedLevel1 = l1.categoryId;
            _selectedLevel2 = l2.categoryId;
            _selectedLevel3 = categoryId;
            return;
          }
        }
      }
    }
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
      items: items
          .map((c) => DropdownMenuItem(
                value: c.categoryId,
                child: Text(c.categoryName),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

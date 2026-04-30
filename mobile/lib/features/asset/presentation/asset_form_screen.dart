import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../data/models/asset_create_request.dart';
import '../data/models/asset_update_request.dart';
import 'asset_providers.dart';
import 'widgets/asset_image_section.dart';
import 'widgets/category_picker.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  final int? assetId;

  const AssetFormScreen({super.key, this.assetId});

  bool get isEditMode => assetId != null;

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serialController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _locationController = TextEditingController();
  final _managingDeptController = TextEditingController();
  final _usingDeptController = TextEditingController();
  final _techSpecsController = TextEditingController();
  final _notesController = TextEditingController();

  int? _categoryId;
  DateTime? _purchaseDate;
  int _conditionRating = 5;
  bool _aiClassified = false;
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _dataLoaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _locationController.dispose();
    _managingDeptController.dispose();
    _usingDeptController.dispose();
    _techSpecsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditMode && !_dataLoaded) {
      final detailAsync =
          ref.watch(assetDetailNotifierProvider(widget.assetId!));
      return Scaffold(
        appBar: AppBar(title: const Text('장비 수정')),
        body: detailAsync.when(
          data: (detail) {
            _populateForm(detail);
            return _buildForm();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('오류: $e')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? '장비 수정' : '장비 등록'),
      ),
      body: _buildForm(),
    );
  }

  void _populateForm(dynamic detail) {
    if (_dataLoaded) return;
    _nameController.text = detail.assetName;
    _serialController.text = detail.serialNumber ?? '';
    _manufacturerController.text = detail.manufacturer ?? '';
    _modelController.text = detail.modelNumber ?? '';
    _locationController.text = detail.location ?? '';
    _managingDeptController.text = detail.managingDepartment ?? '';
    _usingDeptController.text = detail.usingDepartment ?? '';
    _techSpecsController.text = detail.technicalSpecs ?? '';
    _notesController.text = detail.notes ?? '';
    _categoryId = detail.categoryId;
    _purchaseDate = detail.purchaseDate;
    _conditionRating = detail.conditionRating ?? 5;
    _aiClassified = detail.aiClassified;
    _dataLoaded = true;
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AssetImageSection(
              existingImagePath:
                  widget.isEditMode ? _getExistingImagePath() : null,
              selectedImage: _selectedImage,
              onImageChanged: (file) =>
                  setState(() => _selectedImage = file),
            ),
            const SizedBox(height: 20),
            const Text(
              '카테고리',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            CategoryPicker(
              initialCategoryId: _categoryId,
              onChanged: (id) => _categoryId = id,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '장비명 *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => Validators.required(v, '장비명'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: '시리얼번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _manufacturerController,
                    decoration: const InputDecoration(
                      labelText: '제조사',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: '모델명',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDatePicker(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '위치',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _managingDeptController,
                    decoration: const InputDecoration(
                      labelText: '관리 부서',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _usingDeptController,
                    decoration: const InputDecoration(
                      labelText: '사용 부서',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildConditionRating(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _techSpecsController,
              decoration: const InputDecoration(
                labelText: '기술 사양',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            if (!widget.isEditMode) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('AI 분류'),
                subtitle: const Text('AI가 자동 분류한 장비입니다'),
                value: _aiClassified,
                onChanged: (v) => setState(() => _aiClassified = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isEditMode ? '수정' : '등록'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _purchaseDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _purchaseDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '구매일',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          _purchaseDate != null
              ? '${_purchaseDate!.year}-${_purchaseDate!.month.toString().padLeft(2, '0')}-${_purchaseDate!.day.toString().padLeft(2, '0')}'
              : '',
          style: TextStyle(
            color: _purchaseDate != null
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildConditionRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상태등급',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (i) {
            final rating = i + 1;
            return IconButton(
              onPressed: () => setState(() => _conditionRating = rating),
              icon: Icon(
                rating <= _conditionRating ? Icons.star : Icons.star_border,
                color: rating <= _conditionRating
                    ? AppColors.warning
                    : AppColors.textMuted,
                size: 28,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            );
          }),
        ),
      ],
    );
  }

  String? _getExistingImagePath() {
    if (!widget.isEditMode) return null;
    final detail =
        ref.read(assetDetailNotifierProvider(widget.assetId!)).valueOrNull;
    return detail?.imagePath;
  }

  String? _nonEmpty(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(assetRepositoryProvider);
      final purchaseDateStr = _purchaseDate != null
          ? '${_purchaseDate!.year}-${_purchaseDate!.month.toString().padLeft(2, '0')}-${_purchaseDate!.day.toString().padLeft(2, '0')}'
          : null;

      if (widget.isEditMode) {
        final request = AssetUpdateRequest(
          categoryId: _categoryId!,
          assetName: _nameController.text.trim(),
          serialNumber: _nonEmpty(_serialController.text),
          manufacturer: _nonEmpty(_manufacturerController.text),
          modelNumber: _nonEmpty(_modelController.text),
          purchaseDate: purchaseDateStr,
          location: _nonEmpty(_locationController.text),
          managingDepartment: _nonEmpty(_managingDeptController.text),
          usingDepartment: _nonEmpty(_usingDeptController.text),
          conditionRating: _conditionRating,
          technicalSpecs: _nonEmpty(_techSpecsController.text),
          notes: _nonEmpty(_notesController.text),
        );
        await repo.updateAsset(widget.assetId!, request, image: _selectedImage);
      } else {
        final request = AssetCreateRequest(
          categoryId: _categoryId!,
          assetName: _nameController.text.trim(),
          serialNumber: _nonEmpty(_serialController.text),
          manufacturer: _nonEmpty(_manufacturerController.text),
          modelNumber: _nonEmpty(_modelController.text),
          purchaseDate: purchaseDateStr,
          location: _nonEmpty(_locationController.text),
          managingDepartment: _nonEmpty(_managingDeptController.text),
          usingDepartment: _nonEmpty(_usingDeptController.text),
          conditionRating: _conditionRating,
          technicalSpecs: _nonEmpty(_techSpecsController.text),
          aiClassified: _aiClassified,
          notes: _nonEmpty(_notesController.text),
        );
        await repo.createAsset(request, image: _selectedImage);
      }

      ref.invalidate(assetListNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode ? '장비가 수정되었습니다.' : '장비가 등록되었습니다.',
            ),
          ),
        );
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../data/models/rental_create_request.dart';
import 'rental_providers.dart';

class RentalCreateScreen extends ConsumerStatefulWidget {
  const RentalCreateScreen({super.key});

  @override
  ConsumerState<RentalCreateScreen> createState() =>
      _RentalCreateScreenState();
}

class _RentalCreateScreenState extends ConsumerState<RentalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assetIdController = TextEditingController();
  final _borrowerNameController = TextEditingController();
  final _rentalReasonController = TextEditingController();
  int _dueDays = 7;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _assetIdController.dispose();
    _borrowerNameController.dispose();
    _rentalReasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final request = RentalCreateRequest(
        assetId: int.parse(_assetIdController.text),
        borrowerName: _borrowerNameController.text.isNotEmpty
            ? _borrowerNameController.text
            : null,
        rentalReason: _rentalReasonController.text.isNotEmpty
            ? _rentalReasonController.text
            : null,
        dueDays: _dueDays,
      );

      await ref.read(rentalRepositoryProvider).createRental(request);
      ref.invalidate(rentalListNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대여가 등록되었습니다.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('대여 등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 대여 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _assetIdController,
                decoration: const InputDecoration(
                  labelText: '장비 ID *',
                  hintText: '대여할 장비의 ID를 입력하세요',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.required(value, '장비 ID'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _borrowerNameController,
                decoration: const InputDecoration(
                  labelText: '대여자명',
                  hintText: '대여자 이름 (미입력 시 본인)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rentalReasonController,
                decoration: const InputDecoration(
                  labelText: '대여 사유',
                  hintText: '대여 사유를 입력하세요',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              const Text(
                '대여 기간',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _dueDays > 1
                                ? () => setState(() => _dueDays--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_dueDays일',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _dueDays < 30
                                ? () => setState(() => _dueDays++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _dueDays.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '$_dueDays일',
                        onChanged: (v) =>
                            setState(() => _dueDays = v.round()),
                      ),
                      const Text(
                        '1일 ~ 30일',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                      : const Text('대여 등록'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

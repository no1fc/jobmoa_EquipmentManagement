import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'ai_register_providers.dart';
import 'ai_register_state.dart';
import 'widgets/ai_result_widget.dart';

class AiRegisterScreen extends ConsumerStatefulWidget {
  const AiRegisterScreen({super.key});

  @override
  ConsumerState<AiRegisterScreen> createState() => _AiRegisterScreenState();
}

class _AiRegisterScreenState extends ConsumerState<AiRegisterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiRegisterNotifierProvider.notifier).checkModelAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiRegisterNotifierProvider);
    final notifier = ref.read(aiRegisterNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 장비 등록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            notifier.reset();
            context.pop();
          },
        ),
      ),
      body: switch (state) {
        AiRegisterInitial() => _InitialView(
            onCamera: notifier.captureFromCamera,
            onGallery: notifier.pickFromGallery,
          ),
        AiRegisterCapturing() =>
          const LoadingIndicator(message: '카메라 준비 중...'),
        AiRegisterAnalyzing() => const _AnalyzingView(),
        AiRegisterResultReady(:final imageBytes, :final result) =>
          AiResultWidget(
            imageBytes: imageBytes,
            result: result,
            onConfirm: () {
              notifier.confirmResult();
              // AssetFormScreen으로 이동하며 AI 결과 전달
              context.pushNamed(
                'asset-create',
                extra: {
                  'aiResult': result,
                  'imageBytes': imageBytes,
                },
              );
            },
            onRetake: notifier.retake,
          ),
        AiRegisterEditing() => const SizedBox.shrink(),
        AiRegisterSubmitting() =>
          const LoadingIndicator(message: '등록 중...'),
        AiRegisterSuccess() => _SuccessView(
            onDone: () {
              notifier.reset();
              context.pop();
            },
          ),
        AiRegisterError(:final message) => _ErrorView(
            message: message,
            onRetry: notifier.retake,
          ),
        AiRegisterModelUnavailable() => _ModelUnavailableView(
            onManual: () => context.pushNamed('asset-new'),
          ),
      },
    );
  }
}

class _InitialView extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _InitialView({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 72,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'AI 장비 인식',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '장비를 촬영하면 AI가 자동으로\n카테고리와 장비명을 분류합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  '이미지는 기기 내에서만 처리됩니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: onCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('카메라로 촬영'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('갤러리에서 선택'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            '장비를 분석하고 있습니다...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AI가 장비 종류와 카테고리를 판별하고 있습니다',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;

  const _SuccessView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 72, color: AppColors.success),
          const SizedBox(height: 16),
          const Text(
            '장비 등록 완료',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onDone,
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelUnavailableView extends StatelessWidget {
  final VoidCallback onManual;

  const _ModelUnavailableView({required this.onManual});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.memory, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            const Text(
              '이 기기에서는 AI 분석을\n사용할 수 없습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI 분석을 위해 최소 2GB의 메모리가 필요합니다.\n수동으로 장비를 등록할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onManual,
              icon: const Icon(Icons.edit),
              label: const Text('수동 등록으로 진행'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

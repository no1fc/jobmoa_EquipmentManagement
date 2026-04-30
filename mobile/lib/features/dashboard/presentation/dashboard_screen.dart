import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../asset/presentation/asset_providers.dart';
import '../../rental/presentation/rental_providers.dart';
import 'widgets/overdue_rentals_section.dart';
import 'widgets/quick_actions.dart';
import 'widgets/stat_cards.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(rentalDashboardProvider);
    final overdueAsync = ref.watch(overdueRentalsProvider);
    final summaryAsync = ref.watch(assetSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outlined),
            tooltip: '내 프로필',
            onPressed: () => context.pushNamed('profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(rentalDashboardProvider);
          ref.invalidate(overdueRentalsProvider);
          ref.invalidate(assetSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 장비 현황 요약
            summaryAsync.when(
              data: (summary) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '장비 현황',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '전체 ${summary.total}대 (사용중 ${summary.inUse} | 대여중 ${summary.rented} | 보관중 ${summary.inStorage})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            // 대여 통계 카드
            dashboardAsync.when(
              data: (dashboard) => StatCards(
                totalActive: dashboard.totalActive,
                overdueCount: dashboard.overdueCount,
                dueSoon: dashboard.dueSoon,
                returnedToday: dashboard.returnedToday,
              ),
              loading: () => const StatCardsLoading(),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('통계를 불러올 수 없습니다: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 연체 대여 목록
            overdueAsync.when(
              data: (rentals) =>
                  OverdueRentalsSection(rentals: rentals),
              loading: () => const OverdueRentalsSectionLoading(),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('연체 목록을 불러올 수 없습니다: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 빠른 메뉴
            const QuickActions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

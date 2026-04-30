class RentalDashboard {
  final int totalActive;
  final int overdueCount;
  final int dueSoon;
  final int returnedToday;

  const RentalDashboard({
    required this.totalActive,
    required this.overdueCount,
    required this.dueSoon,
    required this.returnedToday,
  });

  factory RentalDashboard.fromJson(Map<String, dynamic> json) {
    return RentalDashboard(
      totalActive: json['totalActive'] as int,
      overdueCount: json['overdueCount'] as int,
      dueSoon: json['dueSoon'] as int,
      returnedToday: json['returnedToday'] as int,
    );
  }
}

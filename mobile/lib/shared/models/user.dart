enum UserRole {
  counselor('COUNSELOR', '상담사'),
  manager('MANAGER', '관리자');

  final String value;
  final String label;
  const UserRole(this.value, this.label);

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.counselor,
    );
  }
}

class User {
  final int userId;
  final String email;
  final String name;
  final UserRole role;
  final String? branchName;
  final String? phone;
  final bool isActive;

  const User({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    this.branchName,
    this.phone,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromValue(json['role'] as String),
      branchName: json['branchName'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  bool get isManager => role == UserRole.manager;
}
class ProfileUpdateRequest {
  final String name;
  final String? phone;

  const ProfileUpdateRequest({required this.name, this.phone});

  Map<String, dynamic> toJson() => {
        'name': name,
        if (phone != null) 'phone': phone,
      };
}

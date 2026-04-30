class AssetStatusRequest {
  final String status;

  const AssetStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}

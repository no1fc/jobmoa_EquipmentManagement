class RentalReturnRequest {
  final String? returnCondition;

  const RentalReturnRequest({this.returnCondition});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (returnCondition != null) json['returnCondition'] = returnCondition;
    return json;
  }
}

class MemberInfo {
  final String name;
  final String phoneNumber;
  final String address;

  MemberInfo(
      {required this.name,
      required this.phoneNumber,
      required this.address});

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
        name: json['name'],
        phoneNumber: json['phoneNumber'],
        address: json['phoneNumber']);
  }
}

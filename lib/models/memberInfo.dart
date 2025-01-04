class MemberInfo {
  final int id;
  final String name;
  final String phoneNumber;
  final String address;

  MemberInfo(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.address});

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
        id: json['memberId'],
        name: json['name'],
        phoneNumber: json['phoneNumber'],
        address: json['address']);
  }
}

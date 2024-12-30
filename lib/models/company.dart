class Company {
  final String companyName;
  final String address;
  String? phoneNumber;
  final String lat;
  final String lot;
  double? distance;

  Company(
      {required this.companyName,
      required this.address,
      this.phoneNumber,
      required this.lat,
      required this.lot,
      this.distance});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyName: json['wasteCompanyName'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      lat: json['lat'],
      lot: json['lot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'address': address,
      'phoneNumber': phoneNumber,
      'lat': lat,
      'lot': lot,
    };
  }
}

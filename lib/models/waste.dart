class Waste {
  final int wasteId;
  final String wasteName;
  final List<String> wasteSortingInfo;

  Waste({
    required this.wasteId,
    required this.wasteName,
    required this.wasteSortingInfo,
  });

  factory Waste.fromJson(Map<String, dynamic> json) {
    List<String> wasteInfoList = json['wasteSortingInfo']
        .toString()
        .split('/')
        .map((e) => e.trim()) // 앞뒤 공백 제거
        .toList();

    return Waste(
      wasteId: json['wasteId'],
      wasteName: json['wasteName'],
      wasteSortingInfo: wasteInfoList,
    );
  }
}

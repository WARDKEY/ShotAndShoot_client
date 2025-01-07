class Prediction {
  final String category;
  final int count;
  final List<String> wasteSortingInfo;

  Prediction({
    required this.category,
    required this.count,
    required this.wasteSortingInfo,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    List<String> wasteInfoList = json['wasteSortingInfo']
        .toString()
        .split('/')
        .map((e) => e.trim()) // 앞뒤 공백 제거
        .toList();

    return Prediction(
      category: json['category'],
      count: json['count'],
      wasteSortingInfo: wasteInfoList,
    );
  }
}

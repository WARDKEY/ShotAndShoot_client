import 'package:shotandshoot/models/prediction.dart';

class ScanInfo {
  final List<Prediction> predictions;
  final String imgUrl;

  ScanInfo({
    required this.predictions,
    required this.imgUrl,
  });

  factory ScanInfo.fromJson(Map<String, dynamic> json) {
    var predictionsList = (json['predictions'] as List)
        .map((item) => Prediction.fromJson(item))
        .toList();

    return ScanInfo(
      predictions: predictionsList,
      imgUrl: json['imgUrl'],
    );
  }
}

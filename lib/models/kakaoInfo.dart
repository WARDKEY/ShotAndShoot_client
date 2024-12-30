class KakaoInfo {
  final int kakaoId;
  final String nickName;

  KakaoInfo({
    required this.kakaoId,
    required this.nickName,
  });

  factory KakaoInfo.fromJson(Map<String, dynamic> json) {
    return KakaoInfo(kakaoId: json['kakaoId'], nickName: json['nickName']);
  }

  Map<String, dynamic> toJson() {
    return {
      'kakaoId': kakaoId,
      'nickName': nickName,
    };
  }

}

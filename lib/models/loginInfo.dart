class LoginInfo {
  final String loginId;
  final String nickName;

  LoginInfo({
    required this.loginId,
    required this.nickName,
  });

  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return LoginInfo(loginId: json['loginId'], nickName: json['nickName']);
  }

  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'nickName': nickName,
    };
  }

}

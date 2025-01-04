import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    return accessToken != null;
  }

  // 로그아웃
  Future<void> logOut() async {
    await _secureStorage.delete(key: 'accessToken');
  }
}

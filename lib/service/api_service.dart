import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shotandshoot/service/token_service.dart';
import '../models/company.dart';
import '../models/memberInfo.dart';

class ApiService {
  final TokenService tokenService = TokenService();
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<Company>> fetchCompanies() async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/wasteCompany/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);

        final data = jsonDecode(decodedBody);
        final List<dynamic> wasteCompanyData = data['wasteCompany'];

        return wasteCompanyData
            .map((companyJson) => Company.fromJson(companyJson))
            .toList();
      } else {
        throw Exception('Failed to load companies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<http.Response> fetchMypageData() async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/member/');
    String? accessToken = await _secureStorage.read(key: 'accessToken');

    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }

  // 카카오 로그인 정보 서버로 보내는 용도
  static Future<bool> postKakaoInfo(String loginId, dynamic nickName) async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/member/kakaoLogin');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'loginId': loginId,
          'nickName': nickName,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        String? accessToken = response.headers['authorization'];

        if (accessToken != null && accessToken.startsWith('Bearer ')) {
          accessToken = accessToken.substring(7); // "Bearer " 제거

          await _secureStorage.write(key: 'accessToken', value: accessToken);
          return true; //로그인 성공
        }
        return false; //로그인 실패, 토큰발급 필요
      } else if (response.statusCode == 201) {
        return false; //로그인 실패, 회원가입 필요
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to post KakaoInfo');
      }
    } catch (e) {
      print('HTTP POST 에러: $e');
      throw Exception('Error: $e');
    }
  }

//   구글 로그인 정보 서버로 보내는 용도
  static Future<bool> postGoogleInfo(String loginId, dynamic nickName) async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/member/googleLogin');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'loginId': loginId,
          'nickName': nickName,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        String? accessToken = response.headers['authorization'];

        if (accessToken != null && accessToken.startsWith('Bearer ')) {
          accessToken = accessToken.substring(7); // "Bearer " 제거

          await _secureStorage.write(key: 'accessToken', value: accessToken);
          return true; //로그인 성공
        }
        return false; //로그인 실패, 토큰발급 필요
      } else if (response.statusCode == 201) {
        return false; //로그인 실패, 회원가입 필요
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to post KakaoInfo');
      }
    } catch (e) {
      print('HTTP POST 에러: $e');
      throw Exception('Error: $e');
    }
  }

//  회원가입 정보 전달
  static Future<MemberInfo> postUserInfo(
      String id, String name, String phoneNumber, String address) async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/member/register');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': id,
          'name': name,
          'phoneNumber': phoneNumber,
          'address': address,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return MemberInfo.fromJson(jsonDecode(response.body));
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to post MemberInfo');
      }
    } catch (e) {
      print('HTTP POST 에러: $e');
      throw Exception('Error: $e');
    }
  }

  Future<http.Response> logout() async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/member/logout');
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    return http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  Future<http.Response> deleteAccount() async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/member/unregister');
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    return http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}

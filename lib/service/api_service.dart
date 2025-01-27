import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shotandshoot/models/comment.dart';
import 'package:shotandshoot/service/token_service.dart';
import '../models/company.dart';
import '../models/memberInfo.dart';
import '../models/question.dart';

class ApiService {
  final TokenService tokenService = TokenService();
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<String> getLocation(String lat, String lot) async {
    final url = Uri.parse(
        "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?request=coordsToaddr&coords=${lot},${lat}&sourcecrs=epsg:4326&output=json");
    Map<String, String> headers = {
      "X-NCP-APIGW-API-KEY-ID": dotenv.get('CLIENT_KEY'),
      "X-NCP-APIGW-API-KEY": dotenv.get('CLIENT_SECRET'),
    };

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        String jsonData = response.body;

        var mydo =
            jsonDecode(jsonData)["results"][1]['region']['area1']['name'];
        var mysi =
            jsonDecode(jsonData)["results"][1]['region']['area2']['name'];
        var mydong =
            jsonDecode(jsonData)["results"][1]['region']['area3']['name'];

        String doSiDong = mydo + " " + mysi + " " + mydong;
        return doSiDong;
      } else {
        throw Exception("주소를 찾지 못했습니다.");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Company>> fetchCompanies(String location) async {
    String ip = dotenv.get('IP');
    final url = Uri.http(ip, '/api/v1/wasteCompany/', {'location': location});
    String? accessToken = await _secureStorage.read(key: 'accessToken');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

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

    if (accessToken == null) {
      throw Exception('토큰없음');
    }
    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.StreamedResponse> postWasteImage(File file) async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/scan/');
    var request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
    ));

    return await request.send();
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

  // questionId에 해당하는 질문 가져오기
  static Future<Question> getQuestion(
    int questionId,
  ) async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/question/$questionId');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8', // 요거랑
        },
      );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)); // 요거 안 넣으면 한글 깨짐
        final question = Question.fromJson(data);
        return question;
      } else {
        throw Exception("질문을 찾지 못했습니다.");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // 질문 작성
  static Future<Question> postQuestion(
      String title, String content, String category) async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/question/');
    String? accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'content': content,
          'category': category,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Question.fromJson(jsonDecode(response.body));
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to post question');
      }
    } catch (e) {
      print('HTTP POST 에러: $e');
      throw Exception('Error: $e');
    }
  }
}

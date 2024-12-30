import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shotandshoot/models/kakaoInfo.dart';
import '../models/company.dart';

class ApiService {
  Future<List<Company>> fetchCompanies() async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/wasteCompany/');

    try {
      final response = await http.get(url);

      // 요청 성공 시
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

  Future<KakaoInfo> postKakaoInfo(int kakaoId, dynamic nickName) async {
    String ip = dotenv.get('IP');
    final url = Uri.parse('http://$ip/api/v1/member/kakaoLogin');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'kakaoId': kakaoId,
          'nickName': nickName,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return KakaoInfo.fromJson(jsonDecode(response.body));
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to post KakaoInfo');
      }
    } catch (e) {
      print('HTTP POST 에러: $e');
      throw Exception('Error: $e');
    }
  }
}

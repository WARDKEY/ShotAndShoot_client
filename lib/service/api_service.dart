import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/company.dart';

class ApiService {
  Future<List<Company>> fetchCompanies() async {
    final url = Uri.parse('http://172.30.1.100:8080/api/v1/wasteCompany/');

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
}

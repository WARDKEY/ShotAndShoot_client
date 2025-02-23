import 'package:flutter/material.dart';
import 'package:shotandshoot/service/api_service.dart';

class WasteDetail extends StatefulWidget {
  final String wasteName;

  const WasteDetail({super.key, required this.wasteName});

  @override
  State<WasteDetail> createState() => _WasteDetailState();
}

class _WasteDetailState extends State<WasteDetail> {
  final List<String> _categories = [
    '종이',
    '고철',
    '유리',
    '캔',
    '플라스틱',
    '스티로폼',
    '비닐',
    '의류',
  ];
  late String _selectedCategory;
  Map<String, dynamic>? wasteInfo;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.wasteName;
    _fetchWasteData(_selectedCategory);
  }

  // 서버에서 쓰레기 정보 가져오기
  Future<void> _fetchWasteData(String wasteName) async {
    final response = await ApiService.getWasteInfo(wasteName);
    print('불러온 결과 =========== $response');
    setState(() {
      wasteInfo = response; // 가져온 데이터로 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                    wasteInfo = null; // 새로운 데이터를 불러올 동안 로딩 상태
                  });
                  _fetchWasteData(newValue); // 새 카테고리에 대한 데이터 가져오기
                }
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, size: 30),
              padding: EdgeInsets.zero,
              dropdownColor: Colors.white,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              wasteInfo == null
                  ? const CircularProgressIndicator() // 데이터 로딩
                  : Text(
                      '분리수거 방법: ${wasteInfo!['wasteSortingInfo'] ?? '정보 없음'}',
                      style: const TextStyle(fontSize: 18),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shotandshoot/models/waste.dart';
import 'package:shotandshoot/service/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

  Waste? wasteInfo;

  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.wasteName;
    _fetchWasteData(_selectedCategory);
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'yYQCHZbrgB4', // 유튜브 아이디 지정
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
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
    double cardWidth = MediaQuery.of(context).size.width - 32; // 카드 너비

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
                    wasteInfo = null;
                  });
                  _fetchWasteData(newValue);
                }
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                );
              }).toList(),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, size: 30),
            ),
          ],
        ),
      ),
      body: wasteInfo == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  wasteInfo!.wasteSortingInfo.isEmpty
                      ? const Center(
                          child: Text('정보 없음', style: TextStyle(fontSize: 18)))
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: wasteInfo!.wasteSortingInfo.length,
                          itemBuilder: (context, index) {
                            return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                  side: const BorderSide(
                                    color: Color(0xffe0e0e0), // 연한 회색 테두리
                                    width: 1, // 테두리 두께
                                  ),
                                ),
                                color: Color(0xfffdfdfd),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: ListTile(
                                  title: Column(
                                    children: [
                                      Text(
                                        wasteInfo!.wasteSortingInfo[index]
                                            .split(':')[0], // 전자 (타이틀)
                                        style: const TextStyle(fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                      const Divider(thickness: 1), // 구분선
                                      Text(
                                        wasteInfo!.wasteSortingInfo[index]
                                            .split(':')[1], // 후자 (내용)
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        ),
                  const SizedBox(height: 23),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: YoutubePlayer(
                        controller: _youtubeController,
                        showVideoProgressIndicator: true,
                        aspectRatio: 16 / 9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

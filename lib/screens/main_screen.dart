import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:shotandshoot/utils/question_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/company.dart';
import '../models/question.dart';
import '../provider/app_state_provider.dart';
import '../service/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  final List<Map<String, dynamic>> gridItems = [
    {'image': 'images/paper.png', 'name': '종이류'},
    {'image': 'images/metal.png', 'name': '고철'},
    {'image': 'images/glass.png', 'name': '유리병'},
    {'image': 'images/can.png', 'name': '캔'},
    {'image': 'images/plastic.png', 'name': '플라스틱'},
    {'image': 'images/styrofoam.png', 'name': '스티로품'},
    {'image': 'images/vinyl.png', 'name': '비닐류'},
    {'image': 'images/clothes.png', 'name': '의류'},
  ];

  List<Question> posts = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<Company?> fetchCompany() async {
    try {
      final companyData = await _apiService.fetchCompany();
      final company = companyData['company'] as Company;
      var latLng =
          NLatLng(companyData['point']['lat'], companyData['point']['lot']);
      try {
        double companyLat = double.parse(company.lat);
        double companyLot = double.parse(company.lot);

        var distance = latLng.distanceTo(NLatLng(companyLat, companyLot));
        company.distance = distance; // 계산된 거리 할당
      } catch (e) {
        print("거리 계산 오류: $e");
        company.distance = 0.0;
      }
      print(
          '${companyData['point']['lat']} ${companyData['point']['lot']} ${company.lat} ${company.lot}}');
      return company;
    } catch (e) {
      return null;
    }
  }

  Future<void> _launchPhone(String? phoneNumber) async {
    final phoneUrl = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(phoneUrl))) {
      await launchUrl(Uri.parse(phoneUrl));
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }

  void refresh() {
    ApiService.fetchPopularPosts().then((value) {
      print("인기 질문들 $value");
      setState(() {
        posts = value.take(5).toList(); // 리스트에서 최대 5개만 저장
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          title: Image.asset(
            "images/sas_logo.png",
            width: 55,
          ),
          //backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                height: 280,
                child: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network("https://picsum.photos/600/400"),
                    );
                  },
                  //autoplay: true,
                  itemCount: 3,
                  pagination: SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    builder: DotSwiperPaginationBuilder(
                      activeColor: Color(0xff748d6f),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '폐기물은 ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        children: [
                          TextSpan(
                            text: '어떻게?',
                            style: TextStyle(color: Color(0xff748d6f)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      iconSize: 30,
                      onPressed: () {
                        print("폐기물 분리배출페이지 이동");
                      },
                    ),
                  ],
                ),
              ),
              Container(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  children: gridItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        print(item['name']);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            item['image'],
                            height: 50,
                          ),
                          const SizedBox(height: 7),
                          Text(item['name'] as String),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '폐기물은 ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        children: [
                          TextSpan(
                            text: '어디에?',
                            style: TextStyle(color: Color(0xff748d6f)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      iconSize: 30,
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false)
                            .onItemTapped(3);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: 170,
                ),
                width: double.infinity,
                child: Card(
                  color: Color(0xfff9f9f9),
                  margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 1,
                  child: FutureBuilder<Company?>(
                    future: fetchCompany(), // 데이터를 가져오는 Future
                    builder: (BuildContext context,
                        AsyncSnapshot<Company?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // 로딩 중 상태
                        return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xff748d6f))));
                      } else if (snapshot.hasError) {
                        // 에러 상태
                        return Center(child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
                      } else if (snapshot.hasData && snapshot.data != null) {
                        // 데이터가 로드된 상태
                        final _company = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _company.companyName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 7),
                              Text(
                                _company.address ?? "주소 정보 없음",
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                "${_company.distance?.toStringAsFixed(0)} m",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xffac2323)),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: _company.phoneNumber != ""
                                        ? Color(0xff748d6f)
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_company.phoneNumber != "") {
                                      _launchPhone(_company.phoneNumber);
                                    }
                                  },
                                  child: Text('업체 호출하기'),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 데이터가 없을 때
                        return Center(child: Text("회사 정보를 찾을 수 없습니다."));
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '인기 질문🔥',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    // 인기 질문 새로고침
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 30,
                      ),
                      onPressed: refresh,
                    ),
                  ],
                ),
              ),
              QuestionList(
                posts: posts,
                onRefresh: refresh,
                selectedFilters: [],
              ),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.fromLTRB(15, 0, 15, 45),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.grey, // 테두리 색상
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // 모서리 둥글게
                    ),
                  ),
                  onPressed: () {
                    Provider.of<AppState>(context, listen: false)
                        .onItemTapped(1);
                  },
                  child: Text('더보기 >'),
                ),
              )
            ],
          ),
        ));
  }
}

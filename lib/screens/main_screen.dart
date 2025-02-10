import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shotandshoot/utils/post_list.dart';
import 'package:shotandshoot/utils/question_list.dart';

import '../models/question.dart';
import '../provider/app_state_provider.dart';
import '../service/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Map<String, dynamic>> gridItems = [
    {'icon': Icons.receipt, 'name': '종이류'},
    {'icon': Icons.receipt, 'name': '고철'},
    {'icon': Icons.receipt, 'name': '유리병'},
    {'icon': Icons.receipt, 'name': '캔'},
    {'icon': Icons.receipt, 'name': '플라스틱'},
    {'icon': Icons.receipt, 'name': '스티로품'},
    {'icon': Icons.receipt, 'name': '비닐류'},
    {'icon': Icons.receipt, 'name': '의류'},
  ];



  List<Question> posts = [];

  @override
  void initState() {
    super.initState();
    refresh();
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
                    Icon(
                      Icons.chevron_right,
                      size: 30,
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
                          Icon(item['icon'] as IconData, size: 40),
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
                    Icon(
                      Icons.chevron_right,
                      size: 30,
                    ),
                  ],
                ),
              ),
              Container(
                  width: double.infinity,
                  child: Card(
                    color: Color(0xfff9f9f9),
                    margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 1,
                    // 그림자 효과
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '임의의 분리수거 대행업체',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 7),
                          Text(
                            '경기도 양평균 용문면 연수로 209',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '130m',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xffac2323)),
                          ),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xff748d6f),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(4), // 모서리 둥글게
                                  ),
                                ),
                                onPressed: () {
                                  print("ElevatedButton clicked");
                                },
                                child: Text('업체 호출하기'),
                              ))
                        ],
                      ),
                    ),
                  )),
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

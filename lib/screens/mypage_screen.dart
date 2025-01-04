import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shotandshoot/models/memberInfo.dart';
import 'package:shotandshoot/screens/login_screen.dart';
import 'package:shotandshoot/screens/signin_screen.dart';
import 'package:shotandshoot/screens/user_edit.dart';

import '../service/api_service.dart';
import '../utils/post_list.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  late TabController _tabController;
  late MemberInfo? _member;
  bool isLoggedIn = false;

  Future<void> fetchMypageData({int retryCount = 0}) async {
    try {
      final response = await _apiService.fetchMypageData();

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);

        setState(() {
          _member = MemberInfo.fromJson(data);
          isLoggedIn = true; // 로그인 상태로 설정
        });
      } else if (response.statusCode == 401) {
        String? accessToken = response.headers['authorization'];

        if (accessToken != null && accessToken.startsWith('Bearer ')) {
          accessToken = accessToken.substring(7);

          await _secureStorage.write(key: 'accessToken', value: accessToken);
          await fetchMypageData(retryCount: retryCount + 1);
        } else {
          await _secureStorage.delete(key: 'accessToken');
          setState(() {
            _member = null;
            isLoggedIn = false;
          });
          print('Unauthorized');
        }
      } else {
        print('Failed to fetch member data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<Map<String, dynamic>> posts = [
    {
      'id': 1,
      'category': '플라스틱',
      'title': '게시물 1',
      'content': '게시물 내용ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ',
      'nickname': '홍길동',
      'createdAt': '12:00',
      'views': 100,
      'comments': 3
    },
    {
      'id': 2,
      'category': '유리',
      'title': '게시물 2',
      'content': '게시물 내용 2',
      'nickname': '닉네임 2',
      'createdAt': '12/20',
      'views': 200,
      'comments': 0
    },
    // 더 많은 게시물 추가 가능
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 두 개의 탭
    fetchMypageData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("마이페이지"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          isLoggedIn
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => UserEdit()))
                        .then((value) => fetchMypageData());
                  },
                  child: Container(
                    width: double.infinity, // 화면을 꽉 채우도록 설정
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_member?.name} 님",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.grey,
                          size: 27,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  width: double.infinity, // 화면 너비를 꽉 채움
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // 여백 추가
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6), // 모서리 둥글게
                              ),
                              side: BorderSide(width: 1, color: Colors.black)),
                          child: Text(
                            "로그인",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SigninScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff748d6f),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6), // 모서리 둥글게
                            ),
                          ),
                          child: Text(
                            "회원가입",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
          Material(
            color: Colors.white,
            elevation: 2, // 탭바 아래 그림자 효과
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xff748d6f),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xff748d6f),
              // 강조선 색상
              indicatorWeight: 4.0,
              // 강조선 두께
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: "작성한 글"),
                Tab(text: "작성한 댓글"),
              ],
            ),
          ),
          // 탭별 콘텐츠
          Expanded(
              child: Container(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    PostList(
                      posts: posts,
                    ),
                  ],
                ),
                ListView.builder(
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("댓글 #$index"),
                    );
                  },
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

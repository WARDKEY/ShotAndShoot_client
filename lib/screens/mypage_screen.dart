import 'package:flutter/material.dart';
import 'package:shotandshoot/screens/login_screen.dart';
import 'package:shotandshoot/screens/signin_screen.dart';
import 'package:shotandshoot/screens/user_edit.dart';

import '../utils/post_list.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoggedIn = true;

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserEdit()),
                    );
                  },
                  child: Container(
                    width: double.infinity, // 화면을 꽉 채우도록 설정
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "홍길동 님",
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

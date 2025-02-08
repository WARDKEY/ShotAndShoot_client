import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shotandshoot/models/memberInfo.dart';
import 'package:shotandshoot/screens/login_screen.dart';
import 'package:shotandshoot/screens/signin_screen.dart';
import 'package:shotandshoot/screens/user_edit.dart';

import '../models/comment.dart';
import '../models/question.dart';
import '../service/api_service.dart';
import '../utils/question_list.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({Key? key}) : super(key: key);

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  late TabController _tabController;
  Future<MemberInfo?>? _futureMember;
  late Future<List<Question>> _futureMyPosts;
  late Future<List<Comment>> _futureMyComments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _futureMember = fetchMember();
    _futureMyPosts = fetchMyPosts();
    _futureMyComments = fetchMyComments();
  }

  Future<MemberInfo?> fetchMember({int retryCount = 0}) async {
    try {
      final response = await _apiService.fetchMypageData();

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        return MemberInfo.fromJson(data);
      } else if (response.statusCode == 401) {
        String? accessToken = response.headers['authorization'];
        if (accessToken != null && accessToken.startsWith('Bearer ')) {
          accessToken = accessToken.substring(7);
          await _secureStorage.write(key: 'accessToken', value: accessToken);
          // 재시도
          return await fetchMember(retryCount: retryCount + 1);
        } else {
          await _secureStorage.delete(key: 'accessToken');
          print('Unauthorized');
          return null;
        }
      } else {
        print('Failed to fetch member data');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // 사용자가 작성한 질문 조회
  Future<List<Question>> fetchMyPosts() {
    return _apiService.fetchMyPosts();
  }

  // 사용자가 작성한 댓글 조회
  Future<List<Comment>> fetchMyComments() {
    return _apiService.fetchMyComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("마이페이지", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // 상단 사용자 정보를 위한 FutureBuilder
      body: FutureBuilder<MemberInfo?>(
        future: _futureMember,
        builder: (context, memberSnapshot) {
          // 사용자 정보 로딩 중
          if (memberSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 에러 발생 시
          if (memberSnapshot.hasError) {
            return Center(child: Text('Error: ${memberSnapshot.error}'));
          }
          // 사용자 정보 로드 후, 전체 화면 구성
          return Column(
            children: [
              // 로그인 상태에 따라 사용자 정보 또는 로그인/회원가입 버튼 표시
              memberSnapshot.hasData && memberSnapshot.data != null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserEdit()),
                        ).then((_) {
                          // 돌아왔을 때 사용자 정보를 다시 불러옴
                          setState(() {
                            _futureMember = fetchMember();
                          });
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${memberSnapshot.data!.name} 님",
                              style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.grey,
                              size: 27,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                ).then((_) {
                                  setState(() {
                                    _futureMember = fetchMember();
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  side: const BorderSide(
                                      width: 1, color: Colors.black)),
                              child: const Text(
                                "로그인",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SigninScreen()),
                                ).then((_) {
                                  setState(() {
                                    _futureMember = fetchMember();
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff748d6f),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                "회원가입",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              // 탭바 영역
              Material(
                color: Colors.white,
                elevation: 2,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xff748d6f),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xff748d6f),
                  indicatorWeight: 4.0,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: "작성한 글"),
                    Tab(text: "작성한 댓글"),
                  ],
                ),
              ),
              // TabBarView 영역
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // 첫 번째 탭: 사용자가 작성한 글에 대한 FutureBuilder
                      FutureBuilder<List<Question>>(
                        future: _futureMyPosts,
                        builder: (context, postsSnapshot) {
                          if (postsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (postsSnapshot.hasError) {
                            return Center(
                                child: Text('로그인 또는 회원가입을 해주세요.'));
                          }
                          if (!postsSnapshot.hasData ||
                              postsSnapshot.data!.isEmpty) {
                            return const Center(child: Text('작성한 글이 없습니다.'));
                          }
                          return QuestionList(
                            posts: postsSnapshot.data!,
                            onRefresh: () {
                              setState(() {
                                _futureMyPosts = fetchMyPosts();
                              });
                            },
                          );
                        },
                      ),
                      // 댓글 영역
                      FutureBuilder<List<Comment>>(
                        future: _futureMyComments,
                        builder: (context, commentsSnapshot) {
                          if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (commentsSnapshot.hasError) {
                            return const Center(child: Text('로그인 또는 회원가입을 해주세요.'));
                          }
                          if (!commentsSnapshot.hasData || commentsSnapshot.data!.isEmpty) {
                            return const Center(child: Text('작성한 댓글이 없습니다.'));
                          }
                          return ListView.builder(
                            itemCount: commentsSnapshot.data!.length,
                            itemBuilder: (context, index) {
                              final comment = commentsSnapshot.data![index]; // Comment 객체 가져오기
                              return ListTile(
                                title: Text(comment.content), // Comment 내용 표시
                                subtitle: Text(comment.createdAt.toString()),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

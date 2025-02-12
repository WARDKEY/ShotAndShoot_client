import 'package:flutter/material.dart';
import 'package:shotandshoot/models/question.dart';
import 'package:shotandshoot/screens/post_write.dart';
import 'package:shotandshoot/service/api_service.dart';
import 'package:shotandshoot/utils/post_filter.dart';
import 'package:shotandshoot/utils/post_search.dart';

import '../utils/question_list.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, bool> _filters = {
    "플라스틱": false,
    "유리": false,
    "박스": false,
    "캔": false,
  };

  // 필터
  List<String> selectedFilters = [];

  // 검색
  List<Question> filteredPosts = [];

  // 전체글
  List<Question> posts = [];

  // 인기글
  List<Question> popularPosts = [];

  void _applyFilters(Map<String, bool> filters) {
    setState(() {
      selectedFilters = filters.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      _filters = filters;
    });

    // 선택된 필터를 출력
    print("선택된 필터: $selectedFilters");
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 두 개의 탭

    refresh();
    popularRefresh();
  }

  void refresh() {
    ApiService.fetchPosts().then((value) {
      print("전체 질문들 $value");
      setState(() {
        posts = value;
        filteredPosts = value;
      });
    });
  }

  void popularRefresh() {
    ApiService.fetchPopularPosts().then((value) {
      print("인기 질문들 $value");
      setState(() {
        popularPosts = value.toList();
      });
    });
  }

  // 검색
  void _searchPosts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPosts = posts;
      });
    } else {
      setState(() {
        filteredPosts = posts
            .where((post) =>
                post.title.toLowerCase().contains(query.toLowerCase()) ||
                post.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void navigateToPostWrite() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostWrite(
          onRefresh: refresh,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text("게시판"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 탭바
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
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "전체글"),
                Tab(text: "인기글"),
              ],
            ),
          ),

          // 탭별 콘텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    PostSearch(
                      onChanged: (value) {
                        print('검색어: $value');
                        _searchPosts(value);
                      },
                    ),
                    Row(
                      children: [
                        PostFilter(filters: _filters, onApply: _applyFilters),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, // 가로로 스크롤
                            child: Row(
                              children: selectedFilters.map((filter) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  // 필터 간 간격 추가
                                  child: Chip(
                                    label: Text(filter),
                                    side: BorderSide(
                                        width: 1.0, color: Color(0xff748d6f)),
                                    labelStyle:
                                        TextStyle(color: Color(0xff748d6f)),
                                    backgroundColor: Colors.white,
                                    deleteIcon: Icon(Icons.clear),
                                    onDeleted: () {
                                      setState(() {
                                        selectedFilters.remove(filter);
                                        _filters[filter] = false;
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    QuestionList(
                      posts: filteredPosts,
                      onRefresh: refresh,
                    ),
                  ],
                ),

                // 인기글 탭 콘텐츠
                // ListView.builder(
                //   itemCount: 30,
                //   itemBuilder: (context, index) {
                //     return ListTile(
                //       title: Text("인기글 게시글 #$index"),
                //     );
                //   },
                // ),
                QuestionList(posts: popularPosts, onRefresh: popularRefresh)
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 버튼 클릭 시의 동작

          navigateToPostWrite();
        },
        backgroundColor: Color(0xff748d6f),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

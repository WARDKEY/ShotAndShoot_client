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
    "종이": false,
    "고철": false,
    "유리": false,
    "캔": false,
    "플라스틱": false,
    "스티로폼": false,
    "비닐": false,
    "의류": false,
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

  Future<void> refresh() async {
    final postData = await ApiService.fetchPosts();

    setState(() {
      posts = postData;
      filteredPosts = postData;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text("게시판"),
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
              labelColor: const Color(0xff748d6f),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xff748d6f),
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

          // 검색창과 필터: 고정
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
                          side: const BorderSide(
                              width: 1.0, color: Color(0xff748d6f)),
                          labelStyle: const TextStyle(color: Color(0xff748d6f)),
                          backgroundColor: Colors.white,
                          deleteIcon: const Icon(Icons.clear),
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

          // 탭별 콘텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 전체글
                SingleChildScrollView(
                  child: QuestionList(
                    posts: filteredPosts,
                    onRefresh: refresh,
                    selectedFilters: selectedFilters,
                  ),
                ),
                // 인기글
                SingleChildScrollView(
                  child: QuestionList(
                    posts: popularPosts,
                    onRefresh: popularRefresh,
                    selectedFilters: selectedFilters,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostWrite(),
            ),
          );
          if (result == true) {
            await Future.delayed(const Duration(milliseconds: 200));
            await refresh();
          }
        },
        backgroundColor: const Color(0xff748d6f),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

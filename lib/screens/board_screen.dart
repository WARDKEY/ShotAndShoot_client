import 'package:flutter/material.dart';
import 'package:shotandshoot/utils/post_filter.dart';
import 'package:shotandshoot/utils/post_list.dart';
import 'package:shotandshoot/utils/post_search.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, bool> _filters = {
    "플라스틱": false,
    "유리": false,
    "박스": false,
    "캔": false,
  };

  List<String> selectedFilters = [];

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
              indicatorColor: Color(0xff748d6f), // 강조선 색상
              indicatorWeight: 4.0, // 강조선 두께
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
                    PostSearch(onChanged: (value) {print('검색어: $value');},),
                    Row(
                      children: [
                        PostFilter(filters: _filters, onApply: _applyFilters),

                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, // 가로로 스크롤
                            child: Row(
                              children: selectedFilters.map((filter) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0), // 필터 간 간격 추가
                                  child: Chip(
                                    label: Text(filter),
                                    side: BorderSide(width: 1.0, color: Color(0xff748d6f)),
                                    labelStyle: TextStyle(color: Color(0xff748d6f)),
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
                    PostList(posts: posts,),
                  ],
                ),

                // 인기글 탭 콘텐츠
                ListView.builder(
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("인기글 게시글 #$index"),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 버튼 클릭 시의 동작
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("글쓰기 버튼 클릭됨")),
          );
        },
        backgroundColor: Color(0xff748d6f),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

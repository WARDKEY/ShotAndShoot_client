import 'package:flutter/material.dart';
import 'package:shotandshoot/models/question.dart';
import '../screens/post_detail.dart';

class QuestionList extends StatelessWidget {
  final List<Question> posts;
  final VoidCallback onRefresh; // BoardScreen에서 전달한 콜백
  final List<String> selectedFilters; // 선택된 필터 목록 추가

  const QuestionList({
    super.key,
    required this.posts,
    required this.onRefresh,
    required this.selectedFilters, // 선택된 필터 목록 초기화
  });

  // 필터링된 게시글 목록을 반환하는 함수
  List<Question> get _filteredPosts {
    if (selectedFilters.isEmpty) {
      return posts; // 필터가 선택되지 않았으면 모든 게시글 반환
    } else {
      return posts.where((post) {
        // 각 게시글의 카테고리가 선택된 필터에 포함되는지 확인
        return selectedFilters.contains(post.category);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 필터링된 게시글 목록 사용
    List<Question> displayPosts = _filteredPosts;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 7),
      child: Column(
        children: displayPosts.map((post) { // _filteredPosts로 변경
          bool isLastPost = displayPosts.indexOf(post) == displayPosts.length - 1; // displayPosts로 변경
          return GestureDetector(
            onTap: () {
              // 게시글 클릭 시 상세 화면으로 이동 후, 복귀하면 onRefresh 호출
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetail(
                    questionId: post.questionId,
                  ),
                ),
              ).then((value) => onRefresh());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // 게시글 내용
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, 5, 3),
                  child: Text(
                    post.content,
                    style: const TextStyle(fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 5, 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(post.member!,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                          const SizedBox(width: 10),
                          Text(post.createAt!,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                      Row(
                        children: [
                          if (post.view! > 0)
                            Text('🕶️ ${post.view}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          if (post.comments > 0) ...[
                            const SizedBox(width: 10),
                            Text('🗨️ ${post.comments}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLastPost)
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
              ],
            ),
          );
        }).toList(), // displayPosts.map의 toList() 호출
      ),
    );
  }
}
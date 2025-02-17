import 'package:flutter/material.dart';
import 'package:shotandshoot/models/question.dart';
import '../screens/post_detail.dart';
// 카테고리별 색상 설정
final Map<String, Color> _categoryColors = {
  '종이': Colors.brown,
  '고철': Colors.grey,
  '유리': Colors.blue,
  '캔': Colors.green,
  '플라스틱': Colors.orange,
  '스티로폼': Colors.purple,
  '비닐': Colors.pink,
  '의류': Colors.red,
  '기타': Colors.black,
};

class QuestionList extends StatelessWidget {
  final List<Question> posts;
  final VoidCallback onRefresh;
  final List<String> selectedFilters;

  const QuestionList({
    super.key,
    required this.posts,
    required this.onRefresh,
    required this.selectedFilters,
  });

  List<Question> get _filteredPosts {
    if (selectedFilters.isEmpty) {
      return posts;
    } else {
      return posts.where((post) {
        return selectedFilters.contains(post.category);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Question> displayPosts = _filteredPosts;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 7),
      child: Column(
        children: displayPosts.map((post) {
          bool isLastPost =
              displayPosts.indexOf(post) == displayPosts.length - 1;
          String category = post.category;
          Color categoryColor = _categoryColors[category] ?? Colors.black;

          return GestureDetector(
            onTap: () {
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
                    // 카테고리 박스
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      margin: const EdgeInsets.only(bottom: 5, right: 10),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        border: Border.all(color: categoryColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // 게시글 제목
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
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
        }).toList(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shotandshoot/models/question.dart';
import '../screens/post_detail.dart';

class QuestionList extends StatelessWidget {
  final List<Question> posts;
  final VoidCallback onRefresh; // BoardScreen에서 전달한 콜백

  const QuestionList({
    super.key,
    required this.posts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 7),
      child: Column(
        children: posts.map((post) {
          bool isLastPost = posts.indexOf(post) == posts.length - 1;
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
                // 게시글 제목
                Text(
                  "[${post.category!}] ${post.title!}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // 게시글 내용
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(post.member!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 10),
                        Text(post.createAt!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
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
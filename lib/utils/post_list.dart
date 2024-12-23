import 'package:flutter/material.dart';
import '../screens/post_detail.dart';

class PostList extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  const PostList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 7),
      child: Column(
        children: posts.map((post) {
          bool isLastPost = posts.indexOf(post) == posts.length - 1;

          return GestureDetector(
            onTap: () {
              // 게시글 클릭 시 상세 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetail(
                    postId: post['id']!.toString(),
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 게시글 제목
                Text(
                  "["+post['category']!+"] "+post['title']!,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // 게시글 내용
                Text(
                  post['content']!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(post['nickname']!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 10),
                        Text(post['createdAt']!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        if (post['views']! > 0)
                          Text('🕶️ ${post['views']}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        if (post['comments']! > 0) ...[
                          const SizedBox(width: 10),
                          Text('🗨️ ${post['comments']}',
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
                    indent: 0,
                    endIndent: 0,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

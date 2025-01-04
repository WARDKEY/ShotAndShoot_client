import 'package:flutter/material.dart';

class PostDetail extends StatelessWidget {
  final String postId;

  const PostDetail({super.key, required this.postId});

  // 백 연결, 게시글,댓글 연동

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '게시판',
          style: TextStyle(color: Colors.black),
        ),
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 및 카테고리
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '유리', // 카테고리
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    // 게시글 내용
                    '이거 깨졌는데 어캄?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // 사이즈 넘어가면 ...처리
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('철수', style: TextStyle(color: Colors.grey)),
                // 작성자
                SizedBox(width: 10),
                Text('작성: 10:19', style: TextStyle(color: Colors.grey)),
                // 작성 시간
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('13', style: TextStyle(color: Colors.grey)), // 조회수
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            // 본문 내용
            Text(
              '밥 먹다 떨궜는데 어카냐 하.. 누가 대신 버려 줬으면 좋겠다.', // 게시글 내용
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            // AI 코멘트
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 코멘트',
                    style: TextStyle(
                      color: Color(0xff748d6f),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    '빗자루로 유리 쓸어서 신문지에 감싸 버리삼',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            // 댓글 섹션
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                  ),
                  Text(
                    '댓글 2개',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Expanded(
                    child: ListView(
                      children: [
                        Comments(
                            author: '영희', time: '11:32', content: '착하게 살아야지'),
                        Comments(author: '훈이', time: '11:11', content: 'ㅋㅋ'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 댓글 입력 필드
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    '등록',
                    style: TextStyle(
                      color: Color(0xff748d6f),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 댓글
class Comments extends StatelessWidget {
  final String author;
  final String time;
  final String content;

  const Comments({
    super.key,
    required this.author,
    required this.time,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text(time, style: TextStyle(color: Colors.grey)),
            SizedBox(width: 8),
            Expanded(child: Text(content)),
            IconButton(
                // 댓글 삭제
                onPressed: () {
                  print('댓글 삭제 완료');
                },
                icon: Icon(Icons.delete, size: 16, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

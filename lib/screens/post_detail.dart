import 'package:flutter/material.dart';
import 'package:shotandshoot/models/question.dart';
import 'package:shotandshoot/service/api_service.dart';

class PostDetail extends StatelessWidget {
  final int questionId;

  const PostDetail({
    Key? key,
    required this.questionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FutureBuilder 위젯을 사용해 API 결과를 가져옴
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '게시판',
          style: TextStyle(color: Colors.black),
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Question>(
        future: ApiService.getQuestion(questionId), // 비동기 호출
        builder: (context, snapshot) {
          // 연결 상태 분기 처리
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 아직 로딩 중
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 에러 발생
            return Center(child: Text('에러: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            // 데이터가 없는 경우
            return const Center(child: Text('데이터가 없습니다.'));
          }

          // 여기까지 오면 snapshot.data가 존재 (Question 객체)
          final question = snapshot.data!;

          print(question.content);

          return _buildBody(context, question);
        },
      ),
    );
  }

  /// 실제 UI를 그리는 부분을 함수로 분리
  Widget _buildBody(BuildContext context, Question question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 및 카테고리
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  question.category, // question.category
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.title, // question.title
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                question.member, // question.member
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 10),
              const Text(
                '작성: ',
                style: TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${question.view}', // question.view
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 본문 내용
          Text(
            question.content, // question.content
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          // AI 코멘트
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AI 코멘트',
                  style: TextStyle(
                    color: Color(0xff748d6f),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '빗자루로 유리 쓸어서 신문지에 감싸 버리삼',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 댓글 섹션
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                  ),
                ),
                const Text(
                  '댓글 2개',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView(
                    children: const [
                      Comments(
                        author: '영희',
                        time: '11:32',
                        content: '착하게 살아야지dddddddddddddddddddddddddddddddddddd',
                      ),
                      Comments(
                        author: '훈이',
                        time: '11:11',
                        content: 'ㅋㅋ',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 댓글 입력 필드
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '댓글을 입력하세요',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // 댓글 등록 로직
                },
                child: const Text(
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
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      author,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  // 댓글 삭제
                  onPressed: () {
                    print('댓글 삭제 완료');
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 16,
                    color: Color(0xffac2323),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
              child: Text(content),
            ),
            SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shotandshoot/models/comment.dart';
import 'package:shotandshoot/models/question.dart';
import 'package:shotandshoot/service/api_service.dart';
import 'package:shotandshoot/service/token_service.dart';

import '../models/AiComments.dart';
import '../utils/comment_item.dart';

final Map<String, Color> _categoryColors = {
  '종이': Color(0xff8B4513),
  '고철': Color(0xff696969),
  '유리': Color(0xff4169E1),
  '캔': Color(0xff6B8E23),
  '플라스틱': Color(0xff4B0082),
  '스티로폼': Color(0xff2F4F4F),
  '비닐': Color(0xff778899),
  '의류': Color(0xffAC2323),
  '기타': Colors.black,
};

Color _getCategoryColor(String category) {
  return _categoryColors[category] ?? Colors.grey;
}

class PostDetail extends StatefulWidget {
  final int questionId;

  const PostDetail({
    super.key,
    required this.questionId,
  });

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = <Comment>[];
  Question? _question;
  final TokenService _tokenService = TokenService();
  bool _isLoggedIn = false;
  bool _isAuthor = false;

  late Timer _timer;
  bool _isAiCommentReady = false;
  String _aiComment = "AI 댓글을 기다리는 중...";

  // 각 댓글(commentId)에 대한 작성자 userId를 저장하는 Map
  final Map<int, String> _commentOwners = {};

  Future<void> _checkLogin() async {
    bool loggedIn = await _tokenService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  // 시간 형식 지정
  String _formatDate(String dateString) {
    DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm").parse(dateString);
    DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return DateFormat("HH:mm").format(dateTime); // 오늘인 경우 시간만
    } else {
      return DateFormat("yyyy-MM-dd").format(dateTime); // 오늘이 아닌 경우 날짜 전체
    }
  }

  @override
  void initState() {
    super.initState();
    // 로그인 여부 확인
    _checkLogin();

    _checkAuthorStatus();

    _timer = Timer.periodic(Duration(seconds: 7), (timer) {
      _checkAiCommentStatus();
    });

    // 댓글 목록 불러오기
    _loadComments();

    // 질문 데이터 불러오기
    ApiService.getQuestion(widget.questionId).then((value) {
      print("질문 내용 : ${value.content}");
      setState(() {
        _question = value;
      });
    }).catchError((error) {
      print("질문 불러오기 에러: $error");
    });
  }

  // 작성자 여부 확인
  Future<void> _checkAuthorStatus() async {
    try {
      bool result = await ApiService.checkQuestionIfAuthor(widget.questionId);
      setState(() {
        _isAuthor = result;
      });
    } catch (e) {
      print("작성자 확인 오류: $e");
    }
  }

  Future<void> _checkAiCommentStatus() async {
    try {
      AiComments aiComment = await ApiService.getAiComment(widget.questionId);
      setState(() {
        _isAiCommentReady = true;
        _aiComment = aiComment.content;
      });
      _timer.cancel(); // AI 댓글이 생성되면 타이머 종료
    } catch (e) {
      setState(() {
        _isAiCommentReady = false;
        _aiComment = "AI 댓글 생성 중...";
      });
    }
  }

  // 댓글 목록과 각 댓글의 작성자 정보(작성자 userId)를 불러오는 메서드
  Future<void> _loadComments() async {
    try {
      List<Comment> fetchedComments =
          await ApiService.getComments(widget.questionId);
      setState(() {
        _comments = fetchedComments;
      });
    } catch (e) {
      print('댓글 목록 불러오기 에러: $e');
    }
  }

  // 댓글 등록 후 전체 댓글 목록 새로고침 및 입력 필드 초기화
  Future<void> _updateFinishState() async {
    await _loadComments();
    setState(() {
      _commentController.clear();
    });
  }

  // 댓글 삭제 후 목록 업데이트
  Future<void> _deleteComment(int commentId) async {
    try {
      await ApiService.deleteComment(commentId);
      await _updateFinishState();
    } catch (e) {
      print('댓글 삭제 에러: $e');
    }
  }

  // 질문 삭제
  Future<void> _deletePost(int questionId) async {
    try {
      await ApiService.deletePost(questionId);
      Navigator.pop(context, true);
    } catch (e) {
      print('질문 삭제 에러: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // _question이 null이면 로딩 표시
    if (_question == null) {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
      body: _buildBody(context, _question!),
    );
  }

  /// 실제 UI를 그리는 메소드
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
                  color: _getCategoryColor(question.category),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  question.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                // 제목을 최대한 차지하도록 설정
                child: Text(
                  question.title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
              ),
              if (_isAuthor)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    _deletePost(widget.questionId);
                    print('질문 삭제 완료');
                  },
                  icon: const Icon(
                    Icons.delete_forever_outlined,
                    size: 20,
                    color: Color(0xffac2323),
                  ),
                ),
            ],
          ),
          // 작성자 및 조회수
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 13, 0),
            child: Row(
              children: [
                Text(
                  question.member,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  _formatDate(_question!.createAt),
                  style: TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${question.view}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 질문 내용
          Text(
            question.content,
            style: const TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 20),
          // AI 코멘트 영역
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
              children: [
                Text(
                  'AI 댓글',
                  style: TextStyle(
                    color: const Color(0xff748d6f),
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 150,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isAiCommentReady)
                          Center(
                            // 로딩 화면 중앙 정렬
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  _aiComment,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                CircularProgressIndicator(),
                              ],
                            ),
                          )
                        else
                          Text(
                            _aiComment,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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
                Text(
                  '댓글 ${_comments.length}개',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      String? owner = _commentOwners[comment.commentId];
                      return CommentItem(
                        commentId: comment.commentId,
                        userId: owner,
                        memberName: comment.memberName,
                        time: comment.createdAt,
                        content: comment.content,
                        isAuthor: comment.isAuthor,
                        onDelete: _deleteComment,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 댓글 입력 영역
          Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: _isLoggedIn,
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: '댓글을 입력하세요',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoggedIn
                    ? () async {
                        if (_commentController.text.isEmpty) return;
                        try {
                          // 댓글 등록 API 호출
                          await ApiService.postComment(
                              widget.questionId, _commentController.text);
                          // 댓글 등록 후 목록 업데이트 및 입력창 초기화
                          await _updateFinishState();
                        } catch (e) {
                          print("댓글 등록 에러: $e");
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff748d6f),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                child: const Text(
                  '등록',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

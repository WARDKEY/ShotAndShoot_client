import 'package:flutter/material.dart';
import 'package:shotandshoot/models/comment.dart';
import 'package:shotandshoot/models/question.dart';
import 'package:shotandshoot/service/api_service.dart';

import '../utils/comment_item.dart';

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
  String? _aiComments;
  Question? _question;

  // 현재 로그인한 사용자의 ID (실제 로그인 로직에 따라 할당)
  String _currentUserId = "";

  // 각 댓글(commentId)에 대한 작성자 userId를 저장하는 Map
  final Map<int, String> _commentOwners = {};

  @override
  void initState() {
    super.initState();

    // 로그인한 사용자의 userId 불러오기
    ApiService.getUserId().then((value) {
      print("현재 로그인한 userId 확인 ${value.toString()}");
      setState(() {
        _currentUserId = value.toString() ?? ""; // 로그아웃 시 빈 문자열 할당
      });
    });

    // AI 댓글 데이터 불러오기
    ApiService.fetchAiComment(widget.questionId).then((value) {
      print("ai 댓글 내용 : ${value.content}");
      setState(() {
        _aiComments = value.content;
      });
    });

    // 댓글 목록 불러오기
    _loadComments();

    // 질문 데이터 불러오기
    ApiService.fetchQuestion(widget.questionId).then((value) {
      print("질문 내용 : ${value.content}");
      setState(() {
        _question = value;
      });
    }).catchError((error) {
      print("질문 불러오기 에러: $error");
    });
  }

  // 댓글 목록과 각 댓글의 작성자 정보(작성자 userId)를 불러오는 메서드
  Future<void> _loadComments() async {
    try {
      List<Comment> fetchedComments =
          await ApiService.fetchComments(widget.questionId);
      setState(() {
        _comments = fetchedComments;
      });
      // 각 댓글에 대해 작성자 userId를 가져옴
      for (var comment in fetchedComments) {
        try {
          String owner =
              await ApiService.getUserIdFromCommentId(comment.commentId);
          setState(() {
            _commentOwners[comment.commentId] = owner;
          });
        } catch (e) {
          print('댓글 ${comment.commentId} 작성자 정보 가져오기 실패: $e');
        }
      }
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  question.category,
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 작성자 및 조회수
          Row(
            children: [
              Text(
                question.member,
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
                    '${question.view}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 질문 내용
          Text(
            question.content,
            style: const TextStyle(fontSize: 14),
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
                  'AI 코멘트',
                  style: TextStyle(
                    color: const Color(0xff748d6f),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 150,
                  child: SingleChildScrollView(
                    child: Text(
                      _aiComments ?? '로딩 중...',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
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
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      // _commentOwners[comment.commentId]
                      String? owner = _commentOwners[comment.commentId];
                      return CommentItem(
                        commentId: comment.commentId,
                        userId: owner,
                        memberName: comment.memberName,
                        time: comment.createdAt,
                        content: comment.content,
                        currentUserId: _currentUserId,
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
                onPressed: () async {
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


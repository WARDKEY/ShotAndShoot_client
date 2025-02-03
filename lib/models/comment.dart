class Comment {
  final int commentId;
  final String content;
  final int questionId;
  final String memberId;
  final String createdAt;

  Comment(
      {required this.commentId,
      required this.content,
      required this.questionId,
      required this.memberId,
      required this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        commentId: json['commentId'] as int,
        content: json['content'] as String,
        questionId: json['questionId'] as int,
        memberId: json['memberId'] as String,
        createdAt: json['createdAt'] as String);
  }
}

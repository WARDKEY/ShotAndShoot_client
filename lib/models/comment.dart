class Comment {
  final int commentId;
  final String content;
  final int questionId;
  final String memberId;
  final String createAt;

  Comment(
      {required this.commentId,
      required this.content,
      required this.questionId,
      required this.memberId,
      required this.createAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        commentId: json['commentId'] as int,
        content: json['content'] as String,
        questionId: json['questionId'] as int,
        memberId: json['memberId'] as String,
        createAt: json['createAt'] as String);
  }
}

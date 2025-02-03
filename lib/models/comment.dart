class Comment {
  final int commentId;
  final String content;
  final int questionId;
  final String memberName;
  final String createdAt;

  Comment({
    required this.commentId,
    required this.content,
    required this.questionId,
    required this.memberName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'] as int,
      content: json['content'] as String,
      questionId: json['questionId'] as int,
      memberName: json['memberName'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
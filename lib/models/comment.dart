class Comment {
  final int commentId;
  final String content;
  final int questionId;
  final String member;
  final DateTime createAt;

  Comment(
      {required this.commentId,
      required this.content,
      required this.questionId,
      required this.member,
      required this.createAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        commentId: json['commentId'],
        content: json['content'],
        questionId: json['questionId'],
        member: json['member'],
        createAt: json['createAt']);
  }
}

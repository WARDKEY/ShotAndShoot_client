class AiComments {
  final int aiCommentId;
  final String content;
  final int questionId;

  AiComments(
      {required this.aiCommentId,
      required this.content,
      required this.questionId});

  factory AiComments.fromJson(Map<String, dynamic> json) {
    return AiComments(
      aiCommentId: json['aiCommentId'] as int,
      content: json['content'] as String,
      questionId: json['questionId'] as int,
    );
  }
}

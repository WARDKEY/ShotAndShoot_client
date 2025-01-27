class Question {
  final int questionId;
  final String title;
  final String content;
  final String category;
  final int view;
  final String member;
  final String createAt;

  Question(
      { required this.questionId,
      required this.title,
      required this.content,
      required this.category,
      required this.view,
      required this.member,
      required this.createAt});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
        questionId: json['questionId'] as int,
        title: json['title'] as String,
        content: json['content'] as String,
        category: json['category'] as String,
        view: json['view'] as int,
        member: json['member'] as String,
        createAt: json['createAt'] as String);
  }
}

class Board {
  int? no;
  String? title;
  String? writer;
  String? content;
  DateTime? regDate;
  DateTime? upDate;

  Board({
    required this.no,
    required this.title,
    required this.writer,
    required this.content,
    this.regDate,
    this.upDate,
  });
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final int commentId;
  final String? userId; // API를 통해 받아온 댓글 작성자 userId (null일 수 있음)
  final String memberName;
  final String time;
  final String content;
  final Function(int) onDelete;
  final String currentUserId; // 현재 로그인한 사용자 ID

  const CommentItem({
    Key? key,
    required this.commentId,
    required this.userId,
    required this.memberName,
    required this.time,
    required this.content,
    required this.onDelete,
    required this.currentUserId,
  }) : super(key: key);

  String _formatDate(String dateString) {
    DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm").parse(dateString);
    DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return DateFormat("HH:mm").format(dateTime);  // 오늘인 경우 시간만
    } else {
      return DateFormat("yyyy-MM-dd").format(dateTime);  // 오늘이 아닌 경우 날짜 전체
    }
  }

  @override
  Widget build(BuildContext context) {
    // API로 받아온 owner가 null이면 아직 로딩 중으로 간주하고, 로딩 중일 때는 삭제 버튼을 표시하지 않습니다.
    bool isOwner = (userId != null && userId == currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Container(
        decoration: const BoxDecoration(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 12, 0),
                  child: Row(
                    children: [
                      Text(
                        memberName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        _formatDate(time),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // 현재 로그인한 사용자와 API로 받아온 댓글 작성자가 일치할 때만 삭제 버튼 표시
                if (isOwner)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () async {
                      await onDelete(commentId);
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Color(0xffac2323),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 12, 0),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PostSearch extends StatelessWidget {
  final Function(String) onChanged;

  const PostSearch({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 7),
      child: TextField(
        decoration: InputDecoration(
          hintText: "게시글 검색",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

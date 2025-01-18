import 'package:flutter/material.dart';

class PostWrite extends StatefulWidget {
  const PostWrite({super.key});

  @override
  State<PostWrite> createState() => _PostWriteState();
}

class _PostWriteState extends State<PostWrite> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool isFinish() {
    if (_titleController.text.isNotEmpty &&
        _categoryController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    _titleController.addListener(_updateFinishState);
    _categoryController.addListener(_updateFinishState);
    _contentController.addListener(_updateFinishState);
  }

  void _updateFinishState() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text('글쓰기'),
        centerTitle: true,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 20,
                )),
            onPressed: isFinish()
                ? () {
                    print(
                        '제목 : ${_titleController.text} 카테고리 : ${_categoryController.text} 내용 ${_contentController.text}');
                  }
                : null,
            child: Text(
              '완료',
              style: TextStyle(
                color: isFinish() ? Color(0xff748d6f) : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: '카테고리',
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Text(
                  '내용',
                  style: TextStyle(fontSize: 23),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요.',
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
              ),
              maxLines: 10,
              textAlignVertical: TextAlignVertical.top,
            ),
          ],
        ),
      ),
    );
  }
}

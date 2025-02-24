import 'package:flutter/material.dart';

import '../service/api_service.dart';

class PostWrite extends StatefulWidget {
  const PostWrite({super.key});

  @override
  State<PostWrite> createState() => _PostWriteState();
}

class _PostWriteState extends State<PostWrite> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<String> _categories = [
    '종이',
    '고철',
    '유리',
    '캔',
    '플라스틱',
    '스티로폼',
    '비닐',
    '의류',
    '기타',
  ];
  String? _selectedCategory;

  bool isFinish() {
    return _titleController.text.isNotEmpty &&
        _selectedCategory != null &&
        _contentController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateFinishState);
    _contentController.addListener(_updateFinishState);
  }

  void _updateFinishState() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('글쓰기'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isFinish()
                ? () {
                    ApiService.postQuestion(_titleController.text,
                        _contentController.text, _selectedCategory!);
                    // Navigator.pop(context);
                    Navigator.pop(context, true);
                  }
                : null,
            child: Text(
              '완료',
              style: TextStyle(
                  color: isFinish() ? const Color(0xff748d6f) : Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 18),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              onChanged: (text) {
                if (text.characters.length > 16) {
                  _titleController.text = text.characters.take(15).toString();
                }
              },
              decoration: const InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                hintText: ' 15자 이내로 입력 가능합니다.',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                )
              ),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: '카테고리 선택',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 40),
            const Row(
              children: [
                Text(
                  '내용',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
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

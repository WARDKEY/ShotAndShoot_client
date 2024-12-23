import 'package:flutter/material.dart';

class UserEdit extends StatefulWidget {
  const UserEdit({super.key});

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  List<TextEditingController> _controllers = [];
  List<String> _labels = ['이름', '이메일'];

  @override
  void initState() {
    super.initState();
    // 각 입력 필드에 대한 TextEditingController 초기화
    _controllers = List.generate(_labels.length, (index) => TextEditingController());
    // 초기 데이터 설정
    _controllers[0].text = "홍길동"; // 이름
    _controllers[1].text = "hong@example.com"; // 이메일
  }

  @override
  void dispose() {
    // 모든 컨트롤러 정리
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveChanges() {
    for (int i = 0; i < _controllers.length; i++) {
      print('${_labels[i]}: ${_controllers[i].text}');
    }
    // 서버로 전송하거나 로컬 저장소에 저장하는 코드 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 정보 수정'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          TextButton(onPressed: _saveChanges, child: Text("저장", style: TextStyle(color: Colors.black, fontSize: 16),),),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < _labels.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 25), // 각 필드 간 간격
                child: TextField(
                  controller: _controllers[i],
                  decoration: InputDecoration(
                    labelText: _labels[i],
                    // 둥근 테두리 설정
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // 테두리 둥글게
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

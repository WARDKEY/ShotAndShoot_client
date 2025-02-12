import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shotandshoot/service/api_service.dart';
import 'package:shotandshoot/service/token_service.dart';

import '../provider/app_state_provider.dart';

class UserEdit extends StatefulWidget {
  const UserEdit({super.key});

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  final TokenService _tokenService = TokenService();
  final ApiService _apiService = ApiService();

  List<TextEditingController> _controllers = [];
  final List<String> _labels = ['이름', '주소'];

  void navigateToMainPage() {
    Navigator.pop(context);
    Provider.of<AppState>(context, listen: false).onItemTapped(0);
  }

  // 회원 정보 수정
  Future<void> updateMemberInfo(String nickName, String address) async {
    await _apiService.updateMemberInfo(nickName, address);
  }

  // 카카오 로그아웃
  Future<void> kakaoLogout() async {
    await UserApi.instance.logout();
  }

  // 구글 로그아웃
  Future<void> googleLogout() async {
    await GoogleSignIn().signOut();
  }

  Future<void> logout() async {
    try {
      final response = await _apiService.logout();

      if (response.statusCode == 200) {
        _tokenService.logOut();
        print("로그아웃 성공");
        navigateToMainPage();
      } else {
        print("로그아웃 실패 ${response.statusCode}");
      }
    } catch (error) {
      print("로그아웃 실패 $error");
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await _apiService.deleteAccount();

      if (response.statusCode == 200) {
        _tokenService.logOut();
        print("회원탈퇴");
        navigateToMainPage();
      } else {
        print("회원탈퇴 실패 ${response.statusCode}");
      }
    } catch (error) {
      print("회원탈퇴 실패 $error");
    }
  }

  @override
  void initState() {
    super.initState();
    // 각 입력 필드에 대한 TextEditingController 초기화
    _controllers =
        List.generate(_labels.length, (index) => TextEditingController());
    // 초기 데이터 설정
    _controllers[0].text = "홍길동"; // 이름
    _controllers[1].text = "경기도 OO시"; // 주소
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
    updateMemberInfo(_controllers[0].text, _controllers[1].text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 정보 수정'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              _saveChanges();
              navigateToMainPage();
            },
            child: Text(
              "저장",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    await logout();
                  },
                  child: Text(
                    "로그아웃",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(7, 0, 7, 0),
                  height: 15, // 세로 높이 설정
                  width: 1, // 선의 두께
                  color: Colors.grey, // 선 색상
                ),
                TextButton(
                  onPressed: () async {
                    await deleteAccount();
                  },
                  child: Text(
                    "회원탈퇴",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

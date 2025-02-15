import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kpostal/kpostal.dart';
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
  final List<String> _labels = ['이름', '주소', '상세주소'];

  Future<Map<String, dynamic>> fetchMemberInfo() async {
    final response = await _apiService.getMemberInfo();
    return response;
  }

  void navigateToMainPage() {
    Navigator.pop(context);
    Provider.of<AppState>(context, listen: false).onItemTapped(0);
  }

  Future<void> updateMemberInfo(String nickName, String address) async {
    await _apiService.updateMemberInfo(nickName, address);
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
    _controllers =
        List.generate(_labels.length, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveChanges() {
    updateMemberInfo(_controllers[0].text, _controllers[1].text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 정보 수정'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              _saveChanges();
              navigateToMainPage();
            },
            child: const Text(
              "저장",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMemberInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            _controllers[0].text = data["nickName"] ?? '';
            _controllers[1].text = data["address"] ?? '';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: TextField(
                      controller: _controllers[0],
                      decoration: InputDecoration(
                        labelText: _labels[0],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: TextField(
                      controller: _controllers[1],
                      readOnly: true,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return KpostalView(
                              callback: (Kpostal result) {
                                // receiverZipController.text = result.postCode;
                                _controllers[1].text = result.address;
                              },
                            );
                          },
                        ));
                      },
                      decoration: InputDecoration(
                        labelText: _labels[1],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: TextField(
                      controller: _controllers[2],
                      decoration: InputDecoration(
                        labelText: "상세주소",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // for (int i = 0; i < _labels.length; i++)
                  //   Padding(
                  //     padding: const EdgeInsets.only(bottom: 25),
                  //     child: TextField(
                  //       controller: _controllers[i],
                  //       decoration: InputDecoration(
                  //         labelText: _labels[i],
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await logout();
                        },
                        child: const Text(
                          "로그아웃",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                        height: 15,
                        width: 1,
                        color: Colors.grey,
                      ),
                      TextButton(
                        onPressed: () async {
                          await deleteAccount();
                        },
                        child: const Text(
                          "회원탈퇴",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('회원 정보를 불러올 수 없습니다.'));
          }
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import 'package:shotandshoot/screens/signin_success_screen.dart';
import 'package:shotandshoot/service/api_service.dart';

class PostUserInfo extends StatefulWidget {
  final String id;

  const PostUserInfo({super.key, required this.id});

  @override
  State<PostUserInfo> createState() => _PostUserInfoState();
}

class _PostUserInfoState extends State<PostUserInfo> {
  final int _maxLength = 12;
  String _currentLength = "0";

  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController =
      TextEditingController();

  // 회원가입인지 내정보 수정인지에 따라 상태 관리 해야됨

  @override
  void initState() {
    super.initState();
    _nickNameController.addListener(() {
      setState(() {
        // 현재 입력된 텍스트 길이 업데이트
        _currentLength = _nickNameController.text.length.toString();
      });
    });
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  // 회원가입 완료 페이지로 이동
  void navigateToSignInLoginPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SigninLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "닉네임",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$_currentLength / $_maxLength',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _nickNameController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              labelText: '닉네임',
              labelStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "전화번호",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              labelText: '전화번호',
              labelStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "주소",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _addressController,
            readOnly: true,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return KpostalView(
                    callback: (Kpostal result) {
                      // receiverZipController.text = result.postCode;
                      _addressController.text = result.address;
                    },
                  );
                },
              ));
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              labelText: '주소',
              labelStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "상세주소",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _detailAddressController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              labelText: '상세주소',
              labelStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 55,
          ),
          ElevatedButton(
            onPressed: () {
              // 닉네임, 전화번호, 주소 들어가기전 클릭 비활성화
              ApiService.postUserInfo(
                  widget.id,
                  _nickNameController.text,
                  _phoneNumberController.text,
                  _addressController.text + _detailAddressController.text);
              navigateToSignInLoginPage();
              print(
                  '닉네임 : ${_nickNameController.text} 전화번호 : ${_phoneNumberController.text} 주소 : ${_addressController.text}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff748d6f),
              elevation: 0,
              minimumSize: Size.fromHeight(70),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              '회원가입',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

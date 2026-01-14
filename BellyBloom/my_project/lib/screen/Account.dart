import 'package:flutter/material.dart';
import 'package:my_project/screen/login_page.dart';
import 'package:my_project/service/account_service.dart';
import 'package:my_project/service/base_common.dart';

class Account_tad extends StatefulWidget {
  const Account_tad({super.key});

  @override
  State<Account_tad> createState() => _Account_tadState();
}

class _Account_tadState extends State<Account_tad> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _mainBody(),
        Container(
          height: 80,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 240),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,

                blurRadius: 0.7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Build_top_main(
                  // icon : Icon(Icons.home),
                  text: 'Trang chủ',
                ),
                _Build_top_main(icon: Icon(Icons.home), text: 'Trang chủ'),
                _Build_top_main(icon: Icon(Icons.home), text: 'Trang chủ'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column _Build_top_main({Icon? icon, required String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon ?? Icon(Icons.topic),
        Text(text, style: TextStyle(color: Colors.pink.shade100, fontSize: 14)),
      ],
    );
  }

  Column _mainBody() {
    return Column(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            gradient: LinearGradient(
              colors: [
                Colors.pink.shade100,
                const Color.fromARGB(255, 209, 57, 108),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.pink.shade100,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Nguyen Van A',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '123@gmail.com',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 50),
        _build_row_function(
          Icon(Icons.person, color: Colors.pink.shade100, size: 34),
          'Thông tin cá nhân',
          false,
        ),
        _build_row_function(
          Icon(Icons.person, color: Colors.pink.shade100, size: 34),
          'Thông tin cá nhân',
          false,
        ),
        _build_row_function(
          Icon(Icons.person, color: Colors.pink.shade100, size: 34),
          'Thông tin cá nhân',
          false,
        ),
        Center(
          child: GestureDetector(
            onTap: () => _showLogoutDialog(),
            child: _build_row_function(
              Icon(Icons.logout_outlined, color: Colors.red, size: 30),
              'Đăng xuất',
              true,
            ),
          ),
        ),
      ],
    );
  }

  Container _build_row_function(Icon icon, String text, bool isLogout) {
    return Container(
      margin:
          isLogout ? EdgeInsets.symmetric(horizontal: 20, vertical: 50) : null,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration:
          isLogout
              ? BoxDecoration(
                border: Border.all(color: Colors.red, width: 1.5),
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              )
              : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 50, height: 50, child: icon),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  color: isLogout ? Colors.red : Colors.pink.shade100,
                ),
              ),
            ),
          ),
          Icon(
            isLogout ? null : Icons.arrow_forward,
            color: isLogout ? Colors.red : Colors.pink.shade100,
            size: 34,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.red.shade400),
                SizedBox(width: 10),
                Text('Đăng xuất'),
              ],
            ),
            content: Text(
              'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Hủy',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleLogout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Đăng xuất'),
              ),
            ],
          ),
    );
  }

  void _handleLogout() async {
    try {
      // Đăng xuất khỏi Firebase
      await AccountService.logout();

      // Xóa dữ liệu user khỏi local storage
      await BaseCommon().clearUserAccount();

      // Navigate to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      // Hiển thị lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đăng xuất: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

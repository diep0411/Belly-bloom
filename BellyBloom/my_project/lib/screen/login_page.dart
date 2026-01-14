import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_project/model/user_account.dart';
import 'package:my_project/resoucre/image_manager.dart';
import 'package:my_project/screen/Home_page.dart';
import 'package:my_project/screen/form_collection/form_collection.dart';
import 'package:my_project/screen/register.dart';
import 'package:my_project/service/account_service.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/service/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  bool isHidePassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _handlelogin() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserAccount userAccount = await AccountService.login(
        email: emailController.text,
        password: passwordController.text,
      );
      BaseCommon().saveUserAccount(userAccount);
      BaseCommon().saveAutoLogin(
        email: emailController.text,
        password: passwordController.text,
      );
      // Reschedule notifications after login
      NotificationService.rescheduleAllAppointments();
      if (userAccount.formCollection == null) {
        log('User chua co thong tin ban dau');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => FormCollectionPage()));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Chào mừng ${userAccount.name}!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomePage()));
      //     });
      // UserCredential user = await FirebaseAuth.instance
      //     .signInWithEmailAndPassword(
      //       email: emailController.text,
      //       password: passwordController.text,
      //     );
      // log(
      //   "Login Success"
      //   " ${user.user?.email ?? 'Unknown'}",
      // );
      // FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(user.user?.uid)
      //     .get()
      //     .then((value) async {
      //       final SharedPreferences prefs =
      //           await SharedPreferences.getInstance();
      //       prefs.setString('user_uid', user.user?.uid ?? '');
      //       UserAccount userAccount = UserAccount.fromJson(value.data() ?? {}, user.user?.uid ?? '');
      //       if (userAccount.formCollection == null) {
      //         log('User chua co thong tin ban dau');
      //         Navigator.of(
      //           context,
      //         ).push(MaterialPageRoute(builder: (_) => FormCollectionPage()));
      //         return;
      //       }
      //       log('Username: ${userAccount.name}');
      //       log('value: ${jsonEncode(userAccount)}');
      //       log('value: ${jsonEncode(value.data())}');
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(
      //           content: Text('Chao mung ${value.data()?['name']}'),
      //           backgroundColor: Colors.red,
      //         ),
      //       );
      //       setState(() {
      //         isLoading = false;
      //       });
      //       Navigator.of(
      //         context,
      //       ).push(MaterialPageRoute(builder: (_) => HomePage()));
      //     });
    } catch (e) {
      log("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getErrorMessage(e.toString()),
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 4),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Không tìm thấy tài khoản với email này';
    } else if (error.contains('wrong-password')) {
      return 'Mật khẩu không chính xác';
    } else if (error.contains('invalid-email')) {
      return 'Email không hợp lệ';
    } else if (error.contains('user-disabled')) {
      return 'Tài khoản đã bị vô hiệu hóa';
    } else if (error.contains('too-many-requests')) {
      return 'Quá nhiều lần thử. Vui lòng thử lại sau';
    } else if (error.contains('network-request-failed')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet';
    } else {
      return 'Đăng nhập thất bại. Vui lòng thử lại';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade100,
              Colors.pink.shade200,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Header Section
                        _buildHeaderSection(),

                        // Form Section
                        Expanded(child: _buildFormSection()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          // Logo with enhanced styling
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              child: Container(
                padding: EdgeInsets.all(15),
                child: Image.asset(ImageRes.logo, fit: BoxFit.contain),
              ),
            ),
          ),

          SizedBox(height: 30),

          // App Title with enhanced styling
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'BaByBloom',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Colors.pink.shade300,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          // Subtitle
          Text(
            'Chào mừng bạn đến với cẩm nang thai kỳ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            Center(
              child: Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            SizedBox(height: 10),

            Center(
              child: Text(
                'Vui lòng nhập thông tin để tiếp tục',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),

            SizedBox(height: 40),

            // Email Field
            _buildInputField(
              label: 'Email',
              icon: Icons.email_outlined,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'Nhập email của bạn',
            ),

            SizedBox(height: 25),

            // Password Field
            _buildInputField(
              label: 'Mật khẩu',
              icon: Icons.lock_outline,
              controller: passwordController,
              obscureText: isHidePassword,
              hintText: 'Nhập mật khẩu',
              suffixIcon: IconButton(
                icon: Icon(
                  isHidePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    isHidePassword = !isHidePassword;
                  });
                },
              ),
            ),

            SizedBox(height: 20),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    color: Colors.pink.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Login Button
            _buildLoginButton(),

            SizedBox(height: 30),

            // Register Section
            _buildRegisterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.pink.shade400),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.pink.shade600],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handlelogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child:
            isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Đang đăng nhập...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildRegisterSection() {
    return Center(
      child: Column(
        children: [
          Text(
            'Chưa có tài khoản?',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.pink.shade300, width: 1),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => RegisterPage()));
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Đăng ký ngay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_project/screen/login_page.dart';
import 'package:my_project/screen/profile_page.dart';
import 'package:my_project/service/account_service.dart';
import 'package:my_project/service/base_common.dart';

class SettingPages extends StatefulWidget {
  const SettingPages({super.key});

  @override
  State<SettingPages> createState() => _SettingPagesState();
}

class _SettingPagesState extends State<SettingPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header with User Profile
            _buildHeaderSection(),

            // Settings Menu Items
            Expanded(child: _buildSettingsMenu()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink.shade400, Colors.pink.shade600],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Avatar and Info
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade200, Colors.pink.shade300],
                      ),
                    ),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(width: 20),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      BaseCommon().userAccount.name,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      BaseCommon().userAccount.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Section
          _buildSectionTitle('Tài khoản'),
          SizedBox(height: 15),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            subtitle: 'Chỉnh sửa thông tin tài khoản',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Bảo mật',
            subtitle: 'Mật khẩu và xác thực',
            onTap: () {
              // TODO: Navigate to security
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            subtitle: 'Cài đặt thông báo',
            onTap: () {
              // TODO: Navigate to notifications
            },
          ),

          SizedBox(height: 30),

          // App Section
          _buildSectionTitle('Ứng dụng'),
          SizedBox(height: 15),
          _buildMenuItem(
            icon: Icons.palette_outlined,
            title: 'Giao diện',
            subtitle: 'Chủ đề và màu sắc',
            onTap: () {
              // TODO: Navigate to theme
            },
          ),
          _buildMenuItem(
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            subtitle: 'Tiếng Việt',
            onTap: () {
              // TODO: Navigate to language
            },
          ),
          _buildMenuItem(
            icon: Icons.storage_outlined,
            title: 'Lưu trữ',
            subtitle: 'Quản lý dữ liệu',
            onTap: () {
              // TODO: Navigate to storage
            },
          ),

          SizedBox(height: 30),

          // Support Section
          _buildSectionTitle('Hỗ trợ'),
          SizedBox(height: 15),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Trợ giúp',
            subtitle: 'Câu hỏi thường gặp',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách bảo mật',
            subtitle: 'Điều khoản sử dụng',
            onTap: () {
              // TODO: Navigate to privacy
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Giới thiệu',
            subtitle: 'Phiên bản 1.0.0',
            onTap: () {
              // TODO: Navigate to about
            },
          ),

          SizedBox(height: 40),

          // Logout Button
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade600,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.red.shade200),
                ),
              ),
              icon: Icon(Icons.logout, size: 20),
              label: Text(
                'Đăng xuất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.pink.shade400, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
      log('handleLogout: ${e.toString()}');
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

import 'package:babyweb/model/user_account.dart';
import 'package:babyweb/resource/color_manager.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/account_service.dart';
import 'package:babyweb/widgets/user_health_chart_dialog.dart';
import 'package:flutter/material.dart';

class AdminUserAccountList extends StatefulWidget {
  const AdminUserAccountList({super.key});

  @override
  State<AdminUserAccountList> createState() => _AdminUserAccountListState();
}

class _AdminUserAccountListState extends State<AdminUserAccountList> {
  List<UserAccount> users = [];
  List<UserAccount> filteredUsers = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();
    searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void loadUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedUsers = await AccountService.getAllUsers();
      setState(() {
        users = loadedUsers;
        filteredUsers = List.from(users);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(users);
      } else {
        filteredUsers = users.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showUserHealthChart(UserAccount user) {
    showDialog(
      context: context,
      builder: (context) => UserHealthChartDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: UtilsReponsive.padding(context, horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: UtilsReponsive.height(24, context)),
          _buildSearchSection(),
          SizedBox(height: UtilsReponsive.height(24, context)),
          Expanded(child: _buildUsersList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorManager.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.people_outline,
            color: ColorManager.primary,
            size: UtilsReponsive.formatFontSize(24, context),
          ),
        ),
        SizedBox(width: UtilsReponsive.width(16, context)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý tài khoản',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(28, context),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'Danh sách người dùng và thông tin sức khỏe',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Spacer(),
        IconButton(
          onPressed: loadUsers,
          icon: Icon(Icons.refresh),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(16, context),
        vertical: UtilsReponsive.height(12, context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: UtilsReponsive.formatFontSize(20, context),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc email...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: UtilsReponsive.formatFontSize(14, context),
                ),
              ),
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clear();
              },
              icon: Icon(Icons.clear, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
        ),
      );
    }

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              searchController.text.isNotEmpty
                  ? 'Không tìm thấy người dùng'
                  : 'Chưa có người dùng nào',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(16, context),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(UserAccount user) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showUserHealthChart(user),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: UtilsReponsive.width(50, context),
              height: UtilsReponsive.width(50, context),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.person,
                color: ColorManager.primary,
                size: UtilsReponsive.formatFontSize(24, context),
              ),
            ),
            SizedBox(width: UtilsReponsive.width(16, context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isNotEmpty ? user.name : 'Chưa có tên',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(16, context),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

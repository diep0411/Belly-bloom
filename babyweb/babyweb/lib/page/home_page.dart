import 'package:babyweb/resource/color_manager.dart';
import 'package:babyweb/resource/image_manager.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/base_common.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Homepage extends StatefulWidget {
  final Widget child;
  
  const Homepage({super.key, required this.child});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int currentIndex = 0;
  bool isSidebarExpanded = true;
  
  List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.dashboard_outlined,
      'selectedIcon': Icons.dashboard,
      'text': 'Bảng điều khiển',
      'path': '/admin/dashboard',
    },
    {
      'icon': Icons.pregnant_woman_outlined,
      'selectedIcon': Icons.pregnant_woman,
      'text': 'Tuần thai kỳ',
      'path': '/admin/pregnancy-weeks',
    },
    {
      'icon': Icons.fitness_center_outlined,
      'selectedIcon': Icons.fitness_center,
      'text': 'Bài tập',
      'path': '/admin/exercises',
    },
    {
      'icon': Icons.article_outlined,
      'selectedIcon': Icons.article,
      'text': 'Nội dung',
      'path': '/admin/content',
    },
    {
      'icon': Icons.notifications_active_outlined,
      'selectedIcon': Icons.notifications_active,
      'text': 'Nhắc hẹn',
      'path': '/admin/reminders',
    },
    {
      'icon': Icons.people_outline,
      'selectedIcon': Icons.people,
      'text': 'Tài khoản',
      'path': '/admin/accounts',
    },
  ];
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _buildMainContent(),
        if (isSidebarExpanded) _buildMobileOverlay(),
        _buildMobileSidebar(),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: isSidebarExpanded ? UtilsReponsive.width(280, context) : UtilsReponsive.width(80, context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.primary,
            ColorManager.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(child: _buildMenuItems()),
          _buildUserProfile(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Row(
        children: [
          if (isSidebarExpanded) ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                ImageRes.logo,
                height: UtilsReponsive.formatFontSize(40, context),
                width: UtilsReponsive.formatFontSize(40, context),
              ),
            ),
            SizedBox(width: UtilsReponsive.width(12, context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belly Bloom',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(18, context),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Bảng quản trị',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(12, context),
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                ImageRes.logo,
                height: UtilsReponsive.formatFontSize(40, context),
                width: UtilsReponsive.formatFontSize(40, context),
              ),
            ),
          ],
          Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                isSidebarExpanded = !isSidebarExpanded;
              });
            },
            icon: Icon(
              isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: UtilsReponsive.height(20, context)),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isSelected = GoRouterState.of(context).matchedLocation == item['path'];
        
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.width(12, context),
            vertical: UtilsReponsive.height(4, context),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.go(item['path']);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(16, context),
                  vertical: UtilsReponsive.height(12, context),
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected 
                      ? Border.all(color: Colors.white.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? item['selectedIcon'] : item['icon'],
                      color: Colors.white,
                      size: UtilsReponsive.formatFontSize(20, context),
                    ),
                    if (isSidebarExpanded) ...[
                      SizedBox(width: UtilsReponsive.width(12, context)),
                      Text(
                        item['text'],
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        children: [
          Divider(color: Colors.white.withOpacity(0.3)),
          SizedBox(height: UtilsReponsive.height(8, context)),
          Row(
            children: [
              CircleAvatar(
                radius: UtilsReponsive.formatFontSize(20, context),
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: UtilsReponsive.formatFontSize(20, context),
                ),
              ),
              if (isSidebarExpanded) ...[
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BaseCommon().userAccount.name.isNotEmpty 
                            ? BaseCommon().userAccount.name
                            : 'Người dùng quản trị',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(12, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        BaseCommon().userAccount.email.isNotEmpty 
                            ? BaseCommon().userAccount.email
                            : 'admin@bellybloom.com',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(10, context),
                          color: Colors.white.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _handleLogout,
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white.withOpacity(0.8),
                    size: UtilsReponsive.formatFontSize(18, context),
                  ),
                ),
              ] else ...[
                Spacer(),
                IconButton(
                  onPressed: _handleLogout,
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white.withOpacity(0.8),
                    size: UtilsReponsive.formatFontSize(18, context),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(24, context),
        vertical: UtilsReponsive.height(16, context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width <= 800) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  isSidebarExpanded = !isSidebarExpanded;
                });
              },
              icon: Icon(Icons.menu),
            ),
            SizedBox(width: UtilsReponsive.width(12, context)),
          ],
          Text(
            menuItems[currentIndex]['text'],
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(24, context),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: UtilsReponsive.width(16, context),
              vertical: UtilsReponsive.height(8, context),
            ),
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Chào mừng trở lại!',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(12, context),
                color: ColorManager.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSidebar() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      left: isSidebarExpanded ? 0 : -UtilsReponsive.width(280, context),
      top: 0,
      bottom: 0,
      child: Container(
        width: UtilsReponsive.width(280, context),
        child: _buildSidebar(),
      ),
    );
  }

  Widget _buildMobileOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isSidebarExpanded = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Đăng xuất'),
          content: Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Clear user data
                BaseCommon().isLogin = false;
                await BaseCommon().prefs.clear();
                
                // Navigate to login
                context.go('/');
              },
              child: Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

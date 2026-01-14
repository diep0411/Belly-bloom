import 'package:flutter/material.dart';
import 'package:my_project/resoucre/ColorManager.dart';
// Tạm ẩn tab Lịch
// import 'package:my_project/screen/schedule.dart';
import 'package:my_project/screen/chat_page.dart';
import 'package:my_project/screen/setting_Pages.dart';
import 'package:my_project/screen/tab/tab_home_page.dart';
import 'package:my_project/service/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  List<Widget> listPage = [];

  @override
  void initState() {
    // Tạm ẩn tab Lịch
    listPage = [TabHomePage(), SettingPages()];
    // listPage = [TabHomePage(), SchedulePage(), SettingPages()];
    super.initState();
    // Reschedule all appointment notifications when user enters home
    _rescheduleNotifications();
  }

  Future<void> _rescheduleNotifications() async {
    try {
      await NotificationService.rescheduleAllAppointments();
    } catch (e) {
      // Silent fail - notifications will be scheduled when appointments are created/updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomNav(),
      body: SafeArea(child: listPage[currentIndex]),
      floatingActionButton:
          currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => ChatPage()));
                },
                backgroundColor: managerColor.primary,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        managerColor.primary,
                        managerColor.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: managerColor.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.smart_toy, color: Colors.white, size: 28),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget bottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: managerColor.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: BottomNavigationBar(
        // backgroundColor: Colors.pinkAccent.shade200,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        currentIndex: currentIndex,
        selectedItemColor: managerColor.primary,
        // selectedLabelStyle: TextStyle(color: Colors.white),
        items: [
          BottomNavigationBarItem(label: 'Trang chủ', icon: Icon(Icons.home)),
          // Tạm ẩn tab Lịch
          // BottomNavigationBarItem(
          //   label: 'Lịch',
          //   icon: Icon(Icons.calendar_month),
          // ),
          BottomNavigationBarItem(label: 'Tài khoản', icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}

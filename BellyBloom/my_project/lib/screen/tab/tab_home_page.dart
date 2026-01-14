import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_project/model/appointment.dart';
import 'package:my_project/model/near_schedule.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/image_manager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/screen/appointment_page.dart';
import 'package:my_project/screen/diary_page.dart';
import 'package:my_project/screen/guide_page.dart';
import 'package:my_project/screen/progress_chart_page.dart';
import 'package:my_project/service/appointment_service.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/utils/util_common.dart';

class TabHomePage extends StatefulWidget {
  const TabHomePage({super.key});

  @override
  State<TabHomePage> createState() => _TabHomePageState();
}

class _TabHomePageState extends State<TabHomePage> {
  List<NearSchedule> nearSchedules = [];
  List<Appointment> upcomingAppointments = [];
  int currentDay = 0;
  int daysLeft = 0;
  DateTime? dueDate;
  bool isLoadingAppointments = true;
  int currentWeek = 0;
  String? token;
  @override
  void initState() {
    fetchData();
    _calculatePregnancyInfo();
    _loadUpcomingAppointments();
    FirebaseMessaging.instance.getToken().then((value) {
      token = value;
      log('token: $value');
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _calculatePregnancyInfo();
    _loadUpcomingAppointments();
    super.didChangeDependencies();
  }

  String constructFCMPayload() {
    return jsonEncode({
      "message": {
        "token": token,
        "notification": {
          "title": "Xin chào!",
          "body": "Đây là tin nhắn FCM v1",
        },
      },
    });
  }

  Future<void> sendPushMessage(String? token) async {
    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    String projectId = 'babyapp-bade7';

    try {
      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Bearer ya29.c.c0ASRK0GZGUZ8dOB0AI8OjaaaoIcRm9WhydmiB1gFqS_-OskA1-GeAXbn2RISecRMHCe8VSEGnHVXhZ2AsFgwqrHoE2AECprmWeACNacBy3jN82kLdENUFdLVnVUOwk18K9koW2_H-t9wy06fUwOwgR3L6ptrPjnn_NqsFU8PqJu5fmkw4tLU08Rc6hnNMLh4pFLb8U2EAI2lu6gBtlNfBrMS_RJo9Sbp9ipnMUgk8H3Wtbt7cZdBnkhU0LEZc_CLJSLDa6u3dOFzB3jA4OCH9Gwo-yBCGmlw1Iddzf2_UCvu5lYkCepruIEgMDcFV5bcn_GHDy-4RR5oJfWVTMNEJuD92cQeerirbqY7V-X6OAYvQkvJft0pr6PsvWQL387P4Vu8UlUJSX80y4Yi1uuearme8is7zjn943cmg6sZgko7f-8pJWerpjjysdpO6VqlpXV5pehbOhZp0lsUoonRlxa3-3wOSh-6zmddJj-Rg5QBqzeSy6Zicl2rfkj59Fyytllcok64gw9quseiWU3M49VF47X7u-kgFr2a-hmk53o0hvjOXJQYu_Q9Y8FZguus8cF13uewgWSbmYfM9znfOZj13r5203oIidib9jUo0vciOdonXO2SgOg0-edJUjFqqo0Qkrws33WJn0OX1RSk4htI9kizl6Ml4c6kk-MSebRfa_f1cWu3v8zz1Wsz4slW5z5Xb57YoV7xuRZbBF_SfpYwVXVRIprje2h165kuJq1MYvg8rWWRQtwFuzI0rjI9F2p6ZoaOydoS62UuMf91RnJ_yS1Zv121wjz1pvtzY-lrlvzcqhgngfaRW6iJx0yIWgedn9Y176X1bY4b3XQUtgRg2kVu3tyq5wQXSUJ4cfO7pJedxIcsqtYkrgWWw8u__tQyd3XxBeM5k8zrsQY4q1noh78wf_8xptIn5ebqey0bbu6dagZWQjjJIe-b7-O6bxe8ar8f_J9g-6JOzF6w7UQSwVOhhkjFqj4bkIuM0pV1txwysa_7uh-f',
        },
        body: constructFCMPayload(),
      );
      log('status: ${response.statusCode}');
      log('response: ${response.body}');
      log('FCM request for device sent!');
    } catch (e) {
      log(e.toString());
    }
  }

  void _calculatePregnancyInfo() {
    currentWeek = UtilsCommon.getCurrentWeekInPregnancy(
      BaseCommon().userAccount.formCollection!.createdAt,
      BaseCommon().userAccount.formCollection!.week,
    );
    dueDate = UtilsCommon.calculateDueDate(DateTime.now(), currentWeek);

    daysLeft = UtilsCommon.getPregnancyDay(
      BaseCommon().userAccount.formCollection!.createdAt,
      BaseCommon().userAccount.formCollection!.week,
    );

    ///new version
    currentDay = UtilsCommon.getCurrentDayInPregnancy(
      BaseCommon().userAccount.formCollection!.createdAt,
      BaseCommon().userAccount.formCollection!.week,
    );
  }

  fetchData() async {
    nearSchedules = [
      NearSchedule(
        date: 'Thứ 6 ngày 10/09/2025',
        time: '10:00',
        description: 'Khám bệnh',
      ),
      NearSchedule(
        date: 'Thứ 7 ngày 11/09/2025',
        time: '11:00',
        description: 'Khám bệnh',
      ),
      NearSchedule(
        date: 'Chủ nhật ngày 12/09/2025',
        time: '12:00',
        description: 'Khám bệnh',
      ),
    ];
  }

  Future<void> _loadUpcomingAppointments() async {
    try {
      final appointments = await AppointmentService.getUpcomingAppointments();
      setState(() {
        upcomingAppointments =
            appointments.take(3).toList(); // Chỉ lấy 3 lịch hẹn gần nhất
        isLoadingAppointments = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAppointments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cập nhật thông tin mỗi lần build để đảm bảo real-time
    _calculatePregnancyInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Section welcome
        _welcomeSection(),
        // Center(child: Image.asset('assets/images/garland.png',fit: BoxFit.fill, height: 70,width: 170,)),
        //Count Days Widget
        _countDays(),
        SizedBoxConst.size(context: context, size: 20),

        //Section infor baby: height, weight, days left
        _inforBaby(),
        SizedBoxConst.size(context: context, size: 20),
        //Show lịch gần tới - chỉ hiển thị khi có lịch hoặc đang loading
        if (isLoadingAppointments || upcomingAppointments.isNotEmpty)
          _upcomingAppointments(),
        if (isLoadingAppointments || upcomingAppointments.isNotEmpty)
          SizedBoxConst.size(context: context, size: 20),
        //Section nut chuc nang
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.height(15, context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tính năng',
                style: TextStyle(
                  color: managerColor.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(height: 2, width: 100, color: managerColor.primary),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconFunction(
                    icon: Image.asset(IconRes.time, height: 50, width: 50),
                    text: 'Quá trình',
                    navigationPage: ProgressChartPage(),
                  ),
                  _buildIconFunction(
                    icon: Image.asset(IconRes.checklist, height: 50, width: 50),
                    text: 'Tất cả lịch',
                    navigationPage: AppointmentPage(),
                  ),
                  _buildIconFunction(
                    icon: Image.asset(IconRes.checklist, height: 50, width: 50),
                    text: 'Cẩm nang',
                    navigationPage: GuidePage(),
                  ),
                  _buildIconFunction(
                    icon: Image.asset(IconRes.budget, height: 50, width: 50),
                    text: 'Nhật kí',
                    navigationPage: DiaryPage(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container _welcomeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.pinkAccent.shade200,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          CircleAvatar(radius: 30, child: Image.asset(ImageRes.logo)),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, ${BaseCommon().userAccount.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Hôm nay bạn thế nào?',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inforBaby() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.height(15, context),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.height(15, context),
        vertical: UtilsReponsive.height(10, context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: managerColor.primary.withOpacity(0.4),
            blurRadius: 10,
            offset: Offset(3, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Thông tin bé',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: UtilsReponsive.formatFontSize(18, context),
            ),
          ),
          SizedBoxConst.size(context: context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInforItem(
                title: 'Chiều cao',
                content:
                    '${BaseCommon().userAccount.formCollection?.height.toStringAsFixed(0) ?? '--'} cm',
              ),
              _buildInforItem(
                title: 'Cân nặng',
                content:
                    '${BaseCommon().userAccount.formCollection?.weight ?? '--'} kg',
              ),
              _buildInforItem(
                title: 'Ngày còn lại',
                content:
                    daysLeft > 0 ? '$daysLeft ngày' : 'Đã đến ngày dự sinh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column _buildInforItem({required String title, required String content}) =>
      Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: UtilsReponsive.formatFontSize(12, context),
            ),
          ),
          Text(
            content,
            style: TextStyle(
              color: managerColor.primary,
              fontWeight: FontWeight.w500,
              fontSize: UtilsReponsive.formatFontSize(16, context),
            ),
          ),
        ],
      );

  Widget _countDays() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: UtilsReponsive.height(20, context)),
        height: UtilsReponsive.height(150, context),
        width: UtilsReponsive.height(150, context),
        decoration: BoxDecoration(
          color: Colors.pinkAccent.shade200,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ngày thứ',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              '$currentDay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (BaseCommon().userAccount.formCollection?.week != null)
              Text(
                'Tuần $currentWeek',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Column _buildIconFunction({
    required Widget icon,
    required String text,
    Widget? navigationPage,
  }) => Column(
    children: [
      InkWell(
        onTap: () async {
          if (navigationPage != null) {
            await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => navigationPage));
            // refresh data
            _loadUpcomingAppointments();
          }
        },
        child: icon,
      ),
      SizedBox(height: 5),
      Text(
        text,
        style: TextStyle(
          color: managerColor.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
  Widget _upcomingAppointments() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.height(15, context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch hẹn sắp tới',
                style: TextStyle(
                  color: managerColor.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: () {
                  sendPushMessage(token);
                },
                icon: Icon(Icons.notifications),
              ),
              if (upcomingAppointments.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: managerColor.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            height: 2,
            width: UtilsReponsive.width(100, context),
            decoration: BoxDecoration(
              color: managerColor.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 12),
          if (isLoadingAppointments)
            SizedBox(
              height: UtilsReponsive.height(120, context),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    managerColor.primary,
                  ),
                ),
              ),
            )
          else if (upcomingAppointments.isEmpty)
            Container(
              height: UtilsReponsive.height(120, context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có lịch hẹn nào',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: UtilsReponsive.height(120, context),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  vertical: UtilsReponsive.height(8, context),
                ),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: upcomingAppointments.length,
                separatorBuilder:
                    (context, index) =>
                        SizedBox(width: UtilsReponsive.width(12, context)),
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(
                    appointment: upcomingAppointments[index],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({required Appointment appointment}) {
    return GestureDetector(
      onTap: () => _showAppointmentDetail(appointment),
      child: Container(
        width: UtilsReponsive.width(180, context),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _getAppointmentColor(appointment.type).withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _getAppointmentColor(appointment.type).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon và type
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getAppointmentColor(
                      appointment.type,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAppointmentIcon(appointment.type),
                    color: _getAppointmentColor(appointment.type),
                    size: 16,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.typeDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getAppointmentColor(appointment.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Title
            Text(
              appointment.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),

            // Date & Time
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${_formatDate(appointment.dateTime)} - ${_formatTime(appointment.dateTime)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetail(Appointment appointment) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getAppointmentColor(appointment.type),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getAppointmentIcon(appointment.type),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                appointment.typeDisplayName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thời gian
                          _buildDetailRow(
                            icon: Icons.access_time,
                            label: 'Thời gian',
                            value:
                                '${_formatDate(appointment.dateTime)} - ${_formatTime(appointment.dateTime)}',
                            color: Colors.blue.shade600,
                          ),

                          // Địa điểm
                          if (appointment.location != null &&
                              appointment.location!.isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.location_on,
                              label: 'Địa điểm',
                              value: appointment.location!,
                              color: Colors.green.shade600,
                            ),

                          // Bác sĩ
                          if (appointment.doctorName != null &&
                              appointment.doctorName!.isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.person,
                              label: 'Bác sĩ',
                              value: appointment.doctorName!,
                              color: Colors.orange.shade600,
                            ),

                          // Mô tả
                          if (appointment.description.isNotEmpty) ...[
                            SizedBox(height: 16),
                            Text(
                              'Mô tả',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                appointment.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],

                          // Ghi chú
                          if (appointment.notes != null &&
                              appointment.notes!.isNotEmpty) ...[
                            SizedBox(height: 16),
                            Text(
                              'Ghi chú',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
                              ),
                              child: Text(
                                appointment.notes!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.amber.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],

                          // Nhắc nhở
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 20,
                                color:
                                    appointment.isReminder
                                        ? Colors.amber.shade600
                                        : Colors.grey.shade400,
                              ),
                              SizedBox(width: 8),
                              Text(
                                appointment.isReminder
                                    ? 'Nhắc nhở ${appointment.reminderMinutes} phút trước'
                                    : 'Không có nhắc nhở',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      appointment.isReminder
                                          ? Colors.amber.shade700
                                          : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getAppointmentColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.KHAM_BENH:
        return Colors.red.shade600;
      case AppointmentType.NHAC_NHO:
        return Colors.blue.shade600;
      case AppointmentType.KHAC:
        return Colors.green.shade600;
    }
  }

  IconData _getAppointmentIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.KHAM_BENH:
        return Icons.medical_services;
      case AppointmentType.NHAC_NHO:
        return Icons.notifications;
      case AppointmentType.KHAC:
        return Icons.event;
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

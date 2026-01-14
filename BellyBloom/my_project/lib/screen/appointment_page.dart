import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/model/appointment.dart';
import 'package:my_project/model/reminder_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/screen/appointment_form_page.dart';
import 'package:my_project/service/appointment_service.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/service/reminder_service.dart';
import 'package:my_project/utils/util_common.dart';
import 'package:my_project/widgets/appointment_card.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage>
    with TickerProviderStateMixin {
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  AppointmentType? _selectedFilter;
  late TabController _tabController;

  // Calendar view state
  bool _isCalendarView = false;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Reminders state
  Map<int, List<ReminderModel>> _remindersByWeek =
      {}; // Map weekNumber -> reminders
  Set<String> _convertedReminderIds =
      {}; // Danh sách reminder đã được convert thành appointment

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadConvertedReminders();
    _loadAppointments();
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointments = await AppointmentService.getAppointments();
      log('loadAppointments: ${appointments.length}');
      for (var appointment in appointments) {
        log('appointment: ${appointment.toJson()}');
      }
      setState(() {
        _appointments = appointments;
        _filteredAppointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Lỗi khi tải dữ liệu: $e');
    }
  }

  // Load danh sách reminder đã convert từ SharedPreferences
  Future<void> _loadConvertedReminders() async {
    try {
      final prefs = BaseCommon().prefs;
      final convertedIds = prefs.getStringList('converted_reminder_ids') ?? [];
      setState(() {
        _convertedReminderIds = convertedIds.toSet();
      });
    } catch (e) {
      log('Error loading converted reminders: $e');
    }
  }

  // Lưu reminder ID vào danh sách đã convert
  Future<void> _saveConvertedReminder(String reminderId) async {
    try {
      _convertedReminderIds.add(reminderId);
      final prefs = BaseCommon().prefs;
      await prefs.setStringList(
        'converted_reminder_ids',
        _convertedReminderIds.toList(),
      );
    } catch (e) {
      log('Error saving converted reminder: $e');
    }
  }

  Future<void> _loadReminders() async {
    try {
      final reminders = await ReminderService.loadReminders();
      setState(() {
        // Group reminders by week number và filter những reminder đã convert
        _remindersByWeek = {};
        for (var reminder in reminders) {
          // Bỏ qua reminder đã được convert
          if (reminder.id != null &&
              _convertedReminderIds.contains(reminder.id)) {
            continue;
          }

          if (!_remindersByWeek.containsKey(reminder.weekNumber)) {
            _remindersByWeek[reminder.weekNumber] = [];
          }
          _remindersByWeek[reminder.weekNumber]!.add(reminder);
        }
      });
    } catch (e) {
      log('Error loading reminders: $e');
    }
  }

  // Kiểm tra xem một ngày có reminder không
  bool _hasReminderForDate(DateTime date) {
    final formCollection = BaseCommon().userAccount.formCollection;
    if (formCollection == null) return false;

    // Tính tuần thai kỳ cho ngày này
    final weekNumber = UtilsCommon.getWeekForDate(
      formCollection.createdAt,
      formCollection.week,
      date,
    );

    // Kiểm tra xem có reminder cho tuần này không
    return _remindersByWeek.containsKey(weekNumber) &&
        _remindersByWeek[weekNumber]!.isNotEmpty;
  }

  // Lấy reminders cho một ngày cụ thể
  List<ReminderModel> _getRemindersForDate(DateTime date) {
    final formCollection = BaseCommon().userAccount.formCollection;
    if (formCollection == null) return [];

    // Tính tuần thai kỳ cho ngày này
    final weekNumber = UtilsCommon.getWeekForDate(
      formCollection.createdAt,
      formCollection.week,
      date,
    );

    // Trả về reminders cho tuần này
    return _remindersByWeek[weekNumber] ?? [];
  }

  void _filterAppointments() {
    setState(() {
      _filteredAppointments =
          _appointments.where((appointment) {
            // Filter by search query
            final matchesSearch =
                _searchQuery.isEmpty ||
                appointment.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                appointment.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (appointment.location?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (appointment.doctorName?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);

            // Filter by type
            final matchesType =
                _selectedFilter == null || appointment.type == _selectedFilter;

            return matchesSearch && matchesType;
          }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _showAddAppointmentPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AppointmentFormPage()),
    );

    // Reload dữ liệu nếu có thay đổi
    if (result == true) {
      _loadAppointments();
    }
  }

  Future<void> _showEditAppointmentPage(Appointment appointment) async {
    log('showEditAppointmentPage: ${appointment.toJson()}');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentFormPage(appointment: appointment),
      ),
    );

    // Reload dữ liệu nếu có thay đổi
    if (result == true) {
      _loadAppointments();
    }
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa lịch hẹn "${appointment.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirmed == true && appointment.id != null) {
      try {
        final success = await AppointmentService.deleteAppointment(
          appointment.id!,
        );
        if (success) {
          setState(() {
            _appointments.removeWhere((a) => a.id == appointment.id);
          });
          _filterAppointments();
          _showSuccessSnackBar('Xóa lịch hẹn thành công!');
        } else {
          _showErrorSnackBar('Lỗi khi xóa lịch hẹn');
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi khi xóa lịch hẹn: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search and Filter - chỉ hiển thị khi không phải calendar view
            if (!_isCalendarView) _buildSearchAndFilter(),

            // Tab Bar - chỉ hiển thị khi không phải calendar view
            if (!_isCalendarView) _buildTabBar(),

            // Content
            Expanded(
              child:
                  _isLoading
                      ? _buildLoadingWidget()
                      : _isCalendarView
                      ? _buildCalendarView()
                      : _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentPage,
        backgroundColor: managerColor.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: managerColor.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch hẹn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: UtilsReponsive.formatFontSize(24, context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Quản lý lịch khám và nhắc nhở',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: UtilsReponsive.formatFontSize(14, context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Switch để đổi chế độ
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.view_list,
                  color:
                      _isCalendarView
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: _isCalendarView,
                    onChanged: (value) {
                      setState(() {
                        _isCalendarView = value;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: managerColor.primary.withOpacity(0.5),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.calendar_month,
                  color:
                      _isCalendarView
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterAppointments();
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm lịch hẹn...',
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: managerColor.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', null),
                SizedBox(width: 8),
                _buildFilterChip('Khám bệnh', AppointmentType.KHAM_BENH),
                SizedBox(width: 8),
                _buildFilterChip('Nhắc nhở', AppointmentType.NHAC_NHO),
                SizedBox(width: 8),
                _buildFilterChip('Khác', AppointmentType.KHAC),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AppointmentType? type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
        _filterAppointments();
      },
      selectedColor: managerColor.primary.withOpacity(0.2),
      checkmarkColor: managerColor.primary,
      labelStyle: TextStyle(
        color: isSelected ? managerColor.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: managerColor.primary,
          borderRadius: BorderRadius.circular(15),
        ),
        indicatorSize: TabBarIndicatorSize.tab, // Quan trọng: chiếm toàn bộ tab
        dividerColor: Colors.transparent, // Ẩn divider mặc định
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        tabs: [
          Tab(text: 'Tất cả'),
          Tab(text: 'Hôm nay'),
          Tab(text: 'Sắp tới'),
          Tab(text: 'Đã qua'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAppointmentList(_filteredAppointments),
        _buildAppointmentList(
          _filteredAppointments.where((a) => a.isToday).toList(),
        ),
        _buildAppointmentList(
          _filteredAppointments.where((a) => a.isUpcoming).toList(),
        ),
        _buildAppointmentList(
          _filteredAppointments.where((a) => a.isPast).toList(),
        ),
      ],
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadAppointments();
        await _loadReminders();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return AppointmentCard(
            appointment: appointment,
            onEdit: () => _showEditAppointmentPage(appointment),
            onDelete: () => _deleteAppointment(appointment),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có lịch hẹn nào',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(18, context),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm lịch hẹn mới',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(14, context),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(managerColor.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(16, context),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Lấy danh sách appointments theo ngày
  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _filteredAppointments.where((appointment) {
      return isSameDay(appointment.dateTime, day);
    }).toList();
  }

  // Helper method để convert events thành List<Appointment> an toàn
  List<Appointment> _getEventsAsList(dynamic events) {
    if (events == null) return [];
    if (events is List) {
      return events.whereType<Appointment>().cast<Appointment>().toList();
    }
    return [];
  }

  // Widget Calendar View
  Widget _buildCalendarView() {
    final selectedDayAppointments = _getAppointmentsForDay(_selectedDay);
    final selectedDayReminders = _getRemindersForDate(_selectedDay);

    return Column(
      children: [
        // Calendar
        Container(
          margin: EdgeInsets.all(16),
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
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getAppointmentsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: managerColor.primary),
              selectedDecoration: BoxDecoration(
                color: managerColor.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: managerColor.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: managerColor.primary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 6,
              markerMargin: EdgeInsets.symmetric(horizontal: 0.5),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: managerColor.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              leftChevronPadding: EdgeInsets.all(8),
              rightChevronPadding: EdgeInsets.all(8),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: managerColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            // Custom marker cho các ngày có appointment và reminder
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final appointments = _getEventsAsList(events);
                final hasReminder = _hasReminderForDate(date);

                // Nếu có cả appointment và reminder, hiển thị cả hai
                if (appointments.isNotEmpty && hasReminder) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Appointment marker
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getAppointmentTypeColor(
                              appointments.first.type,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2),
                        // Reminder marker (dấu sao)
                        Icon(
                          Icons.star,
                          size: 10,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  );
                } else if (appointments.isNotEmpty) {
                  // Chỉ có appointment
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getAppointmentTypeColor(
                          appointments.first.type,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                } else if (hasReminder) {
                  // Chỉ có reminder (dấu sao)
                  return Positioned(
                    bottom: 1,
                    child: Icon(
                      Icons.star,
                      size: 10,
                      color: Colors.orange.shade700,
                    ),
                  );
                }
                return SizedBox.shrink();
              },
              todayBuilder: (context, date, events) {
                final appointments = _getEventsAsList(events);
                final hasEvents = appointments.isNotEmpty;
                return Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        hasEvents
                            ? managerColor.primary.withOpacity(0.7)
                            : managerColor.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border:
                        hasEvents
                            ? Border.all(color: managerColor.primary, width: 2)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, date, events) {
                final appointments = _getEventsAsList(events);
                final hasEvents = appointments.isNotEmpty;
                return Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: managerColor.primary,
                    shape: BoxShape.circle,
                    border:
                        hasEvents
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Danh sách appointments và reminders của ngày được chọn
        if (selectedDayAppointments.isNotEmpty ||
            selectedDayReminders.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedDayAppointments.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.event, color: managerColor.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '${selectedDayAppointments.length} lịch hẹn ngày ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(16, context),
                          fontWeight: FontWeight.bold,
                          color: managerColor.primary,
                        ),
                      ),
                    ],
                  ),
                if (selectedDayAppointments.isNotEmpty &&
                    selectedDayReminders.isNotEmpty)
                  SizedBox(height: 8),
                if (selectedDayReminders.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange.shade700, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '${selectedDayReminders.length} nhắc hẹn quan trọng',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(16, context),
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadAppointments();
                await _loadReminders();
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount:
                    selectedDayAppointments.length +
                    selectedDayReminders.length,
                itemBuilder: (context, index) {
                  // Hiển thị appointments trước
                  if (index < selectedDayAppointments.length) {
                    final appointment = selectedDayAppointments[index];
                    return AppointmentCard(
                      appointment: appointment,
                      onEdit: () => _showEditAppointmentPage(appointment),
                      onDelete: () => _deleteAppointment(appointment),
                    );
                  } else {
                    // Sau đó hiển thị reminders
                    final reminderIndex =
                        index - selectedDayAppointments.length;
                    final reminder = selectedDayReminders[reminderIndex];
                    return _buildReminderCard(reminder);
                  }
                },
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    'Không có lịch hẹn nào',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(18, context),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ngày ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Helper để lấy màu theo loại appointment
  Color _getAppointmentTypeColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.KHAM_BENH:
        return Colors.red.shade600;
      case AppointmentType.NHAC_NHO:
        return Colors.blue.shade600;
      case AppointmentType.KHAC:
        return Colors.green.shade600;
    }
  }

  // Widget để hiển thị reminder card
  Widget _buildReminderCard(ReminderModel reminder) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.height(15, context),
        vertical: UtilsReponsive.height(8, context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: reminder.priorityColor.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: reminder.priorityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.height(15, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: reminder.priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.star,
                    color: reminder.priorityColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(16, context),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: reminder.priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reminder.priorityDisplayName,
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(
                                  11,
                                  context,
                                ),
                                color: reminder.priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tuần ${reminder.weekNumber}',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(
                                  11,
                                  context,
                                ),
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reminder.description.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                reminder.description,
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(14, context),
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 12),
            // Nút "Tạo nhắc hẹn"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateAppointmentDialog(reminder),
                icon: Icon(Icons.add_alarm, size: 18),
                label: Text('Tạo nhắc hẹn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: managerColor.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog để chọn ngày và giờ trong tuần đó
  Future<void> _showCreateAppointmentDialog(ReminderModel reminder) async {
    final formCollection = BaseCommon().userAccount.formCollection;
    if (formCollection == null) {
      _showErrorSnackBar('Vui lòng cập nhật thông tin thai kỳ');
      return;
    }

    // Tính toán tuần bắt đầu và kết thúc của reminder
    final weekStartDate = _getWeekStartDate(
      reminder.weekNumber,
      formCollection.createdAt,
      formCollection.week,
    );
    final weekEndDate = weekStartDate.add(Duration(days: 6));

    DateTime? selectedDate;
    TimeOfDay? selectedTime = TimeOfDay.now();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.calendar_today, color: managerColor.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tạo nhắc hẹn',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              18,
                              context,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              16,
                              context,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Chọn ngày và giờ trong tuần ${reminder.weekNumber}',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              14,
                              context,
                            ),
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Từ ${DateFormat('dd/MM/yyyy').format(weekStartDate)} đến ${DateFormat('dd/MM/yyyy').format(weekEndDate)}',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              12,
                              context,
                            ),
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Chọn ngày
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? weekStartDate,
                              firstDate: weekStartDate,
                              lastDate: weekEndDate,
                              helpText:
                                  'Chọn ngày trong tuần ${reminder.weekNumber}',
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: managerColor.primary,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: managerColor.primary,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ngày',
                                        style: TextStyle(
                                          fontSize:
                                              UtilsReponsive.formatFontSize(
                                                12,
                                                context,
                                              ),
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        selectedDate != null
                                            ? DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(selectedDate!)
                                            : 'Chọn ngày',
                                        style: TextStyle(
                                          fontSize:
                                              UtilsReponsive.formatFontSize(
                                                14,
                                                context,
                                              ),
                                          fontWeight: FontWeight.w600,
                                          color:
                                              selectedDate != null
                                                  ? Colors.black
                                                  : Colors.grey.shade400,
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
                        ),

                        SizedBox(height: 16),

                        // Chọn giờ
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                              helpText: 'Chọn giờ',
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: managerColor.primary,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: managerColor.primary,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Giờ',
                                        style: TextStyle(
                                          fontSize:
                                              UtilsReponsive.formatFontSize(
                                                12,
                                                context,
                                              ),
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        selectedTime != null
                                            ? selectedTime!.format(context)
                                            : 'Chọn giờ',
                                        style: TextStyle(
                                          fontSize:
                                              UtilsReponsive.formatFontSize(
                                                14,
                                                context,
                                              ),
                                          fontWeight: FontWeight.w600,
                                          color:
                                              selectedTime != null
                                                  ? Colors.black
                                                  : Colors.grey.shade400,
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
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed:
                          selectedDate != null && selectedTime != null
                              ? () => Navigator.of(context).pop(true)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: managerColor.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
          ),
    );

    if (result == true && selectedDate != null && selectedTime != null) {
      await _createAppointmentFromReminder(
        reminder,
        selectedDate!,
        selectedTime!,
      );
    }
  }

  // Tính toán ngày bắt đầu của tuần thai kỳ
  DateTime _getWeekStartDate(
    int weekNumber,
    DateTime createdAt,
    int initialWeek,
  ) {
    // Tính số ngày từ tuần ban đầu đến tuần hiện tại
    final daysFromStart = (weekNumber - initialWeek) * 7;
    final weekStartDate = createdAt.add(Duration(days: daysFromStart));

    // Làm tròn về đầu tuần (Thứ 2)
    final weekday = weekStartDate.weekday;
    final daysToMonday = (weekday - 1) % 7;
    return weekStartDate.subtract(Duration(days: daysToMonday));
  }

  // Tạo appointment từ reminder
  Future<void> _createAppointmentFromReminder(
    ReminderModel reminder,
    DateTime selectedDate,
    TimeOfDay selectedTime,
  ) async {
    try {
      // Tạo DateTime từ selectedDate và selectedTime
      final appointmentDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Tạo Appointment từ Reminder
      final appointment = Appointment(
        title: reminder.title,
        description: reminder.description,
        dateTime: appointmentDateTime,
        type: AppointmentType.NHAC_NHO,
        isReminder: true,
        reminderMinutes: 30, // Mặc định 30 phút
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Lưu appointment
      final appointmentId = await AppointmentService.addAppointment(
        appointment,
      );

      if (appointmentId != null) {
        // Lưu reminder ID vào danh sách đã convert
        if (reminder.id != null) {
          await _saveConvertedReminder(reminder.id!);
        }

        // Reload data
        await _loadAppointments();
        await _loadReminders();

        _showSuccessSnackBar('Đã tạo nhắc hẹn thành công!');
      } else {
        _showErrorSnackBar('Lỗi khi tạo nhắc hẹn');
      }
    } catch (e) {
      log('Error creating appointment from reminder: $e');
      _showErrorSnackBar('Lỗi: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/image_manager.dart';
import 'package:my_project/model/diary.dart';
import 'package:my_project/model/hand_book.dart';
import 'package:my_project/model/my_note.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/screen/Diary_detail.dart';
import 'package:my_project/screen/handbook_detail.dart.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  final int _chunkSize = 14;
  int _selectedIndex = 0;
  final List<DateTime> _dates = [];
  final ScrollController _scrollController = ScrollController();
  List<MyNote> _myNotes = [];
  List<HandBook> _handbook = [];
  List<Diary> _diary = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _appendNextChunk();
    _scrollController.addListener(_onScroll);

    _fetchMyNotes();
    fetchHandbook();
    fetchDiary();

    _tabController = TabController(length: 3, vsync: this);
  }

  void _onScroll() {
    // Load more when nearing the end of the list
    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <
        200) {
      _appendNextChunk();
    }
  }

  void fetchHandbook() {
    setState(() {
      _handbook = [
        HandBook(id: 1, title: 'title1', content: 'content1'),
        HandBook(id: 2, title: 'title2', content: 'content2'),
        HandBook(id: 3, title: 'title3', content: 'content3'),
        HandBook(id: 4, title: 'title4', content: 'content4'),
        HandBook(id: 5, title: 'title5', content: 'content5'),
        HandBook(id: 6, title: 'title6', content: 'content6'),
        HandBook(id: 7, title: 'title7', content: 'content7'),
      ];
    });
  }

  void fetchDiary() {
    setState(() {
      _diary = [
        Diary(
          id: 1,
          title: 'Diary1',
          content:
              'Manage your tasks, set reminders, and stay organized with our app.',
          date: DateTime.now(),
        ),
        Diary(
          id: 2,
          title: 'Diary2',
          content:
              'Manage your tasks, set reminders, and stay organized with our app.',
          date: DateTime.now(),
        ),
        Diary(id: 3, title: 'Diary3', content: 'Diary3', date: DateTime.now()),
        Diary(id: 4, title: 'Diary4', content: 'Diary4', date: DateTime.now()),
        Diary(id: 5, title: 'Diary5', content: 'Diary5', date: DateTime.now()),
      ];
    });
  }

  void _fetchMyNotes() {
    setState(() {
      _myNotes = [
        MyNote(
          id: 1,
          title: 'My note 1',
          content: 'Content 1',
          date: DateTime.now(),
        ),
        MyNote(
          id: 1,
          title: 'My note 2',
          content: 'Content 2',
          date: DateTime.now(),
        ),
        MyNote(
          id: 1,
          title: 'My note 3',
          content: 'Content 3',
          date: DateTime.now(),
        ),
        MyNote(
          id: 1,
          title: 'My note 3',
          content: 'Content 3',
          date: DateTime.now(),
        ),
      ];
    });
  }

  void _appendNextChunk() {
    final DateTime start = _dates.isEmpty
        ? DateTime.now()
        : _dates.last.add(const Duration(days: 1));
    final List<DateTime> next = List.generate(
      _chunkSize,
      (i) => start.add(Duration(days: i)),
    );
    setState(() {
      _dates.addAll(next);
    });
  }

  String _weekdayShort(DateTime date) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = date.weekday; // 1..7
    return names[(weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _dates.isEmpty
        ? DateTime.now()
        : _dates[_selectedIndex.clamp(0, _dates.length - 1)];
    final monthNames = const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              _calendarScroll(selectedDate, monthNames),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: managerColor.primary),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelStyle: TextStyle(
                    color: managerColor.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  indicatorColor: managerColor.primary,
                  dividerColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.height(10, context),
                    vertical: UtilsReponsive.height(10, context),
                  ),
                  tabs: [
                    Container(
                      child: Column(
                        children: [
                          Image.asset(
                            ImageRes.logo,
                            height: UtilsReponsive.height(34, context),
                          ),
                          Text('Lich nhac'),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Image.asset(
                            ImageRes.logo,
                            height: UtilsReponsive.height(34, context),
                          ),
                          Text('Cam nang'),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Image.asset(
                            ImageRes.logo,
                            height: UtilsReponsive.height(34, context),
                          ),
                          Text('Nhat ky'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMynote(),
                    _buildHandbook(),
                    SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: ListView.separated(
                        itemCount: _diary.length,
                        itemBuilder: (context, index) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MyDiaryPage(diary: _diary[index]),
                                ),
                              );
                            },
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'HH:mm',
                                  ).format(_diary[index].date),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(_diary[index].title),
                              ],
                            ),
                            subtitle: Text(
                              _diary[index].content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: Container(
                              height: 80,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: managerColor.primary,
                                  width: 2,
                                ),
                              ),
                              child: Image.asset(ImageRes.welcome1),
                            ),
                          ),
                        ),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _buildHandbook() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: ListView.separated(
        itemCount: _handbook.length,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HandbookDetailPage(handBook: _handbook[index]),
                ),
              );
            },

            title: Text(
              _handbook[index].title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: managerColor.primary,
              ),
            ),
            subtitle: Text(_handbook[index].content),
            leading: Image.asset(ImageRes.logo),
          ),
        ),
        separatorBuilder: (context, index) => SizedBox(height: 10),
      ),
    );
  }

  SizedBox _buildMynote() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                _ShowDialogMynote();
              },
              icon: Container(
                decoration: BoxDecoration(
                  color: managerColor.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('Add'), Icon(Icons.add)],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) => ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('HH:mm').format(_myNotes[index].date)),
                    Text(_myNotes[index].title),
                  ],
                ),
                subtitle: Text(_myNotes[index].content),
                leading: Icon(Icons.book),
              ),
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: _myNotes.length,
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _ShowDialogMynote() {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Them lich nhac',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: managerColor.primary,
                  fontSize: 24,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tieu de',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.pink.shade100,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: UtilsReponsive.height(10, context)),
              TextField(
                maxLines: 6,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: 'Noi dung',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.pink.shade100,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: managerColor.primary,
                      ),
                      child: Text(
                        'Thêm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _calendarScroll(DateTime selectedDate, List<String> monthNames) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${selectedDate.day}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthNames[selectedDate.month - 1],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 86,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = index == _selectedIndex;
              final bool showMonthInline = index == 0 || date.day == 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? managerColor.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayShort(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      showMonthInline
                          ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${date.day}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/${date.month}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 18,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

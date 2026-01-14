import 'package:flutter/material.dart';
import 'package:my_project/model/blog_model.dart';
import 'package:my_project/model/exercise_model.dart';
import 'package:my_project/model/pregnancy_week_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/screen/blog_detail_page.dart';
import 'package:my_project/screen/exercise_detail_page.dart';
import 'package:my_project/screen/pregnancy_week_detail_page.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/service/blog_service.dart';
import 'package:my_project/service/exercise_service.dart';
import 'package:my_project/service/pregnancy_week_service.dart';
import 'package:my_project/utils/util_common.dart';
import 'package:my_project/widgets/blog_card.dart';
import 'package:my_project/widgets/exercise_card.dart';

class GuidePage extends StatefulWidget {
  final int? initialTab; // 0 = blogs, 1 = exercises
  final int? initialWeek; // Tuần để filter

  const GuidePage({super.key, this.initialTab, this.initialWeek});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BlogModel> blogs = [];
  List<ExerciseModel> exercises = [];
  bool isLoadingBlogs = true;
  bool isLoadingExercises = true;
  int currentWeek = 0;
  int selectedWeek = 0; // Tuần được chọn để filter
  bool isFilteringByWeek = false; // Có đang filter theo tuần không
  PregnancyWeekModel? currentWeekInfo; // Thông tin tuần thai kỳ hiện tại
  PregnancyWeekModel? selectedWeekInfo; // Thông tin tuần được chọn
  bool isLoadingWeekInfo = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentWeek();

    // Set initial tab nếu có
    if (widget.initialTab != null && widget.initialTab! < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController.animateTo(widget.initialTab!);
      });
    }

    // Set initial week filter nếu có
    if (widget.initialWeek != null) {
      selectedWeek = widget.initialWeek!;
      isFilteringByWeek = true;
    }

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _getCurrentWeek() {
    final formCollection = BaseCommon().userAccount.formCollection;
    if (formCollection != null) {
      // Tính toán tuần hiện tại dựa trên logic ở trang chủ
      // Sử dụng UtilsCommon.getCurrentWeekInPregnancy giống như trang chủ
      currentWeek = UtilsCommon.getCurrentWeekInPregnancy(
        formCollection.createdAt,
        formCollection.week,
      );
    } else {
      // Fallback về 0 nếu chưa có thông tin
      currentWeek = 0;
    }
    selectedWeek = currentWeek; // Mặc định chọn tuần hiện tại
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadBlogs(),
      _loadExercises(),
      _loadPregnancyWeekInfo(),
    ]);
  }

  Future<void> _loadPregnancyWeekInfo() async {
    setState(() {
      isLoadingWeekInfo = true;
    });

    try {
      final weekToLoad =
          isFilteringByWeek && selectedWeek > 0
              ? selectedWeek
              : currentWeek > 0
              ? currentWeek
              : 0;

      if (weekToLoad > 0) {
        final weekInfo = await PregnancyWeekService.getPregnancyWeek(
          weekToLoad,
        );
        setState(() {
          if (isFilteringByWeek) {
            selectedWeekInfo = weekInfo;
          } else {
            currentWeekInfo = weekInfo;
          }
        });
      }
    } catch (e) {
      print('Error loading pregnancy week info: $e');
    } finally {
      setState(() {
        isLoadingWeekInfo = false;
      });
    }
  }

  Future<void> _loadBlogs() async {
    setState(() {
      isLoadingBlogs = true;
    });

    try {
      if (isFilteringByWeek && selectedWeek > 0) {
        blogs = await BlogService.loadBlogsForWeek(selectedWeek);
      } else if (currentWeek > 0) {
        blogs = await BlogService.loadBlogsForWeek(currentWeek);
      } else {
        blogs = await BlogService.loadBlogs();
      }
    } catch (e) {
      print('Error loading blogs: $e');
    } finally {
      setState(() {
        isLoadingBlogs = false;
      });
    }
  }

  Future<void> _loadExercises() async {
    setState(() {
      isLoadingExercises = true;
    });

    try {
      if (isFilteringByWeek && selectedWeek > 0) {
        exercises = await ExerciseService.loadExercisesForWeek(selectedWeek);
      } else if (currentWeek > 0) {
        exercises = await ExerciseService.loadExercisesForWeek(currentWeek);
      } else {
        exercises = await ExerciseService.loadExercises();
      }
    } catch (e) {
      print('Error loading exercises: $e');
    } finally {
      setState(() {
        isLoadingExercises = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Cẩm nang thai kỳ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: managerColor.primary,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(icon: Icon(Icons.article_outlined), text: 'Cẩm nang'),
            Tab(icon: Icon(Icons.fitness_center_outlined), text: 'Bài tập'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Week info header
          if (currentWeek > 0 || (isFilteringByWeek && selectedWeek > 0))
            _buildWeekInfo(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildBlogsTab(), _buildExercisesTab()],
            ),
          ),
        ],
      ),
    );
  }

  void _showWeekSelectorDialog() {
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
                      color: managerColor.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Chọn tuần thai kỳ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                        children: [
                          // Current week option
                          if (currentWeek > 0) ...[
                            _buildWeekOption(
                              week: currentWeek,
                              isCurrent: true,
                              isSelected: !isFilteringByWeek,
                              onTap: () {
                                setState(() {
                                  isFilteringByWeek = false;
                                  selectedWeek = currentWeek;
                                  selectedWeekInfo = null;
                                });
                                Navigator.of(context).pop();
                                _loadData();
                              },
                            ),
                            SizedBox(height: 16),
                            Divider(),
                            SizedBox(height: 16),
                          ],

                          // Other weeks
                          Text(
                            'Chọn tuần khác:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Week grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: 40,
                            itemBuilder: (context, index) {
                              final week = index + 1;
                              final isSelected =
                                  isFilteringByWeek && selectedWeek == week;

                              return _buildWeekGridItem(
                                week: week,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    isFilteringByWeek = true;
                                    selectedWeek = week;
                                    selectedWeekInfo = null;
                                  });
                                  Navigator.of(context).pop();
                                  _loadData();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  if (isFilteringByWeek)
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  isFilteringByWeek = false;
                                  selectedWeek = currentWeek;
                                  selectedWeekInfo = null;
                                });
                                Navigator.of(context).pop();
                                _loadData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.grey.shade700,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.clear, size: 16),
                              label: Text('Xem tuần hiện tại'),
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

  Widget _buildWeekOption({
    required int week,
    required bool isCurrent,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? managerColor.primary.withOpacity(0.1)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? managerColor.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrent ? managerColor.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$week',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tuần $week',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (isCurrent)
                    Text(
                      'Tuần thai kỳ hiện tại',
                      style: TextStyle(
                        fontSize: 12,
                        color: managerColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: managerColor.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekGridItem({
    required int week,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? managerColor.primary : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? managerColor.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekInfo() {
    final weekInfo = isFilteringByWeek ? selectedWeekInfo : currentWeekInfo;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            managerColor.primary.withOpacity(0.1),
            managerColor.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: managerColor.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main row - click để chọn tuần
          GestureDetector(
            onTap: () => _showWeekSelectorDialog(),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: managerColor.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pregnant_woman,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFilteringByWeek
                            ? 'Đang xem tuần'
                            : 'Tuần thai kỳ hiện tại',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        isFilteringByWeek
                            ? 'Tuần $selectedWeek'
                            : 'Tuần $currentWeek',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: managerColor.primary,
                        ),
                      ),
                      if (weekInfo != null && weekInfo.title.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          weekInfo.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: managerColor.primary,
                  size: 24,
                ),
              ],
            ),
          ),
          // Description và button xem chi tiết
          if (weekInfo != null && weekInfo.description.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: managerColor.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      weekInfo.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Button xem chi tiết
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => PregnancyWeekDetailPage(week: weekInfo),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: managerColor.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.visibility, size: 18),
                label: Text('Xem chi tiết tuần thai kỳ'),
              ),
            ),
          ],
          if (isLoadingWeekInfo) ...[
            SizedBox(height: 8),
            SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(managerColor.primary),
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlogsTab() {
    if (isLoadingBlogs) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(managerColor.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải cẩm nang...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (blogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              isFilteringByWeek
                  ? 'Chưa có cẩm nang cho tuần $selectedWeek'
                  : currentWeek > 0
                  ? 'Chưa có cẩm nang cho tuần $currentWeek'
                  : 'Chưa có cẩm nang nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              isFilteringByWeek
                  ? 'Thử chọn tuần khác hoặc bỏ lọc để xem tất cả nội dung'
                  : currentWeek > 0
                  ? 'Hãy cập nhật thông tin tuần thai kỳ để xem nội dung phù hợp'
                  : 'Hãy cập nhật thông tin tuần thai kỳ để xem nội dung phù hợp',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlogs,
      color: managerColor.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: blogs.length,
        itemBuilder: (context, index) {
          return BlogCard(
            blog: blogs[index],
            onTap: () => _showBlogDetail(blogs[index]),
          );
        },
      ),
    );
  }

  Widget _buildExercisesTab() {
    if (isLoadingExercises) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(managerColor.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải bài tập...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              isFilteringByWeek
                  ? 'Chưa có bài tập cho tuần $selectedWeek'
                  : currentWeek > 0
                  ? 'Chưa có bài tập cho tuần $currentWeek'
                  : 'Chưa có bài tập nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              isFilteringByWeek
                  ? 'Thử chọn tuần khác hoặc bỏ lọc để xem tất cả bài tập'
                  : currentWeek > 0
                  ? 'Hãy cập nhật thông tin tuần thai kỳ để xem bài tập phù hợp'
                  : 'Hãy cập nhật thông tin tuần thai kỳ để xem bài tập phù hợp',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExercises,
      color: managerColor.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return ExerciseCard(
            exercise: exercises[index],
            onTap: () => _showExerciseDetail(exercises[index]),
          );
        },
      ),
    );
  }

  void _showBlogDetail(BlogModel blog) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => BlogDetailPage(blog: blog)));
  }

  void _showExerciseDetail(ExerciseModel exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseDetailPage(exercise: exercise),
      ),
    );
  }
}

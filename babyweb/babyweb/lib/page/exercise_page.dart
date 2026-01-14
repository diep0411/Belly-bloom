import 'package:babyweb/model/exercise_model.dart';
import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:babyweb/resource/color_manager.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/exercise_service.dart';
import 'package:babyweb/service/pregnancy_week_service.dart';
import 'package:babyweb/widgets/exercises_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  TextEditingController searchController = TextEditingController();
  List<ExerciseModel> exercises = [];
  List<ExerciseModel> filteredExercises = [];
  bool isLoading = false;
  String selectedCategory = 'Tất cả';
  String selectedDifficulty = 'Tất cả';

  final List<String> categories = [
    'Tất cả',
    'yoga',
    'cardio',
    'strength',
    'breathing',
    'stretching',
    'pelvic',
  ];

  final List<String> difficulties = [
    'Tất cả',
    'beginner',
    'intermediate',
    'advanced',
  ];

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  void loadExercises() async {
    setState(() {
      isLoading = true;
    });
    
    exercises = await ExerciseService.loadExercises();
    _applyFilters();
    
    setState(() {
      isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      filteredExercises = exercises.where((exercise) {
        bool matchesSearch = searchController.text.isEmpty ||
            exercise.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
            exercise.description.toLowerCase().contains(searchController.text.toLowerCase()) ||
            exercise.category.toLowerCase().contains(searchController.text.toLowerCase());
        
        bool matchesCategory = selectedCategory == 'Tất cả' ||
            exercise.category == selectedCategory;
        
        bool matchesDifficulty = selectedDifficulty == 'Tất cả' ||
            exercise.difficulty == selectedDifficulty;
        
        return matchesSearch && matchesCategory && matchesDifficulty;
      }).toList();
    });
  }

  void _filterExercises(String query) {
    _applyFilters();
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
          _buildSearchAndCreateSection(),
          SizedBox(height: UtilsReponsive.height(24, context)),
          _buildFiltersSection(),
          SizedBox(height: UtilsReponsive.height(24, context)),
          Expanded(child: _buildExercisesList()),
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
            Icons.fitness_center,
            color: ColorManager.primary,
            size: UtilsReponsive.formatFontSize(24, context),
          ),
        ),
        SizedBox(width: UtilsReponsive.width(16, context)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý bài tập bà bầu',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(28, context),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'Quản lý các bài tập yoga, thể dục cho bà bầu',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.width(16, context),
            vertical: UtilsReponsive.height(8, context),
          ),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${exercises.length} bài tập',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(12, context),
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndCreateSection() {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: searchController,
                onChanged: _filterExercises,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài tập...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(16, context),
                    vertical: UtilsReponsive.height(12, context),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(16, context)),
          ElevatedButton.icon(
            onPressed: () {
              _showCreateEditDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(20, context),
                vertical: UtilsReponsive.height(12, context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(Icons.add, size: UtilsReponsive.formatFontSize(18, context)),
            label: Text(
              'Thêm bài tập',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loại bài tập',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(12, context),
                      vertical: UtilsReponsive.height(8, context),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category == 'Tất cả' ? 'Tất cả' : _getCategoryText(category),
                        style: TextStyle(fontSize: UtilsReponsive.formatFontSize(12, context)),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: UtilsReponsive.width(16, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Độ khó',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                DropdownButtonFormField<String>(
                  value: selectedDifficulty,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(12, context),
                      vertical: UtilsReponsive.height(8, context),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: difficulties.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(
                        difficulty == 'Tất cả' ? 'Tất cả' : _getDifficultyText(difficulty),
                        style: TextStyle(fontSize: UtilsReponsive.formatFontSize(12, context)),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDifficulty = value!;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_outlined,
                size: UtilsReponsive.formatFontSize(48, context),
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            Text(
              exercises.isEmpty ? 'Chưa có bài tập nào' : 'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(18, context),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            Text(
              exercises.isEmpty 
                  ? 'Hãy thêm bài tập đầu tiên'
                  : 'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade500,
              ),
            ),
            if (exercises.isEmpty) ...[
              SizedBox(height: UtilsReponsive.height(24, context)),
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateEditDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(24, context),
                    vertical: UtilsReponsive.height(12, context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.add),
                label: Text('Thêm bài tập đầu tiên'),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: ColorManager.primary,
                  size: UtilsReponsive.formatFontSize(20, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                Text(
                  'Danh sách bài tập',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(16, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Spacer(),
                Text(
                  '${filteredExercises.length} bài tập',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return _buildExerciseCard(exercise);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showCreateEditDialog(exercise: exercise);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Row(
              children: [
                // Image
                Container(
                  width: UtilsReponsive.width(80, context),
                  height: UtilsReponsive.height(80, context),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: exercise.imageUrl.isNotEmpty
                      ? Image.network(
                          exercise.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.fitness_center,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.fitness_center,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
                SizedBox(width: UtilsReponsive.width(16, context)),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.title,
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(16, context),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: exercise.isActive 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise.isActive ? 'Hoạt động' : 'Tạm dừng',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(10, context),
                                color: exercise.isActive 
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: UtilsReponsive.height(4, context)),
                      Text(
                        exercise.description,
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: ColorManager.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise.categoryText,
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(10, context),
                                color: ColorManager.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: UtilsReponsive.width(8, context)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise.difficultyText,
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(10, context),
                                color: _getDifficultyColor(exercise.difficulty),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: UtilsReponsive.width(8, context)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise.durationText,
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(10, context),
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showCreateEditDialog(exercise: exercise);
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: ColorManager.primary,
                      ),
                      tooltip: 'Chỉnh sửa',
                    ),
                    IconButton(
                      onPressed: () {
                        _showDeleteDialog(exercise);
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryText(String category) {
    switch (category.toLowerCase()) {
      case 'yoga':
        return 'Yoga';
      case 'cardio':
        return 'Cardio';
      case 'strength':
        return 'Tăng cường sức mạnh';
      case 'breathing':
        return 'Thở';
      case 'stretching':
        return 'Kéo giãn';
      case 'pelvic':
        return 'Sàn chậu';
      default:
        return category;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      default:
        return 'Cơ bản';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  void _showCreateEditDialog({ExerciseModel? exercise}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExerciseDialog(
        exercise: exercise,
        onSave: () {
          loadExercises();
        },
      ),
    );
  }

  void _showDeleteDialog(ExerciseModel exercise) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Xác nhận xóa'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc chắn muốn xóa bài tập này?'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      exercise.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hành động này không thể hoàn tác!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteExercise(exercise);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteExercise(ExerciseModel exercise) async {
    if (exercise.id == null) return;
    
    try {
      bool success = await ExerciseService.deleteExercise(exercise.id!);
      if (success) {
        loadExercises();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa bài tập thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi xóa bài tập'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi xóa bài tập'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


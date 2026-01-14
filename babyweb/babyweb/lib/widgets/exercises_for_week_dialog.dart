import 'package:babyweb/model/exercise_model.dart';
import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/exercise_service.dart';
import 'package:flutter/material.dart';

// Dialog for showing exercises for a specific week
class ExercisesForWeekDialog extends StatefulWidget {
  final PregnancyWeekModel week;

  const ExercisesForWeekDialog({
    super.key,
    required this.week,
  });

  @override
  State<ExercisesForWeekDialog> createState() => _ExercisesForWeekDialogState();
}

class _ExercisesForWeekDialogState extends State<ExercisesForWeekDialog> {
  List<ExerciseModel> exercises = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExercisesForWeek();
  }

  void _loadExercisesForWeek() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      exercises = await ExerciseService.getExercisesByTargetWeeks([widget.week.weekNumber.toString()]);
    } catch (e) {
      print('Error loading exercises for week: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: UtilsReponsive.formatFontSize(20, context),
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(12, context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bài tập cho Tuần ${widget.week.weekNumber}',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(18, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          widget.week.title,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(12, context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                          SizedBox(height: UtilsReponsive.height(16, context)),
                          Text(
                            'Đang tải bài tập...',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(14, context),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : exercises.isEmpty
                      ? Center(
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
                                'Chưa có bài tập nào',
                                style: TextStyle(
                                  fontSize: UtilsReponsive.formatFontSize(18, context),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: UtilsReponsive.height(8, context)),
                              Text(
                                'Chưa có bài tập nào được gán cho tuần thai kỳ này',
                                style: TextStyle(
                                  fontSize: UtilsReponsive.formatFontSize(14, context),
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return _buildExerciseCard(exercise);
                          },
                        ),
            ),
            
            // Footer
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${exercises.length} bài tập phù hợp',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(12, context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddExerciseDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: UtilsReponsive.width(12, context),
                            vertical: UtilsReponsive.height(8, context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(Icons.add, size: UtilsReponsive.formatFontSize(14, context)),
                        label: Text(
                          'Thêm bài tập',
                          style: TextStyle(fontSize: UtilsReponsive.formatFontSize(12, context)),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(8, context)),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Đóng'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
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
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Row(
          children: [
            // Image
            Container(
              width: UtilsReponsive.width(60, context),
              height: UtilsReponsive.height(60, context),
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
            SizedBox(width: UtilsReponsive.width(12, context)),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: UtilsReponsive.height(4, context)),
                  Text(
                    exercise.description,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(12, context),
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
                          horizontal: UtilsReponsive.width(6, context),
                          vertical: UtilsReponsive.height(2, context),
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(exercise.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCategoryText(exercise.category),
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            color: _getCategoryColor(exercise.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(6, context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(6, context),
                          vertical: UtilsReponsive.height(2, context),
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getDifficultyText(exercise.difficulty),
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            color: _getDifficultyColor(exercise.difficulty),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(6, context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(6, context),
                          vertical: UtilsReponsive.height(2, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                SizedBox(height: UtilsReponsive.height(8, context)),
                IconButton(
                  onPressed: () {
                    _removeExerciseFromWeek(exercise);
                  },
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red.shade400,
                  ),
                  tooltip: 'Loại bỏ khỏi tuần này',
                ),
              ],
            ),
          ],
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
        return 'Tăng cường';
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'yoga':
        return Colors.purple;
      case 'cardio':
        return Colors.red;
      case 'strength':
        return Colors.orange;
      case 'breathing':
        return Colors.blue;
      case 'stretching':
        return Colors.green;
      case 'pelvic':
        return Colors.pink;
      default:
        return Colors.grey;
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

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddExerciseToWeekDialog(
        week: widget.week,
        onExerciseAdded: () {
          _loadExercisesForWeek();
        },
      ),
    );
  }

  void _removeExerciseFromWeek(ExerciseModel exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xác nhận loại bỏ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn loại bỏ bài tập này khỏi tuần thai kỳ?'),
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
              await _removeExercise(exercise);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Loại bỏ'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeExercise(ExerciseModel exercise) async {
    try {
      // Remove the week number from targetWeeks
      List<String> updatedTargetWeeks = List.from(exercise.targetWeeks);
      updatedTargetWeeks.remove(widget.week.weekNumber.toString());
      
      ExerciseModel updatedExercise = exercise.copyWith(
        targetWeeks: updatedTargetWeeks,
        updatedAt: DateTime.now(),
      );
      
      bool success = await ExerciseService.updateExercise(updatedExercise);
      if (success) {
        _loadExercisesForWeek();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã loại bỏ bài tập khỏi tuần thai kỳ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi loại bỏ bài tập'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Dialog for adding exercises to a specific week
class AddExerciseToWeekDialog extends StatefulWidget {
  final PregnancyWeekModel week;
  final VoidCallback onExerciseAdded;

  const AddExerciseToWeekDialog({
    super.key,
    required this.week,
    required this.onExerciseAdded,
  });

  @override
  State<AddExerciseToWeekDialog> createState() => _AddExerciseToWeekDialogState();
}

class _AddExerciseToWeekDialogState extends State<AddExerciseToWeekDialog> {
  List<ExerciseModel> allExercises = [];
  List<ExerciseModel> availableExercises = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableExercises();
  }

  void _loadAvailableExercises() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      allExercises = await ExerciseService.loadExercises();
      // Filter out exercises that are already assigned to this week
      availableExercises = allExercises.where((exercise) {
        return !exercise.targetWeeks.contains(widget.week.weekNumber.toString());
      }).toList();
    } catch (e) {
      print('Error loading available exercises: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: UtilsReponsive.formatFontSize(20, context),
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(12, context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thêm bài tập cho Tuần ${widget.week.weekNumber}',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(18, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          widget.week.title,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(12, context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                          SizedBox(height: UtilsReponsive.height(16, context)),
                          Text(
                            'Đang tải bài tập...',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(14, context),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : availableExercises.isEmpty
                      ? Center(
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
                                'Không có bài tập nào',
                                style: TextStyle(
                                  fontSize: UtilsReponsive.formatFontSize(18, context),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: UtilsReponsive.height(8, context)),
                              Text(
                                'Tất cả bài tập đã được gán cho tuần thai kỳ này',
                                style: TextStyle(
                                  fontSize: UtilsReponsive.formatFontSize(14, context),
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                          itemCount: availableExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = availableExercises[index];
                            return _buildAvailableExerciseCard(exercise);
                          },
                        ),
            ),
            
            // Footer
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${availableExercises.length} bài tập có thể thêm',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(12, context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Đóng'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableExerciseCard(ExerciseModel exercise) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
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
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Row(
          children: [
            // Image
            Container(
              width: UtilsReponsive.width(60, context),
              height: UtilsReponsive.height(60, context),
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
            SizedBox(width: UtilsReponsive.width(12, context)),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: UtilsReponsive.height(4, context)),
                  Text(
                    exercise.description,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(12, context),
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
                          horizontal: UtilsReponsive.width(6, context),
                          vertical: UtilsReponsive.height(2, context),
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(exercise.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCategoryText(exercise.category),
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            color: _getCategoryColor(exercise.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(6, context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(6, context),
                          vertical: UtilsReponsive.height(2, context),
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getDifficultyText(exercise.difficulty),
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            color: _getDifficultyColor(exercise.difficulty),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(6, context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(6, context),
                          vertical: UtilsReponsive.height(2, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
            
            // Add Button
            ElevatedButton.icon(
              onPressed: () {
                _addExerciseToWeek(exercise);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(12, context),
                  vertical: UtilsReponsive.height(8, context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(Icons.add, size: UtilsReponsive.formatFontSize(14, context)),
              label: Text(
                'Thêm',
                style: TextStyle(fontSize: UtilsReponsive.formatFontSize(12, context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExerciseToWeek(ExerciseModel exercise) async {
    try {
      // Add the week number to targetWeeks
      List<String> updatedTargetWeeks = List.from(exercise.targetWeeks);
      if (!updatedTargetWeeks.contains(widget.week.weekNumber.toString())) {
        updatedTargetWeeks.add(widget.week.weekNumber.toString());
      }
      
      ExerciseModel updatedExercise = exercise.copyWith(
        targetWeeks: updatedTargetWeeks,
        updatedAt: DateTime.now(),
      );
      
      bool success = await ExerciseService.updateExercise(updatedExercise);
      if (success) {
        widget.onExerciseAdded();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm bài tập vào tuần thai kỳ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi thêm bài tập'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getCategoryText(String category) {
    switch (category.toLowerCase()) {
      case 'yoga':
        return 'Yoga';
      case 'cardio':
        return 'Cardio';
      case 'strength':
        return 'Tăng cường';
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'yoga':
        return Colors.purple;
      case 'cardio':
        return Colors.red;
      case 'strength':
        return Colors.orange;
      case 'breathing':
        return Colors.blue;
      case 'stretching':
        return Colors.green;
      case 'pelvic':
        return Colors.pink;
      default:
        return Colors.grey;
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
}

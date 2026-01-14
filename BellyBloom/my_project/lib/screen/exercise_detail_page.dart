import 'package:flutter/material.dart';
import 'package:my_project/model/exercise_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class ExerciseDetailPage extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar với image
          _buildSliverAppBar(context),
          
          // Content
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: UtilsReponsive.height(300, context),
      pinned: true,
      backgroundColor: Colors.orange.shade600,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          exercise.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: UtilsReponsive.formatFontSize(18, context),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image background
            if (exercise.imageUrl.isNotEmpty)
              Image.network(
                exercise.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.orange.shade600,
                    child: Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.orange.shade600,
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          _buildHeaderInfo(context),
          
          Divider(height: 1),
          
          // Basic info chips
          _buildBasicInfo(context),
          
          // Description
          if (exercise.description.isNotEmpty) _buildDescription(context),
          
          // Content (if exists)
          if (exercise.content.isNotEmpty) _buildContentSection(context),
          
          // Benefits
          if (exercise.benefits.isNotEmpty) _buildBenefits(context),
          
          // Equipment
          if (exercise.equipment.isNotEmpty) _buildEquipment(context),
          
          // Precautions
          if (exercise.precautions.isNotEmpty) _buildPrecautions(context),
          
          // Instructions
          if (exercise.instructions.isNotEmpty) _buildInstructions(context),
          
          // Target Weeks
          if (exercise.targetWeeks.isNotEmpty) _buildTargetWeeks(context),
          
          // Footer spacing
          SizedBox(height: UtilsReponsive.height(40, context)),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fitness_center,
              color: Colors.orange.shade700,
              size: UtilsReponsive.formatFontSize(24, context),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bài tập thai kỳ',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(14, context),
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: exercise.isActive 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: exercise.isActive 
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            exercise.isActive ? 'Hoạt động' : 'Tạm dừng',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(11, context),
                              color: exercise.isActive 
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 4),
              Text(
                _formatDate(exercise.createdAt),
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(11, context),
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Wrap(
        spacing: UtilsReponsive.width(12, context),
        runSpacing: UtilsReponsive.height(12, context),
        children: [
          _buildInfoChip(
            context: context,
            icon: Icons.timer,
            label: '${exercise.duration} phút',
            color: Colors.blue,
          ),
          _buildInfoChip(
            context: context,
            icon: Icons.signal_cellular_alt,
            label: exercise.difficultyDisplayName,
            color: _getDifficultyColor(exercise.difficulty),
          ),
          _buildInfoChip(
            context: context,
            icon: Icons.category,
            label: exercise.categoryDisplayName,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                size: 20,
                color: Colors.grey.shade700,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              exercise.description,
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(15, context),
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.article,
                size: 20,
                color: Colors.grey.shade700,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Text(
                'Nội dung chi tiết',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              exercise.content,
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(15, context),
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: Colors.green.shade700,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Text(
                'Lợi ích',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          ...exercise.benefits.map((benefit) => Container(
            margin: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Colors.green.shade700,
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEquipment(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_gymnastics,
                size: 20,
                color: Colors.blue.shade700,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Text(
                'Dụng cụ cần thiết',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          Wrap(
            spacing: UtilsReponsive.width(8, context),
            runSpacing: UtilsReponsive.height(8, context),
            children: exercise.equipment.map((item) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(12, context),
                vertical: UtilsReponsive.height(8, context),
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.blue.shade700,
                  ),
                  SizedBox(width: UtilsReponsive.width(6, context)),
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(13, context),
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecautions(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                size: 20,
                color: Colors.orange.shade700,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Text(
                'Lưu ý',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          ...exercise.precautions.map((precaution) => Container(
            margin: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: Colors.orange.shade700,
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: Text(
                    precaution,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                size: 20,
                color: Colors.purple.shade700,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Text(
                'Hướng dẫn thực hiện',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          ...exercise.instructions.asMap().entries.map((entry) => Container(
            margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: UtilsReponsive.width(32, context),
                  height: UtilsReponsive.height(32, context),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(14, context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTargetWeeks(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: managerColor.primary,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Text(
                'Tuần thai kỳ phù hợp',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          Wrap(
            spacing: UtilsReponsive.width(8, context),
            runSpacing: UtilsReponsive.height(8, context),
            children: exercise.targetWeeks.map((week) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(12, context),
                  vertical: UtilsReponsive.height(8, context),
                ),
                decoration: BoxDecoration(
                  color: managerColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: managerColor.primary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pregnant_woman,
                      size: 16,
                      color: managerColor.primary,
                    ),
                    SizedBox(width: UtilsReponsive.width(6, context)),
                    Text(
                      'Tuần $week',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(13, context),
                        color: managerColor.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(12, context),
        vertical: UtilsReponsive.height(8, context),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: UtilsReponsive.width(6, context)),
          Text(
            label,
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(13, context),
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}


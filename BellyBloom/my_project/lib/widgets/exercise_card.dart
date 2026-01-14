import 'package:flutter/material.dart';
import 'package:my_project/model/exercise_model.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback? onTap;

  const ExerciseCard({super.key, required this.exercise, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (exercise.imageUrl.isNotEmpty)
              Container(
                height: UtilsReponsive.height(160, context),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(exercise.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    exercise.title,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(16, context),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Description
                  if (exercise.description.isNotEmpty)
                    Text(
                      exercise.description,
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(13, context),
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: 12),

                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        icon: Icons.timer,
                        label: '${exercise.duration} phút',
                        color: Colors.blue,
                      ),
                      _buildInfoChip(
                        icon: Icons.signal_cellular_alt,
                        label: exercise.difficultyDisplayName,
                        color: _getDifficultyColor(exercise.difficulty),
                      ),
                      _buildInfoChip(
                        icon: Icons.category,
                        label: exercise.categoryDisplayName,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Benefits preview
                  if (exercise.benefits.isNotEmpty) ...[
                    Text(
                      'Lợi ích:',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(12, context),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      exercise.benefits.take(2).join(', ') +
                          (exercise.benefits.length > 2 ? '...' : ''),
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(12, context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 12),
                  ],

                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: Colors.orange.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Bài tập',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(12, context),
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey.shade400,
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
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
}

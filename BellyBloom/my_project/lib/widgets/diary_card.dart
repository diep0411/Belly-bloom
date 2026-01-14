import 'package:flutter/material.dart';
import 'package:my_project/model/diary_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class DiaryCard extends StatelessWidget {
  final DiaryModel diary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.onDelete,
  });

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
            // Header with date
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: managerColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: managerColor.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          diary.dayOfWeek,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${diary.date.day}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diary.formattedDate,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              16,
                              context,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          diary.relativeDate,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              12,
                              context,
                            ),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (diary.isToday)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Hôm nay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onSelected: (value) {
                        if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        } else if (value == 'edit' && onTap != null) {
                          onTap!();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.grey.shade700),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red.shade600),
                              SizedBox(width: 8),
                              Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text content
                  if (diary.content.isNotEmpty)
                    Text(
                      diary.content,
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(14, context),
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Images preview
                  if (diary.imageUrls.isNotEmpty) ...[
                    SizedBox(height: 12),
                    _buildImagePreview(context),
                  ],

                  SizedBox(height: 12),

                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 16,
                        color: managerColor.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Nhật ký',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(12, context),
                          color: managerColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      if (diary.imageUrls.isNotEmpty) ...[
                        Icon(
                          Icons.photo_library,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${diary.imageUrls.length} ảnh',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              12,
                              context,
                            ),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      SizedBox(width: 8),
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

  Widget _buildImagePreview(BuildContext context) {
    if (diary.imageUrls.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: diary.imageUrls.length > 3 ? 3 : diary.imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 8),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Image.network(
                  diary.imageUrls[index],
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey.shade500,
                      ),
                    );
                  },
                ),
                if (index == 2 && diary.imageUrls.length > 3)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        '+${diary.imageUrls.length - 3}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

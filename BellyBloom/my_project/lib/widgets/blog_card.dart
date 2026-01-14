import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_project/model/blog_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class BlogCard extends StatelessWidget {
  final BlogModel blog;
  final VoidCallback? onTap;

  const BlogCard({super.key, required this.blog, this.onTap});

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
            if (blog.imageUrl.isNotEmpty)
              Container(
                height: UtilsReponsive.height(180, context),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(blog.imageUrl),
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
                    blog.title,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(16, context),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Subtitle
                  if (blog.subtitle.isNotEmpty)
                    Text(
                      blog.subtitle,
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(14, context),
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: 12),

                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 16,
                        color: managerColor.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Cẩm nang',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(12, context),
                          color: managerColor.primary,
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

  String _getContentPreview(String content) {
    if (content.isEmpty) {
      return '';
    }

    String plainText = '';

    // Try to parse as JSON Delta (from Flutter Quill)
    try {
      final json = content.trim();
      // Check if it's JSON format
      if (json.startsWith('{') && json.contains('"ops"')) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        if (decoded.containsKey('ops') && decoded['ops'] is List) {
          // Extract plain text from Delta operations
          for (var op in decoded['ops'] as List) {
            if (op is Map && op.containsKey('insert')) {
              final insert = op['insert'];
              if (insert is String) {
                plainText += insert;
              } else if (insert is Map) {
                // Handle embedded objects (images, etc.)
                if (insert.containsKey('image')) {
                  plainText += '[Hình ảnh] ';
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // Not JSON Delta, continue with other parsing methods
    }

    // If JSON Delta parsing didn't work or returned empty, try other formats
    if (plainText.isEmpty) {
      // Try to remove HTML tags
      plainText =
          content
              .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
              .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces
              .trim();
    }

    // Clean up the text
    plainText =
        plainText
            .replaceAll(RegExp(r'\n+'), ' ') // Replace newlines
            .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces
            .trim();

    if (plainText.isEmpty) {
      return 'Không có nội dung';
    }

    if (plainText.length > 150) {
      return '${plainText.substring(0, 150)}...';
    }
    return plainText;
  }
}

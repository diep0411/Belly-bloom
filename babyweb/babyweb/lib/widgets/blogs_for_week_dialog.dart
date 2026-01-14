import 'package:babyweb/model/blog_model.dart';
import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/blog_service.dart';
import 'package:flutter/material.dart';

// Dialog for showing blogs for a specific week
class BlogsForWeekDialog extends StatefulWidget {
  final PregnancyWeekModel week;

  const BlogsForWeekDialog({
    super.key,
    required this.week,
  });

  @override
  State<BlogsForWeekDialog> createState() => _BlogsForWeekDialogState();
}

class _BlogsForWeekDialogState extends State<BlogsForWeekDialog> {
  List<BlogModel> blogs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBlogsForWeek();
  }

  void _loadBlogsForWeek() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Load all blogs and filter by week number in title or content
      List<BlogModel> allBlogs = await BlogService.loadBlog();
      blogs = allBlogs.where((blog) {
        String weekNumber = widget.week.weekNumber.toString();
        return blog.title.toLowerCase().contains('tuần $weekNumber') ||
               blog.title.toLowerCase().contains('week $weekNumber') ||
               blog.subtitle.toLowerCase().contains('tuần $weekNumber') ||
               blog.subtitle.toLowerCase().contains('week $weekNumber') ||
               blog.content.toLowerCase().contains('tuần $weekNumber') ||
               blog.content.toLowerCase().contains('week $weekNumber');
      }).toList();
    } catch (e) {
      print('Error loading blogs for week: $e');
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
                color: Colors.blue.withOpacity(0.1),
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
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.article,
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
                          'Blog cho Tuần ${widget.week.weekNumber}',
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(height: UtilsReponsive.height(16, context)),
                          Text(
                            'Đang tải blog...',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(14, context),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : blogs.isEmpty
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
                                  Icons.article_outlined,
                                  size: UtilsReponsive.formatFontSize(48, context),
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              SizedBox(height: UtilsReponsive.height(16, context)),
                              Text(
                                'Chưa có blog nào',
                                style: TextStyle(
                                  fontSize: UtilsReponsive.formatFontSize(18, context),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: UtilsReponsive.height(8, context)),
                              Text(
                                'Chưa có blog nào liên quan đến tuần thai kỳ này',
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
                          itemCount: blogs.length,
                          itemBuilder: (context, index) {
                            final blog = blogs[index];
                            return _buildBlogCard(blog);
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
                    '${blogs.length} blog liên quan',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(12, context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddBlogDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                          'Thêm blog',
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

  Widget _buildBlogCard(BlogModel blog) {
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
              width: UtilsReponsive.width(80, context),
              height: UtilsReponsive.height(80, context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              clipBehavior: Clip.hardEdge,
              child: blog.imageUrl.isNotEmpty
                  ? Image.network(
                      blog.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.article,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.article,
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
                    blog.title,
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
                    blog.subtitle,
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
                          horizontal: UtilsReponsive.width(8, context),
                          vertical: UtilsReponsive.height(4, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Bài viết',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            color: Colors.blue.shade700,
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
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ID: ${blog.id?.substring(0, 8) ?? 'Không có'}',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            color: Colors.green.shade700,
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
                    _showBlogDetail(blog);
                  },
                  icon: Icon(
                    Icons.visibility_outlined,
                    color: Colors.blue.shade600,
                  ),
                  tooltip: 'Xem chi tiết',
                ),
                IconButton(
                  onPressed: () {
                    _removeBlogFromWeek(blog);
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

  void _showBlogDetail(BlogModel blog) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                  color: Colors.blue.withOpacity(0.1),
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
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.article,
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
                            'Chi tiết blog',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(18, context),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            blog.title,
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(12, context),
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (blog.imageUrl.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          height: UtilsReponsive.height(200, context),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade100,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            blog.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.article,
                                  color: Colors.grey.shade400,
                                  size: UtilsReponsive.formatFontSize(48, context),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: UtilsReponsive.height(16, context)),
                      ],
                      
                      // Title
                      Text(
                        blog.title,
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(20, context),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      
                      // Subtitle
                      Text(
                        blog.subtitle,
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(16, context),
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      // Content
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          blog.content,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(14, context),
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      'ID: ${blog.id ?? 'Không có'}',
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
      ),
    );
  }

  void _showAddBlogDialog() {
    // TODO: Implement AddBlogToWeekDialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tính năng thêm blog sẽ được triển khai sau'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _removeBlogFromWeek(BlogModel blog) {
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
            Text('Bạn có chắc chắn muốn loại bỏ blog này khỏi tuần thai kỳ?'),
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
                    blog.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    blog.subtitle,
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
              'Lưu ý: Blog sẽ không bị xóa, chỉ loại bỏ khỏi danh sách liên quan đến tuần này.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                fontStyle: FontStyle.italic,
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
              await _removeBlog(blog);
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

  Future<void> _removeBlog(BlogModel blog) async {
    try {
      // For blogs, we can't directly remove from targetWeeks like exercises
      // Instead, we'll show a message that this is a content-based relationship
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Blog được liên kết dựa trên nội dung. Để loại bỏ, hãy chỉnh sửa nội dung blog.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
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

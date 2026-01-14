import 'dart:convert';
import 'dart:developer';

import 'package:babyweb/model/blog_model.dart';
import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:babyweb/resource/color_manager.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/blog_service.dart';
import 'package:babyweb/service/pregnancy_week_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController linkImageController = TextEditingController();
  String linkImage = '';
  QuillController _controller = QuillController.basic();
  bool isLoading = false;
  bool isLoadingButton = false;
  List<BlogModel> blogs = [];
  List<BlogModel> filteredBlogs = [];
  
  // For target weeks selection
  List<int> targetWeeks = [];
  List<PregnancyWeekModel> availableWeeks = [];
  bool isLoadingWeeks = false;

  Future<void> saveContent() async {
    log('saveContent');
    final String content = jsonEncode(_controller.document.toDelta().toJson());
    log('json: $json');
    final now = DateTime.now();
    final BlogModel blog = BlogModel(
      id: null,
      title: titleController.text,
      subtitle: subtitleController.text,
      content: content,
      imageUrl: linkImage,
      targetWeeks: targetWeeks,
      createdAt: now,
      updatedAt: now,
    );
    bool isSuccess = await BlogService.addBlog(blog);
    if (isSuccess) {
      // Close dialog first
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Then reload data
      loadBlog();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tạo bài viết thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi tạo bài viết!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateContent({required BlogModel blog}) async {
    final String content = jsonEncode(_controller.document.toDelta().toJson());
    log('json: $json');
    final BlogModel blogUpdate = BlogModel(
      id: blog.id,
      title: titleController.text,
      subtitle: subtitleController.text,
      content: content,
      imageUrl: linkImage,
      targetWeeks: targetWeeks,
      createdAt: blog.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    bool isSuccess = await BlogService.updateBlog(blogUpdate);
    if (isSuccess) {
      // Close dialog first
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Then reload data
      loadBlog();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật bài viết thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi cập nhật bài viết!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void loadBlog() async {
    setState(() {
      isLoading = true;
    });
    blogs = await BlogService.loadBlog();
    filteredBlogs = List.from(blogs);
    log('blogs: $blogs');
    setState(() {
      isLoading = false;
    });
  }

  void _filterBlogs(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBlogs = List.from(blogs);
      } else {
        filteredBlogs = blogs.where((blog) {
          return blog.title.toLowerCase().contains(query.toLowerCase()) ||
                 blog.subtitle.toLowerCase().contains(query.toLowerCase());
        }).toList();
       
      }
    });
  }

  Future<void> _loadPregnancyWeeks({VoidCallback? onStateChanged}) async {
    setState(() {
      isLoadingWeeks = true;
    });
    if (onStateChanged != null) {
      onStateChanged();
    }
    
    try {
      availableWeeks = await PregnancyWeekService.loadPregnancyWeeks();
    } catch (e) {
      log('Error loading pregnancy weeks: $e');
    } finally {
      setState(() {
        isLoadingWeeks = false;
      });
      if (onStateChanged != null) {
        onStateChanged();
      }
    }
  }

  @override
  void initState() {
    loadBlog();
    // TODO: implement initState
    super.initState();
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
          Expanded(child: _buildContentList()),
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
            Icons.article_outlined,
            color: ColorManager.primary,
            size: UtilsReponsive.formatFontSize(24, context),
          ),
        ),
        SizedBox(width: UtilsReponsive.width(16, context)),
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Quản lý nội dung',
            style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(28, context),
              fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'Quản lý nội dung blog và bài viết',
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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${blogs.length} bài viết',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(12, context),
                  color: Colors.green.shade700,
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
                onChanged: _filterBlogs,
                  decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài viết...',
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
              _showDialogCreateContent();
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
              'Tạo bài viết',
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

  Widget _buildContentList() {
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

    if (blogs.isEmpty) {
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
                Icons.article_outlined,
                size: UtilsReponsive.formatFontSize(48, context),
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(18, context),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            Text(
              'Hãy tạo bài viết đầu tiên của bạn',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(24, context)),
            ElevatedButton.icon(
                  onPressed: () {
                    _showDialogCreateContent();
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
              label: Text('Tạo bài viết đầu tiên'),
            ),
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
                  'Danh sách bài viết',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(16, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Spacer(),
                Text(
                  '${blogs.length} bài viết',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    color: Colors.grey.shade600,
                ),
              ),
            ],
            ),
          ),
          Expanded(
            child: _buildBlogCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogCards() {
    return ListView.builder(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      itemCount: filteredBlogs.length,
      itemBuilder: (context, index) {
        final blog = filteredBlogs[index];
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
                _showDialogCreateContent(blog: blog);
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
                      child: Image.network(
                        blog.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: UtilsReponsive.width(16, context)),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.title,
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(16, context),
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
                                  'Bài viết',
                                  style: TextStyle(
                                    fontSize: UtilsReponsive.formatFontSize(10, context),
                                    color: ColorManager.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                'ID: ${blog.id?.substring(0, 8) ?? 'Không có'}',
                                style: TextStyle(
                                  fontSize: UtilsReponsive.formatFontSize(10, context),
                                  color: Colors.grey.shade500,
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
                              _showDialogCreateContent(blog: blog);
                            },
                          icon: Icon(
                            Icons.edit_outlined,
                            color: ColorManager.primary,
                          ),
                          tooltip: 'Chỉnh sửa',
                          ),
                          IconButton(
                          onPressed: () {
                            _showDeleteDialog(blog);
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
      },
    );
  }

  void _showDeleteDialog(BlogModel blog) {
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
              Text('Bạn có chắc chắn muốn xóa bài viết này?'),
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
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                await _deleteBlog(blog);
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

  Future<void> _deleteBlog(BlogModel blog) async {
    if (blog.id == null) return;
    
    try {
      // TODO: Implement delete in BlogService
      // bool success = await BlogService.deleteBlog(blog.id!);
      // if (success) {
      //   loadBlog();
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Đã xóa bài viết thành công'),
      //       backgroundColor: Colors.green,
      //     ),
      //   );
      // }
      
      // Temporary implementation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tính năng xóa đang được phát triển'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi xóa bài viết'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _showDialogCreateContent({BlogModel? blog}) {
    if (blog != null) {
      titleController.text = blog.title;
      subtitleController.text = blog.subtitle;
      linkImage = blog.imageUrl;
      linkImageController.text = blog.imageUrl;
      _controller.document = Document.fromJson(jsonDecode(blog.content));
      targetWeeks = List.from(blog.targetWeeks);
    } else {
      // Reset form for new blog
      titleController.clear();
      subtitleController.clear();
      linkImageController.clear();
      linkImage = '';
      _controller = QuillController.basic();
      targetWeeks = [];
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Load weeks when dialog opens if not loaded
          if (availableWeeks.isEmpty && !isLoadingWeeks) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadPregnancyWeeks(onStateChanged: () {
                setStateDialog(() {});
              });
            });
          }
          
          return Dialog(
            child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
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
                  color: ColorManager.primary.withOpacity(0.1),
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
                        color: ColorManager.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        blog == null ? Icons.add : Icons.edit,
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
                            blog == null ? 'Tạo bài viết mới' : 'Chỉnh sửa bài viết',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(18, context),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            blog == null 
                                ? 'Tạo nội dung blog mới cho website'
                                : 'Chỉnh sửa thông tin bài viết',
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildOverviewInfo(setStateDialog),
                      ),
                      SizedBox(width: UtilsReponsive.width(20, context)),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: QuillSimpleToolbar(
                              controller: _controller,
                              config: const QuillSimpleToolbarConfig(),
                              ),
                            ),
                            SizedBox(height: UtilsReponsive.height(8, context)),
                            Container(
                              height: UtilsReponsive.height(400, context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: QuillEditor(
                                controller: _controller,
                                config: QuillEditorConfig(
                                  padding: UtilsReponsive.padding(
                                    context,
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  placeholder: 'Nhập nội dung bài viết...',
                                ),
                                focusNode: FocusNode(),
                                scrollController: ScrollController(),
                              ),
                            ),
                          ],
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Hủy'),
                    ),
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    StatefulBuilder(
                      builder: (context, setStateButton) => ElevatedButton.icon(
                        onPressed: isLoadingButton ? null : () async {
                        if (isLoadingButton) return;
                        setStateButton(() {
                          isLoadingButton = true;
                          });
                        try {
                          if (blog == null) {
                            await saveContent();
                          } else {
                            await updateContent(blog: blog);
                          }
                        } finally {
                          setStateButton(() {
                            isLoadingButton = false;
                          });
                        }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: UtilsReponsive.width(24, context),
                            vertical: UtilsReponsive.height(12, context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: isLoadingButton 
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                blog == null ? Icons.save : Icons.update,
                                size: UtilsReponsive.formatFontSize(16, context),
                              ),
                        label: Text(
                          isLoadingButton 
                              ? 'Đang lưu...'
                              : (blog == null ? 'Tạo bài viết' : 'Cập nhật'),
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(14, context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewInfo(StateSetter setStateDialog) {
    return StatefulBuilder(
      builder: (context, setStateX) {
        return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text(
            'Thông tin cơ bản',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(16, context),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Image Preview
                Container(
            height: UtilsReponsive.height(200, context),
            width: double.infinity,
                  decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.hardEdge,
            child: linkImage.isNotEmpty
                ? Image.network(
                    linkImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                              size: UtilsReponsive.formatFontSize(32, context),
                            ),
                            SizedBox(height: UtilsReponsive.height(8, context)),
                            Text(
                              'Không thể tải hình ảnh',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(12, context),
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: UtilsReponsive.formatFontSize(32, context),
                        ),
                        SizedBox(height: UtilsReponsive.height(8, context)),
                        Text(
                          'Chưa có hình ảnh',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(12, context),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Image URL Field
          Text(
            'URL hình ảnh',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(14, context),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  onChanged: (value) {
                    setStateX(() {
                      linkImage = value;
                      linkImageController.text = value;
                    });
                  },
                  controller: linkImageController,
                  decoration: InputDecoration(
              hintText: 'Nhập URL hình ảnh...',
              prefixIcon: Icon(Icons.link, color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorManager.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(12, context),
                vertical: UtilsReponsive.height(12, context),
              ),
            ),
          ),
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Title Field
          Text(
            'Tiêu đề bài viết',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(14, context),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Nhập tiêu đề bài viết...',
              prefixIcon: Icon(Icons.title, color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorManager.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(12, context),
                vertical: UtilsReponsive.height(12, context),
              ),
            ),
          ),
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Subtitle Field
          Text(
            'Mô tả ngắn',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(14, context),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextField(
            controller: subtitleController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập mô tả ngắn về bài viết...',
              prefixIcon: Icon(Icons.description, color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorManager.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(12, context),
                vertical: UtilsReponsive.height(12, context),
                    ),
                  ),
                ),
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Target Weeks Selection
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: UtilsReponsive.formatFontSize(16, context),
                color: Colors.grey.shade700,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Text(
                'Tuần thai kỳ phù hợp',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(14, context),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Spacer(),
              if (targetWeeks.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setStateX(() {
                      targetWeeks.clear();
                    });
                    // Also update dialog state
                    setStateDialog(() {});
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(8, context),
                      vertical: UtilsReponsive.height(4, context),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Bỏ chọn tất cả',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(10, context),
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          if (isLoadingWeeks)
            Center(
              child: Padding(
                padding: EdgeInsets.all(UtilsReponsive.height(16, context)),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                ),
              ),
            )
          else if (availableWeeks.isEmpty)
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  Expanded(
                    child: Text(
                      'Chưa có tuần thai kỳ nào. Vui lòng tạo tuần thai kỳ trước.',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(11, context),
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: UtilsReponsive.width(8, context),
              runSpacing: UtilsReponsive.height(8, context),
              children: availableWeeks.map((week) {
                bool isSelected = targetWeeks.contains(week.weekNumber);
                return GestureDetector(
                  onTap: () {
                    setStateX(() {
                      if (isSelected) {
                        targetWeeks.remove(week.weekNumber);
                      } else {
                        targetWeeks.add(week.weekNumber);
                      }
                    });
                    // Also update dialog state
                    setStateDialog(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(12, context),
                      vertical: UtilsReponsive.height(6, context),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? ColorManager.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? ColorManager.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: UtilsReponsive.width(20, context),
                          height: UtilsReponsive.height(20, context),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? ColorManager.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? ColorManager.primary
                                  : Colors.grey.shade400,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: UtilsReponsive.formatFontSize(12, context),
                                )
                              : null,
                        ),
                        SizedBox(width: UtilsReponsive.width(6, context)),
                        Text(
                          'Tuần ${week.weekNumber}',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(12, context),
                            color: isSelected 
                                ? ColorManager.primary
                                : Colors.grey.shade700,
                            fontWeight: isSelected 
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          if (targetWeeks.isNotEmpty) ...[
            SizedBox(height: UtilsReponsive.height(12, context)),
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đã chọn:',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(10, context),
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: UtilsReponsive.height(4, context)),
                  Text(
                    targetWeeks.map((week) => 'Tuần $week').join(', '),
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(10, context),
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
      },
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:my_project/model/blog_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class BlogDetailPage extends StatefulWidget {
  final BlogModel blog;

  const BlogDetailPage({super.key, required this.blog});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  late QuillController _controller;
  bool _isLoadingContent = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() {
    try {
      final content = widget.blog.content.trim();
      if (content.isNotEmpty) {
        // Parse JSON Delta - Document.fromJson expects the decoded JSON map
        final json = jsonDecode(content);
        _controller = QuillController(
          document: Document.fromJson(json),
          selection: TextSelection.collapsed(offset: 0),
        );
      } else {
        // Plain text fallback
        _controller = QuillController.basic();
        if (content.isNotEmpty) {
          _controller.document = Document()..insert(0, content);
        }
      }
      // Set read-only mode để chỉ hiển thị, không cho edit
      _controller.readOnly = true;
    } catch (e) {
      // Error parsing, use plain text
      _controller = QuillController.basic();
      if (widget.blog.content.isNotEmpty) {
        _controller.document = Document()..insert(0, widget.blog.content);
      }
      // Set read-only mode
      _controller.readOnly = true;
    } finally {
      setState(() {
        _isLoadingContent = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BlogModel get blog => widget.blog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar với image
          _buildSliverAppBar(context),

          // Content
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: UtilsReponsive.height(300, context),
      pinned: true,
      backgroundColor: managerColor.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          blog.title,
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
            if (blog.imageUrl.isNotEmpty)
              Image.network(
                blog.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: managerColor.primary,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: managerColor.primary,
                child: Center(
                  child: Icon(
                    Icons.article,
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
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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

          // Subtitle
          if (blog.subtitle.isNotEmpty) _buildSubtitle(context),

          // Main content
          _buildMainContent(context),

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
              color: managerColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.article,
              color: managerColor.primary,
              size: UtilsReponsive.formatFontSize(24, context),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cẩm nang thai kỳ',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(14, context),
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                if (blog.targetWeeks.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children:
                        blog.targetWeeks.map((week) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: managerColor.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Tuần $week',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(
                                  11,
                                  context,
                                ),
                                color: managerColor.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade400),
              SizedBox(height: 4),
              Text(
                _formatDate(blog.createdAt),
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

  Widget _buildSubtitle(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blog.subtitle,
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(18, context),
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      padding: UtilsReponsive.padding(context, horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nội dung',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(20, context),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          _buildBlogContent(context),
        ],
      ),
    );
  }

  // Display blog content using Flutter Quill
  Widget _buildBlogContent(BuildContext context) {
    if (blog.content.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade400),
            SizedBox(width: 12),
            Text(
              'Không có nội dung',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingContent) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(managerColor.primary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: QuillEditor.basic(
        controller: _controller,
        config: QuillEditorConfig(
          padding: EdgeInsets.all(20),
          placeholder: '',
          // readOnly: true, // Set read-only mode
        ),
      ),
    );
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

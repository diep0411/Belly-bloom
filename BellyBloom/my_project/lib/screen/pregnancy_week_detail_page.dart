import 'package:flutter/material.dart';
import 'package:my_project/model/pregnancy_week_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class PregnancyWeekDetailPage extends StatelessWidget {
  final PregnancyWeekModel week;

  const PregnancyWeekDetailPage({super.key, required this.week});

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
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: false,
      title: LayoutBuilder(
        builder: (context, constraints) {
          // Show title only when collapsed
          if (constraints.biggest.height <= kToolbarHeight) {
            return Text(
              week.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: UtilsReponsive.formatFontSize(16, context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }
          return SizedBox.shrink();
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: UtilsReponsive.width(72, context),
          right: UtilsReponsive.width(16, context),
          bottom: UtilsReponsive.height(16, context),
        ),
        title: Text(
          week.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: UtilsReponsive.formatFontSize(16, context),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
        ),
        background: week.imageUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    week.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: managerColor.primary,
                        child: Icon(
                          Icons.pregnant_woman,
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay - cải thiện để title rõ hơn
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      managerColor.primary,
                      managerColor.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.pregnant_woman,
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
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
          // Week number badge
          _buildWeekBadge(context),

          // Description
          if (week.description.isNotEmpty) _buildDescription(context),

          // Baby Development
          if (week.babyDevelopment.isNotEmpty)
            _buildSection(
              context,
              icon: Icons.child_care,
              title: 'Sự phát triển của bé',
              content: week.babyDevelopment,
              color: Colors.blue,
            ),

          // Mother Changes
          if (week.motherChanges.isNotEmpty)
            _buildSection(
              context,
              icon: Icons.favorite,
              title: 'Thay đổi của mẹ',
              content: week.motherChanges,
              color: Colors.pink,
            ),

          // Tips
          if (week.tips.isNotEmpty)
            _buildSection(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Lời khuyên',
              content: week.tips,
              color: Colors.orange,
            ),

          // Symptoms
          if (week.symptoms.isNotEmpty)
            _buildListSection(
              context,
              icon: Icons.medical_services_outlined,
              title: 'Triệu chứng',
              items: week.symptoms,
              color: Colors.red,
            ),

          // Recommendations
          if (week.recommendations.isNotEmpty)
            _buildListSection(
              context,
              icon: Icons.check_circle_outline,
              title: 'Khuyến nghị',
              items: week.recommendations,
              color: Colors.green,
            ),

          // Footer spacing
          SizedBox(height: UtilsReponsive.height(40, context)),
        ],
      ),
    );
  }

  Widget _buildWeekBadge(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(UtilsReponsive.width(20, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            managerColor.primary,
            managerColor.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: managerColor.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: UtilsReponsive.formatFontSize(24, context),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(16, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tuần thai kỳ',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(14, context),
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Tuần ${week.weekNumber}',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(28, context),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(20, context),
        vertical: UtilsReponsive.height(8, context),
      ),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        week.description,
        style: TextStyle(
          fontSize: UtilsReponsive.formatFontSize(15, context),
          color: Colors.grey.shade800,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(20, context),
        vertical: UtilsReponsive.height(12, context),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: UtilsReponsive.formatFontSize(20, context),
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(18, context),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Text(
              content,
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

  Widget _buildListSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(20, context),
        vertical: UtilsReponsive.height(12, context),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: UtilsReponsive.formatFontSize(20, context),
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(18, context),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(8, context),
                    vertical: UtilsReponsive.height(4, context),
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(12, context),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              children: items.asMap().entries.map((entry) {
                int index = entry.key;
                String item = entry.value;
                return Container(
                  margin: EdgeInsets.only(
                    bottom: UtilsReponsive.height(8, context),
                  ),
                  padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: UtilsReponsive.width(24, context),
                        height: UtilsReponsive.height(24, context),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(12, context),
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(12, context)),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(14, context),
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


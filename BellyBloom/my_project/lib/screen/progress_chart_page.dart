import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/model/health_metric_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/service/health_metric_service.dart';
import 'package:my_project/widgets/health_metric_dialog.dart';

class ProgressChartPage extends StatefulWidget {
  const ProgressChartPage({super.key});

  @override
  State<ProgressChartPage> createState() => _ProgressChartPageState();
}

class _ProgressChartPageState extends State<ProgressChartPage> {
  List<HealthMetricModel> _healthMetrics = [];
  bool _isLoading = true;
  String _selectedMetric =
      'weight'; // 'weight', 'height', 'bloodPressure', 'heartRate'
  int _selectedDays = 30; // 7, 30, 90, all

  @override
  void initState() {
    super.initState();
    _loadHealthMetrics();
  }

  Future<void> _loadHealthMetrics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = BaseCommon().userAccount.uid;
      if (userId == null || userId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final metrics = await HealthMetricService.getHealthMetrics(userId);
      setState(() {
        _healthMetrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading health metrics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<HealthMetricModel> _getFilteredMetrics() {
    if (_selectedDays == 0) {
      return _healthMetrics;
    }

    final cutoffDate = DateTime.now().subtract(Duration(days: _selectedDays));
    return _healthMetrics
        .where((metric) => metric.date.isAfter(cutoffDate))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: managerColor.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Quá trình phát triển',
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(20, context),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddMetricDialog(),
            tooltip: 'Thêm thông số',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    managerColor.primary,
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadHealthMetrics,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(UtilsReponsive.height(16, context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter buttons
                      _buildFilterSection(),
                      SizedBox(height: UtilsReponsive.height(20, context)),

                      // Metric selector
                      _buildMetricSelector(),
                      SizedBox(height: UtilsReponsive.height(20, context)),

                      // Chart
                      _buildChart(),
                      SizedBox(height: UtilsReponsive.height(20, context)),

                      // Legend
                      _buildLegend(),
                      SizedBox(height: UtilsReponsive.height(20, context)),

                      // Recent metrics list
                      _buildRecentMetricsList(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.height(12, context)),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFilterChip('7 ngày', 7),
          _buildFilterChip('30 ngày', 30),
          _buildFilterChip('90 ngày', 90),
          _buildFilterChip('Tất cả', 0),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int days) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = days;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: UtilsReponsive.width(16, context),
          vertical: UtilsReponsive.height(8, context),
        ),
        decoration: BoxDecoration(
          color: isSelected ? managerColor.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: UtilsReponsive.formatFontSize(12, context),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.height(12, context)),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricChip(
            'Cân nặng',
            'weight',
            Icons.monitor_weight,
            Colors.blue,
          ),
          _buildMetricChip('Chiều cao', 'height', Icons.height, Colors.green),
          _buildMetricChip(
            'Huyết áp',
            'bloodPressure',
            Icons.favorite,
            Colors.red,
          ),
          _buildMetricChip(
            'Nhịp tim',
            'heartRate',
            Icons.favorite_border,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMetric == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(UtilsReponsive.height(8, context)),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: UtilsReponsive.formatFontSize(20, context),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: UtilsReponsive.formatFontSize(10, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final filteredMetrics = _getFilteredMetrics();

    if (filteredMetrics.isEmpty) {
      return Container(
        height: UtilsReponsive.height(300, context),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                'Chưa có dữ liệu',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(16, context),
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Nhấn nút + để thêm thông số',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(14, context),
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: UtilsReponsive.height(300, context),
      padding: EdgeInsets.all(UtilsReponsive.height(16, context)),
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
      child: _buildLineChart(filteredMetrics),
    );
  }

  Widget _buildLineChart(List<HealthMetricModel> metrics) {
    // Prepare data points based on selected metric
    List<FlSpot> spots = [];
    List<FlSpot>? secondarySpots; // For blood pressure (systolic/diastolic)

    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final x = i.toDouble();
      double? y;
      double? y2;

      switch (_selectedMetric) {
        case 'weight':
          if (metric.weight != null) {
            y = metric.weight!;
            minY = minY > y ? y : minY;
            maxY = maxY < y ? y : maxY;
          }
          break;
        case 'height':
          if (metric.height != null) {
            y = metric.height!;
            minY = minY > y ? y : minY;
            maxY = maxY < y ? y : maxY;
          }
          break;
        case 'bloodPressure':
          if (metric.bloodPressureSystolic != null) {
            y = metric.bloodPressureSystolic!;
            minY = minY > y ? y : minY;
            maxY = maxY < y ? y : maxY;
          }
          if (metric.bloodPressureDiastolic != null) {
            y2 = metric.bloodPressureDiastolic!;
            minY = minY > y2 ? y2 : minY;
            maxY = maxY < y2 ? y2 : maxY;
          }
          break;
        case 'heartRate':
          if (metric.heartRate != null) {
            y = metric.heartRate!.toDouble();
            minY = minY > y ? y : minY;
            maxY = maxY < y ? y : maxY;
          }
          break;
      }

      if (y != null) {
        spots.add(FlSpot(x, y));
      }
      if (y2 != null) {
        secondarySpots ??= [];
        secondarySpots.add(FlSpot(x, y2));
      }
    }

    // Add padding to Y axis
    if (minY != double.infinity && maxY != double.negativeInfinity) {
      // If maxY == minY (e.g., height doesn't change), add minimum range
      if (maxY == minY) {
        final baseValue = maxY;
        minY = (baseValue - 1).clamp(0, double.infinity);
        maxY = baseValue + 1;
      } else {
        final padding = (maxY - minY) * 0.1;
        minY = (minY - padding).clamp(0, double.infinity);
        maxY = maxY + padding;
      }
    } else {
      minY = 0;
      maxY = 100;
    }

    // Ensure maxY - minY is never zero
    if (maxY - minY == 0) {
      maxY = minY + 1;
    }

    final lineBarsData = <LineChartBarData>[];

    // Primary line
    if (spots.isNotEmpty) {
      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _getMetricColor(_selectedMetric),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: _getMetricColor(_selectedMetric),
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: _getMetricColor(_selectedMetric).withOpacity(0.1),
          ),
        ),
      );
    }

    // Secondary line (for blood pressure)
    if (secondarySpots != null && secondarySpots.isNotEmpty) {
      lineBarsData.add(
        LineChartBarData(
          spots: secondarySpots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.orange,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 5).clamp(0.1, double.infinity),
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (metrics.length / 5).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < metrics.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(metrics[index].date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: UtilsReponsive.formatFontSize(10, context),
                      ),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: ((maxY - minY) / 5).clamp(0.1, double.infinity),
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(
                    _selectedMetric == 'weight' || _selectedMetric == 'height'
                        ? 1
                        : 0,
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: UtilsReponsive.formatFontSize(10, context),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        minX: 0,
        maxX: (metrics.length - 1).toDouble().clamp(0, double.infinity),
        minY: minY,
        maxY: maxY,
        lineBarsData: lineBarsData,
      ),
    );
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case 'weight':
        return Colors.blue;
      case 'height':
        return Colors.green;
      case 'bloodPressure':
        return Colors.red;
      case 'heartRate':
        return Colors.orange;
      default:
        return managerColor.primary;
    }
  }

  Widget _buildLegend() {
    if (_selectedMetric == 'bloodPressure') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Tâm thu', Colors.red),
          SizedBox(width: UtilsReponsive.width(20, context)),
          _buildLegendItem('Tâm trương', Colors.orange),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(12, context),
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMetricsList() {
    final filteredMetrics = _getFilteredMetrics();
    if (filteredMetrics.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử gần đây',
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(18, context),
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: UtilsReponsive.height(12, context)),
        ...filteredMetrics.reversed
            .take(10)
            .map((metric) => _buildMetricCard(metric)),
      ],
    );
  }

  Widget _buildMetricCard(HealthMetricModel metric) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      padding: EdgeInsets.all(UtilsReponsive.height(16, context)),
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
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: managerColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.analytics, color: managerColor.primary, size: 24),
          ),
          SizedBox(width: UtilsReponsive.width(16, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(metric.date),
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(14, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Wrap(
                  spacing: UtilsReponsive.width(12, context),
                  runSpacing: UtilsReponsive.height(4, context),
                  children: [
                    if (metric.weight != null)
                      _buildMetricValueChip(
                        'Cân nặng: ${metric.weight!.toStringAsFixed(1)} kg',
                        Colors.blue,
                      ),
                    if (metric.height != null)
                      _buildMetricValueChip(
                        'Chiều cao: ${metric.height!.toStringAsFixed(1)} cm',
                        Colors.green,
                      ),
                    if (metric.bloodPressureSystolic != null &&
                        metric.bloodPressureDiastolic != null)
                      _buildMetricValueChip(
                        'Huyết áp: ${metric.bloodPressureSystolic!.toInt()}/${metric.bloodPressureDiastolic!.toInt()}',
                        Colors.red,
                      ),
                    if (metric.heartRate != null)
                      _buildMetricValueChip(
                        'Nhịp tim: ${metric.heartRate} bpm',
                        Colors.orange,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditMetricDialog(metric);
              } else if (value == 'delete') {
                _deleteMetric(metric);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricValueChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(8, context),
        vertical: UtilsReponsive.height(4, context),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: UtilsReponsive.formatFontSize(11, context),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddMetricDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => HealthMetricDialog(),
    );

    if (result == true) {
      _loadHealthMetrics();
    }
  }

  void _showEditMetricDialog(HealthMetricModel metric) async {
    final result = await showDialog(
      context: context,
      builder: (context) => HealthMetricDialog(metric: metric),
    );

    if (result == true) {
      _loadHealthMetrics();
    }
  }

  void _deleteMetric(HealthMetricModel metric) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa thông số ngày ${DateFormat('dd/MM/yyyy').format(metric.date)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (metric.id != null) {
                    final success =
                        await HealthMetricService.deleteHealthMetric(
                          metric.id!,
                        );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa thông số thành công'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadHealthMetrics();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Có lỗi xảy ra khi xóa'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

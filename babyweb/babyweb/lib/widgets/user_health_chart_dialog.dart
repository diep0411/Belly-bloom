import 'dart:developer';
import 'package:babyweb/model/health_metric_model.dart';
import 'package:babyweb/model/user_account.dart';
import 'package:babyweb/resource/color_manager.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/health_metric_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserHealthChartDialog extends StatefulWidget {
  final UserAccount user;

  const UserHealthChartDialog({
    super.key,
    required this.user,
  });

  @override
  State<UserHealthChartDialog> createState() => _UserHealthChartDialogState();
}

class _UserHealthChartDialogState extends State<UserHealthChartDialog> {
  List<HealthMetricModel> _healthMetrics = [];
  bool _isLoading = true;
  String _selectedMetric = 'weight'; // 'weight', 'height', 'bloodPressure', 'heartRate'
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
      if (widget.user.uid == null || widget.user.uid!.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final metrics = await HealthMetricService.getHealthMetrics(widget.user.uid!);
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
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
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
                      Icons.analytics,
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
                          'Thông tin sức khỏe',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(18, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name
                              : widget.user.email,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(14, context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(ColorManager.primary),
                      ),
                    )
                  : _healthMetrics.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.show_chart,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có dữ liệu sức khỏe',
                                style: TextStyle(
                                  fontSize:
                                      UtilsReponsive.formatFontSize(16, context),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(
                            UtilsReponsive.width(20, context),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Filter buttons
                              _buildFilterSection(),
                              SizedBox(
                                height: UtilsReponsive.height(20, context),
                              ),

                              // Metric selector
                              _buildMetricSelector(),
                              SizedBox(
                                height: UtilsReponsive.height(20, context),
                              ),

                              // Chart
                              _buildChart(),
                              SizedBox(
                                height: UtilsReponsive.height(20, context),
                              ),

                              // Legend
                              _buildLegend(),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.height(12, context)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
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
          color: isSelected
              ? ColorManager.primary
              : Colors.grey.shade200,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
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
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'Không có dữ liệu trong khoảng thời gian này',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(14, context),
              color: Colors.grey.shade600,
            ),
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
        border: Border.all(color: Colors.grey.shade200),
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
        return ColorManager.primary;
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
}


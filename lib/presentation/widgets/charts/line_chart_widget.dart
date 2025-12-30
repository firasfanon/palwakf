import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';

class LineChartWidget extends StatelessWidget {
  final List<LineChartDataPoint> data;
  final String? title;
  final double? maxY;
  final double? minY;
  final List<String>? bottomTitles;
  final Color lineColor;
  final bool showDots;
  final bool showGrid;
  final bool isCurved;

  const LineChartWidget({
    super.key,
    required this.data,
    this.title,
    this.maxY,
    this.minY,
    this.bottomTitles,
    this.lineColor = AppColors.islamicGreen,
    this.showDots = true,
    this.showGrid = true,
    this.isCurved = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              maxY: maxY,
              minY: minY ?? 0,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.black87,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        spot.y.toStringAsFixed(1),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: AppTextStyles.bodySmall,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: bottomTitles != null,
                    getTitlesWidget: (value, meta) {
                      if (bottomTitles == null) return const Text('');
                      final index = value.toInt();
                      if (index >= 0 && index < bottomTitles!.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            bottomTitles![index],
                            style: AppTextStyles.bodySmall,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: showGrid,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.borderLight,
                    strokeWidth: 1,
                  );
                },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.value);
                  }).toList(),
                  isCurved: isCurved,
                  color: lineColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: showDots),
                  belowBarData: BarAreaData(
                    show: true,
                    color: lineColor.withValues(alpha:0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LineChartDataPoint {
  final double value;

  LineChartDataPoint({required this.value});
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';

class PieChartWidget extends StatelessWidget {
  final List<PieChartDataItem> data;
  final String? title;
  final double radius;
  final bool showLegend;
  final double centerSpaceRadius;

  const PieChartWidget({
    super.key,
    required this.data,
    this.title,
    this.radius = 60,
    this.showLegend = true,
    this.centerSpaceRadius = 40,
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
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: centerSpaceRadius,
                    sections: data.map((item) {
                      return PieChartSectionData(
                        color: item.color,
                        value: item.value,
                        title: item.value.toStringAsFixed(0),
                        radius: radius,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                    ),
                  ),
                ),
              ),
            ),
            if (showLegend) ...[
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: data.map((item) => _buildLegendItem(item)).toList(),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(PieChartDataItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.label,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartDataItem {
  final String label;
  final double value;
  final Color color;

  PieChartDataItem({
    required this.label,
    required this.value,
    required this.color,
  });
}
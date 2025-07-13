import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StackedBarChartWidget extends StatefulWidget {
  final List<List<double>> data;
  final List<String> dateLabels;
  final List<String> legendLabels;
  final List<Color> colors;
  final String title;
  final double minY;
  final double maxY;
  final Widget Function(double value)? leftLabelBuilder;
  final Widget Function(String date)? bottomLabelBuilder;
  final Widget? customLegend;

  const StackedBarChartWidget({
    Key? key,
    required this.data,
    required this.dateLabels,
    required this.legendLabels,
    required this.colors,
    required this.title,
    this.minY = 0,
    this.maxY = 10,
    this.leftLabelBuilder,
    this.bottomLabelBuilder,
    this.customLegend,
  }) : super(key: key);

  @override
  State<StackedBarChartWidget> createState() => _StackedBarChartWidgetState();
}

class _StackedBarChartWidgetState extends State<StackedBarChartWidget> {
  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(widget.dateLabels.length, (i) {
      double runningTotal = 0;
      List<BarChartRodStackItem> stacks = [];

      for (int d = 0; d < widget.data.length; d++) {
        double from = runningTotal;
        runningTotal += widget.data[d][i];
        stacks.add(BarChartRodStackItem(from, runningTotal, widget.colors[d]));
      }

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: runningTotal,
            rodStackItems: stacks,
            width: 18,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxStackedValue = 0;
    for (int i = 0; i < widget.dateLabels.length; i++) {
      double total = 0;
      for (int d = 0; d < widget.data.length; d++) {
        total += widget.data[d][i];
      }
      if (total > maxStackedValue) {
        maxStackedValue = total;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => widget.leftLabelBuilder?.call(value) ??
                            Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 32,
                        getTitlesWidget: (value, _) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < widget.dateLabels.length) {
                            return widget.bottomLabelBuilder?.call(widget.dateLabels[idx]) ??
                                Text(widget.dateLabels[idx], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                  minY: widget.minY,
                  maxY: (maxStackedValue * 1.1).ceilToDouble(),
                  barGroups: _buildBarGroups(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey[300]!,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        int x = group.x.toInt();
                        return BarTooltipItem(
                          '${widget.dateLabels[x]}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            for (int i = 0; i < widget.data.length; i++)
                              TextSpan(
                                text: '${widget.data[i][x].toStringAsFixed(2)}\n',
                                style: TextStyle(color: widget.colors[i]),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            widget.customLegend ??
                Row(
                  children: [
                    for (int i = 0; i < widget.legendLabels.length; i++) ...[
                      Container(width: 16, height: 4, color: widget.colors[i]),
                      const SizedBox(width: 4),
                      Text(widget.legendLabels[i]),
                      const SizedBox(width: 16),
                    ]
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

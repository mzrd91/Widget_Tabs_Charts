import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StackedBarWidget extends StatelessWidget {
  final List<List<double>> data;
  final List<String> dateLabels;
  final List<String> legendLabels;
  final List<Color> colors;
  final String title;
  final double minY;
  final double maxY;

  const StackedBarWidget({
    Key? key,
    required this.data,
    required this.dateLabels,
    required this.legendLabels,
    required this.colors,
    required this.title,
    this.minY = 0,
    this.maxY = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the maximum total value for stacked bars
    double maxStackedValue = 0;
    for (int i = 0; i < dateLabels.length; i++) {
      double total = 0;
      for (int d = 0; d < data.length; d++) {
        total += data[d][i];
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        getTitlesWidget: (value, _) => Text(
                          value.toStringAsFixed(0), 
                          style: const TextStyle(fontSize: 10)
                        ),
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
                          if (idx >= 0 && idx < dateLabels.length) {
                            return Text(dateLabels[idx], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                  minY: minY,
                  maxY: (maxStackedValue * 1.1).ceilToDouble(), // Add 10% padding
                  barGroups: _buildBarGroups(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey[300]!,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        int x = group.x.toInt();
                        return BarTooltipItem(
                          '${dateLabels[x]}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            for (int i = 0; i < data.length; i++) ...[
                              TextSpan(
                                text: '${data[i][x].toStringAsFixed(2)}\n',
                                style: TextStyle(color: colors[i]),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 0; i < legendLabels.length; i++) ...[
                  Container(width: 16, height: 4, color: colors[i]),
                  const SizedBox(width: 4),
                  Text(legendLabels[i]),
                  const SizedBox(width: 16),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(dateLabels.length, (i) {
      double runningTotal = 0;
      List<BarChartRodStackItem> stacks = [];
      
      for (int d = 0; d < data.length; d++) {
        double from = runningTotal;
        runningTotal += data[d][i];
        stacks.add(BarChartRodStackItem(from, runningTotal, colors[d]));
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
} 
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final List<List<double>> data;
  final List<String> dateLabels;
  final List<String> legendLabels;
  final List<Color> colors;
  final String title;
  final String yAxisLabel;
  final double minY;
  final double maxY;
  final bool showMovingAverage;
  final bool showMinMaxIndicators;
  final List<int>? minMaxIndices;
  final String? currencySymbol;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.dateLabels,
    required this.legendLabels,
    required this.colors,
    required this.title,
    this.yAxisLabel = '',
    this.minY = 0,
    this.maxY = 100,
    this.showMovingAverage = false,
    this.showMinMaxIndicators = false,
    this.minMaxIndices,
    this.currencySymbol,
  }) : super(key: key);

  List<double> _calculateMovingAverage(List<double> data, int window) {
    if (data.isEmpty) return [];
    List<double> avg = [];
    for (int i = 0; i < data.length; i++) {
      int start = (i - window + 1).clamp(0, data.length - 1);
      double sum = 0;
      for (int j = start; j <= i; j++) {
        sum += data[j];
      }
      avg.add(sum / (i - start + 1));
    }
    return avg;
  }

  @override
  Widget build(BuildContext context) {
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
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: !showMinMaxIndicators, 
                    drawVerticalLine: false
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(
                          currencySymbol != null 
                            ? '$currencySymbol${value.toStringAsFixed(0)}'
                            : value.toStringAsFixed(0),
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
                  minX: 0,
                  maxX: (data[0].length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: _buildLineBarsData(),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blue[700]!,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map<LineTooltipItem?>((spot) {
                          String label = '';
                          if (showMinMaxIndicators && minMaxIndices != null) {
                            if (spot.spotIndex == minMaxIndices![0]) label = 'Min';
                            if (spot.spotIndex == minMaxIndices![1]) label = 'Max';
                          }
                          return LineTooltipItem(
                            '${dateLabels[spot.x.toInt()]}\n${currencySymbol ?? ''}${spot.y.toStringAsFixed(1)} $label',
                            TextStyle(
                              color: label == 'Min' ? Colors.red : 
                                     label == 'Max' ? Colors.green : 
                                     Colors.white
                            ),
                          );
                        }).toList();
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
                ],
                if (showMinMaxIndicators) ...[
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Min'),
                  const SizedBox(width: 12),
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Max'),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData() {
    List<LineChartBarData> lineBars = [];
    
    // Main data lines
    for (int i = 0; i < data.length; i++) {
      lineBars.add(LineChartBarData(
        spots: List.generate(data[i].length, (j) => FlSpot(j.toDouble(), data[i][j])),
        isCurved: true,
        color: colors[i],
        barWidth: 3,
        dotData: FlDotData(
          show: showMinMaxIndicators,
          getDotPainter: (spot, percent, bar, index) {
            if (showMinMaxIndicators && minMaxIndices != null) {
              if (index == minMaxIndices![0]) {
                return FlDotCirclePainter(
                  radius: 5, 
                  color: Colors.red, 
                  strokeWidth: 2, 
                  strokeColor: Colors.white
                );
              } else if (index == minMaxIndices![1]) {
                return FlDotCirclePainter(
                  radius: 5, 
                  color: Colors.green, 
                  strokeWidth: 2, 
                  strokeColor: Colors.white
                );
              }
            }
            return FlDotCirclePainter(
              radius: 3, 
              color: colors[i], 
              strokeWidth: 1, 
              strokeColor: Colors.white
            );
          },
        ),
      ));
    }
    
    // Moving average line (if enabled)
    if (showMovingAverage && data.isNotEmpty) {
      List<double> movingAvg = _calculateMovingAverage(data[0], data[0].length);
      lineBars.add(LineChartBarData(
        spots: List.generate(movingAvg.length, (i) => FlSpot(i.toDouble(), movingAvg[i])),
        isCurved: true,
        color: Colors.orange,
        barWidth: 2,
        dotData: FlDotData(show: false),
        dashArray: [6, 4],
      ));
    }
    
    return lineBars;
  }
} 
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartCustomWidget extends StatefulWidget {
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

  final Widget Function(String label, Color color)? legendItemBuilder;
  final String Function(double value)? yAxisLabelFormatter;

  const LineChartCustomWidget({
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
    this.legendItemBuilder,
    this.yAxisLabelFormatter,
  }) : super(key: key);

  @override
  State<LineChartCustomWidget> createState() => _LineChartCustomWidgetState();
}

class _LineChartCustomWidgetState extends State<LineChartCustomWidget> {
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
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (widget.maxY - widget.minY) / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) =>
                            Text(widget.yAxisLabelFormatter?.call(value) ??
                                (widget.currencySymbol != null
                                    ? '${widget.currencySymbol}${value.toStringAsFixed(0)}'
                                    : value.toStringAsFixed(0))),
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
                            return Text(widget.dateLabels[idx], style: const TextStyle(fontSize: 10));
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
                  maxX: (widget.data[0].length - 1).toDouble(),
                  minY: widget.minY,
                  maxY: widget.maxY,
                  lineBarsData: _buildLineBarsData(),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blue[700]!,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map<LineTooltipItem?>((spot) {
                          String label = '';
                          if (widget.showMinMaxIndicators && widget.minMaxIndices != null) {
                            if (spot.spotIndex == widget.minMaxIndices![0]) label = 'Min';
                            if (spot.spotIndex == widget.minMaxIndices![1]) label = 'Max';
                          }
                          return LineTooltipItem(
                            '${widget.dateLabels[spot.x.toInt()]}\n${widget.currencySymbol ?? ''}${spot.y.toStringAsFixed(1)} $label',
                            TextStyle(
                              color: label == 'Min'
                                  ? Colors.red
                                  : label == 'Max'
                                      ? Colors.green
                                      : Colors.white,
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
                for (int i = 0; i < widget.legendLabels.length; i++) ...[
                  widget.legendItemBuilder?.call(widget.legendLabels[i], widget.colors[i]) ??
                      Row(
                        children: [
                          Container(width: 16, height: 4, color: widget.colors[i]),
                          const SizedBox(width: 4),
                          Text(widget.legendLabels[i]),
                          const SizedBox(width: 16),
                        ],
                      ),
                ],
                if (widget.showMinMaxIndicators) ...[
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

    for (int i = 0; i < widget.data.length; i++) {
      lineBars.add(LineChartBarData(
        spots: List.generate(widget.data[i].length, (j) => FlSpot(j.toDouble(), widget.data[i][j])),
        isCurved: true,
        color: widget.colors[i],
        barWidth: 3,
        dotData: FlDotData(
          show: widget.showMinMaxIndicators,
          getDotPainter: (spot, percent, bar, index) {
            if (widget.showMinMaxIndicators && widget.minMaxIndices != null) {
              if (index == widget.minMaxIndices![0]) {
                return FlDotCirclePainter(radius: 5, color: Colors.red, strokeWidth: 2, strokeColor: Colors.white);
              } else if (index == widget.minMaxIndices![1]) {
                return FlDotCirclePainter(radius: 5, color: Colors.green, strokeWidth: 2, strokeColor: Colors.white);
              }
            }
            return FlDotCirclePainter(radius: 3, color: widget.colors[i], strokeWidth: 1, strokeColor: Colors.white);
          },
        ),
        belowBarData: BarAreaData(show: true, color: widget.colors[i].withOpacity(0.1)),
      ));
    }

    if (widget.showMovingAverage && widget.data.isNotEmpty) {
      List<double> movingAvg = _calculateMovingAverage(widget.data[0], widget.data[0].length);
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

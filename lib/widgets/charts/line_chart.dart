import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatefulWidget {
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

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Future: Initialize data loading
    // _loadChartData();
  }

  // Future method for backend integration
  Future<void> _loadChartData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Future: Replace with actual API calls
      // final data = await ApiService.getLineChartData();

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load chart data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
            Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Error message
            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => errorMessage = null),
                      icon: const Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],

            // Loading state
            if (isLoading) ...[
              SizedBox(
                height: 220,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Loading chart data...', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Chart content
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: !widget.showMinMaxIndicators,
                      drawVerticalLine: false,
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) => Text(
                            widget.currencySymbol != null
                                ? '${widget.currencySymbol}${value.toStringAsFixed(0)}'
                                : value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
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
              ), // ✅ This line was missing
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 0; i < widget.legendLabels.length; i++) ...[
                  Container(width: 16, height: 4, color: widget.colors[i]),
                  const SizedBox(width: 4),
                  Text(widget.legendLabels[i]),
                  const SizedBox(width: 16),
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

    // Main data lines
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
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.red,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              } else if (index == widget.minMaxIndices![1]) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.green,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              }
            }
            return FlDotCirclePainter(
              radius: 3,
              color: widget.colors[i],
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
      ));
    }

    // Moving average line (if enabled)
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

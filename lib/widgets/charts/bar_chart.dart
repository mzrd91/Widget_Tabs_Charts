import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final String title;
  final double minY;
  final double maxY;
  final String yAxisLabel;
  final Color? barColor;
  final List<Color>? barColors;

  const BarChartWidget({
    Key? key,
    required this.data,
    required this.labels,
    required this.title,
    this.minY = 0,
    this.maxY = 50,
    this.yAxisLabel = '',
    this.barColor,
    this.barColors,
  }) : super(key: key);

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
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
      // final data = await ApiService.getBarChartData();

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

  Color _getBarColor(int index, double value) {
    if (widget.barColors != null && index < widget.barColors!.length) {
      return widget.barColors![index];
    }

    if (widget.barColor != null) {
      return widget.barColor!;
    }

    // All bars are green
    return Colors.green[600]!;
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
                height: 300,
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
                height: 300,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()}h',
                            style: const TextStyle(fontSize: 10),
                          ),
                          reservedSize: 40,
                          interval: 10,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            int idx = value.toInt();
                            if (idx >= 0 && idx < widget.labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  widget.labels[idx],
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 60,
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                    minY: widget.minY,
                    maxY: widget.maxY,
                    barGroups: _buildBarGroups(),
                                      extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      // 25h Part-time line
                      HorizontalLine(
                        y: 25,
                        color: Colors.orange[600]!,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 8, top: 4),
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          labelResolver: (line) => '25 Hr',
                        ),
                      ),
                      // 40h Full-time line
                      HorizontalLine(
                        y: 40,
                        color: Colors.red[600]!,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 8, top: 4),
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          labelResolver: (line) => '40 Hr',
                        ),
                      ),
                    ],
                  ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blue[700]!,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${widget.labels[group.x.toInt()]}\n${widget.data[group.x.toInt()].toStringAsFixed(1)} hours',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 16, height: 4, color: Colors.green[600]),
                const SizedBox(width: 4),
                const Text('Staff Hours'),
                const SizedBox(width: 16),
                Container(width: 16, height: 4, color: Colors.orange[600]),
                const SizedBox(width: 4),
                const Text('25h Part-time'),
                const SizedBox(width: 16),
                Container(width: 16, height: 4, color: Colors.red[600]),
                const SizedBox(width: 4),
                const Text('40h Full-time'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(widget.data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: widget.data[i],
            color: _getBarColor(i, widget.data[i]),
            width: 30,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}

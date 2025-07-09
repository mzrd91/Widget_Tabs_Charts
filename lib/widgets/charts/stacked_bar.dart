import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StackedBarWidget extends StatefulWidget {
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
  State<StackedBarWidget> createState() => _StackedBarWidgetState();
}

class _StackedBarWidgetState extends State<StackedBarWidget> {
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
      // final data = await ApiService.getStackedBarData();
      
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

  @override
  Widget build(BuildContext context) {
    // Calculate the maximum total value for stacked bars
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
                  minY: widget.minY,
                  maxY: (maxStackedValue * 1.1).ceilToDouble(), // Add 10% padding
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
                            for (int i = 0; i < widget.data.length; i++) ...[
                              TextSpan(
                                text: '${widget.data[i][x].toStringAsFixed(2)}\n',
                                style: TextStyle(color: widget.colors[i]),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
                )
              ),
            ],
            const SizedBox(height: 8),
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
} 
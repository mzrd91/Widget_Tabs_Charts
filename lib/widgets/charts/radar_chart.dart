import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RadarChartWidget extends StatefulWidget {
  final List<List<double>> data;
  final List<String> labels;
  final List<String> legendLabels;
  final List<Color> colors;
  final String title;
  final double maxValue;
  final int tickCount;

  const RadarChartWidget({
    Key? key,
    required this.data,
    required this.labels,
    required this.legendLabels,
    required this.colors,
    required this.title,
    this.maxValue = 10.0,
    this.tickCount = 5,
  }) : super(key: key);

  @override
  State<RadarChartWidget> createState() => _RadarChartWidgetState();
}

class _RadarChartWidgetState extends State<RadarChartWidget> {
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
      // final data = await ApiService.getRadarChartData();

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
                height: 400,
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
                height: 400,
                child: RadarChart(
                  RadarChartData(
                    dataSets: _buildDataSets(),
                    titleTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    titlePositionPercentageOffset: 0.2,
                    tickCount: widget.tickCount,
                    ticksTextStyle: const TextStyle(fontSize: 8),
                    getTitle: (index, angle) {
                      return RadarChartTitle(
                        text: widget.labels[index],
                        angle: angle,
                      );
                    },
                    tickBorderData: const BorderSide(color: Colors.grey, width: 1),
                    borderData: FlBorderData(show: false),
                    gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                    radarBorderData: const BorderSide(color: Colors.transparent),
                    radarTouchData: RadarTouchData(enabled: true),
                  ),
                ),
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

  List<RadarDataSet> _buildDataSets() {
    return List.generate(widget.data.length, (index) {
      return RadarDataSet(
        dataEntries: List.generate(widget.labels.length, (i) {
          return RadarEntry(value: widget.data[index][i]);
        }),
        fillColor: widget.colors[index].withOpacity(0.3),
        borderColor: widget.colors[index],
        entryRadius: 3,
        borderWidth: 2,
      );
    });
  }
}

import 'package:flutter/material.dart';

class StaffHeatMapWidget extends StatefulWidget {
  final List<List<double>> data;
  final List<String> dateLabels;
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final Function(int day, int hour, double value, String date)? onCellTap;

  const StaffHeatMapWidget({
    Key? key,
    required this.data,
    required this.dateLabels,
    required this.title,
    this.xAxisLabel = 'Hour',
    this.yAxisLabel = 'Date',
    this.onCellTap,
  }) : super(key: key);

  @override
  State<StaffHeatMapWidget> createState() => _StaffHeatMapWidgetState();
}

class _StaffHeatMapWidgetState extends State<StaffHeatMapWidget> {
  double get _minValue {
    double minVal = double.infinity;
    for (var day in widget.data) {
      for (var value in day) {
        if (value < minVal) minVal = value;
      }
    }
    return minVal;
  }

  double get _maxValue {
    double maxVal = 0;
    for (var day in widget.data) {
      for (var value in day) {
        if (value > maxVal) maxVal = value;
      }
    }
    return maxVal;
  }

  // Column-specific color scale for staff analysis
  Color _getColumnSpecificColor(double value, int columnIndex) {
    switch (columnIndex) {
      case 0: // Customer Satisfaction (0-10 scale)
        if (value >= 8.5) return Colors.green[600]!;
        if (value >= 7.0) return Colors.yellow[600]!;
        return Colors.red[600]!;
      case 1: // Evaluation Rate (0-10 scale)
        if (value >= 9.0) return Colors.green[600]!;
        if (value >= 8.0) return Colors.yellow[600]!;
        return Colors.red[600]!;
      case 2: // Weekly Hours (20-50 hours)
        if (value >= 40) return Colors.red[600]!; // Over 40 hours = red (overtime)
        if (value >= 35) return Colors.green[600]!; // 35-40 hours = green (ideal)
        return Colors.yellow[600]!; // Less than 35 hours = yellow
      default:
        return Colors.grey[400]!;
    }
  }

  String _getColumnSpecificText(double value, int columnIndex) {
    switch (columnIndex) {
      case 0: // Customer Satisfaction
      case 1: // Evaluation Rate
        return value.toStringAsFixed(1);
      case 2: // Weekly Hours
        return value.toInt().toString();
      default:
        return value.toStringAsFixed(1);
    }
  }

  void _showDetails(int day, int hour, double value, String date) {
    if (widget.onCellTap != null) {
      widget.onCellTap!(day, hour, value, date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int columnCount = widget.data.isNotEmpty ? widget.data[0].length : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 500,
              child: Column(
                children: [
                  Container(
                    height: 30,
                    child: Row(
                      children: [
                        const SizedBox(width: 80),
                        ...List.generate(columnCount, (i) => Expanded(
                              child: Text(
                                _getColumnTitle(i),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(widget.dateLabels.length, (dayIndex) {
                          return Container(
                            height: 35,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Text(
                                      widget.dateLabels[dayIndex],
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: List.generate(columnCount, (hourIndex) {
                                      final value = widget.data[dayIndex][hourIndex];
                                      final cellColor = _getColumnSpecificColor(value, hourIndex);
                                      final displayText = _getColumnSpecificText(value, hourIndex);

                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () => _showDetails(dayIndex, hourIndex, value, widget.dateLabels[dayIndex]),
                                          child: Container(
                                            height: 35,
                                            margin: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: cellColor,
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: Colors.grey[300]!, width: 0.5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                displayText,
                                                style: const TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildCustomLegend(),
          ],
        ),
      ),
    );
  }

  String _getColumnTitle(int columnIndex) {
    switch (columnIndex) {
      case 0:
        return 'CS';
      case 1:
        return 'ER';
      case 2:
        return 'WH';
      default:
        return '$columnIndex';
    }
  }

  Widget _buildCustomLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Legend:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            // Customer Satisfaction legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Satisfaction:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green[600], borderRadius: BorderRadius.circular(2))),
                      const Text(' ≥8.5 ', style: TextStyle(fontSize: 8)),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.yellow[600], borderRadius: BorderRadius.circular(2))),
                      const Text(' 7.0-8.4 ', style: TextStyle(fontSize: 8)),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red[600], borderRadius: BorderRadius.circular(2))),
                      const Text(' <7.0', style: TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),
            // Weekly Hours legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weekly Hours:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red[600], borderRadius: BorderRadius.circular(2))),
                      const Text(' ≥40h ', style: TextStyle(fontSize: 8)),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green[600], borderRadius: BorderRadius.circular(2))),
                      const Text(' 35-39h ', style: TextStyle(fontSize: 8)),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.yellow[600], borderRadius: BorderRadius.circular(2))),
                      const Text(' <35h', style: TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
} 
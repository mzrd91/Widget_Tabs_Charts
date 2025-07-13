import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../widgets/charts/charts.dart';

class QualityTab extends StatefulWidget {
  const QualityTab({Key? key}) : super(key: key);

  @override
  State<QualityTab> createState() => _QualityTabState();
}

class _QualityTabState extends State<QualityTab> {
  final List<int> _dateRanges = [7, 14, 30];
  int _selectedRange = 7;

  // Inspection failure reasons for Pareto chart
  final List<String> _failureReasons = [
    'Linens Not Replaced',
    'Bathroom Not Clean',
    'Dust on Surfaces',
    'Amenities Missing',
    'Bed Not Made Properly',
    'Trash Not Emptied',
    'Towels Not Fresh',
    'Floor Not Vacuumed'
  ];

  final List<Color> _failureColors = [
    Colors.red[400]!,
    Colors.orange[400]!,
    Colors.yellow[600]!,
    Colors.blue[400]!,
    Colors.purple[400]!,
    Colors.teal[400]!,
    Colors.pink[400]!,
    Colors.indigo[400]!,
  ];

  List<String> get _dateLabels {
    final now = DateTime.now();
    return List.generate(_selectedRange, (i) {
      final date = now.subtract(Duration(days: _selectedRange - 1 - i));
      return DateFormat('MM/dd').format(date);
    });
  }

  // Generate inspection pass rate data
  double get _inspectionPassRate {
    final rand = Random(_selectedRange);
    return 85 + rand.nextDouble() * 15; // 85-100%
  }

  // Generate failure reason data for Pareto chart
  List<double> get _failureReasonData {
    final rand = Random(_selectedRange + 100);
    return List.generate(_failureReasons.length, (i) {
      return 10 + rand.nextDouble() * 40 + (i * 2); // Higher values for first items
    });
  }

  // Generate response time data for heatmap (in minutes)
  List<List<double>> get _responseTimeData {
    final rand = Random(_selectedRange + 200);
    return List.generate(_selectedRange, (day) {
      return List.generate(24, (hour) {
        // Weekends and late hours have slower response times
        bool isWeekend = (DateTime.now().weekday - _selectedRange + day) % 7 >= 5;
        bool isLateHour = hour < 6 || hour > 22;
        double baseTime = isWeekend ? 25 : 15;
        baseTime += isLateHour ? 10 : 0;
        return baseTime + rand.nextDouble() * 20;
      });
    });
  }

  // Generate rework rate data
  List<double> get _reworkRateData {
    final rand = Random(_selectedRange + 300);
    return List.generate(_selectedRange, (i) => 5 + rand.nextDouble() * 15);
  }

  @override
  Widget build(BuildContext context) {
    final passRate = _inspectionPassRate;
    final failureData = _failureReasonData;
    final responseData = _responseTimeData;
    final reworkData = _reworkRateData;
    final dateLabels = _dateLabels;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Quality Metrics',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              DropdownButton<int>(
                value: _selectedRange,
                items: _dateRanges.map((days) {
                  return DropdownMenuItem<int>(
                    value: days,
                    child: Text('Last $days days'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRange = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// KPI Tile: Inspection Pass Rate
          InspectionPassRateWidget(passRate: passRate),

          const SizedBox(height: 24),

          /// Chart 1: First-Pass Yield (Pareto Chart)
          ParetoChartCustomWidget(
            data: failureData,
            labels: _failureReasons,
            colors: _failureColors,
            title: 'First-Pass Yield: Top Failure Reasons',
          ),

          const SizedBox(height: 24),

          /// Chart 2: Guest Service Response Time Heatmap
          CustomHeatMapWidget(
            data: responseData,
            dateLabels: dateLabels,
            title: 'Guest Service Response Time (Minutes)',
            onCellTap: _showResponseTimeDetails,
          ),

          const SizedBox(height: 24),

          /// Chart 3: Service Rework Rate Trend
          LineChartCustomWidget(
            data: [reworkData],
            dateLabels: dateLabels,
            legendLabels: ['Rework Rate'],
            colors: [Colors.red[400]!],
            title: 'Service Rework Rate (%)',
            minY: 0,
            maxY: reworkData.reduce((a, b) => a > b ? a : b) + 5,
          ),
        ],
      ),
    );
  }





  void _showResponseTimeDetails(int day, int hour, double responseTime, String date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Response Time Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date'),
            Text('Hour: ${hour}:00'),
            Text('Average Response Time: ${responseTime.toStringAsFixed(1)} minutes'),
            const SizedBox(height: 16),
            const Text('Sample Requests:'),
            Text('• Room service order - ${(responseTime * 0.8).toStringAsFixed(1)} min'),
            Text('• Towel request - ${(responseTime * 1.2).toStringAsFixed(1)} min'),
            Text('• Maintenance call - ${(responseTime * 1.5).toStringAsFixed(1)} min'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

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
          _buildInspectionPassRateCard(passRate),

          const SizedBox(height: 24),

          /// Chart 1: First-Pass Yield (Pareto Chart)
          _buildParetoChart(failureData),

          const SizedBox(height: 24),

          /// Chart 2: Guest Service Response Time Heatmap
          _buildResponseTimeHeatmap(responseData, dateLabels),

          const SizedBox(height: 24),

          /// Chart 3: Service Rework Rate Trend
          _buildReworkRateChart(reworkData, dateLabels),
        ],
      ),
    );
  }

  Widget _buildInspectionPassRateCard(double passRate) {
    bool isAlert = passRate < 95;
    
    return Card(
      color: isAlert ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isAlert ? Colors.red[100] : Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAlert ? Icons.warning : Icons.check_circle,
                size: 40,
                color: isAlert ? Colors.red[700] : Colors.green[700],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inspection Pass Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAlert ? Colors.red[700] : Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${passRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isAlert ? Colors.red[700] : Colors.green[700],
                    ),
                  ),
                  Text(
                    isAlert ? 'Below target (95%)' : 'Above target',
                    style: TextStyle(
                      fontSize: 14,
                      color: isAlert ? Colors.red[600] : Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParetoChart(List<double> failureData) {
    // Sort data for Pareto analysis
    List<MapEntry<int, double>> sortedData = [];
    for (int i = 0; i < failureData.length; i++) {
      sortedData.add(MapEntry(i, failureData[i]));
    }
    sortedData.sort((a, b) => b.value.compareTo(a.value));

    // Calculate cumulative percentages
    double total = failureData.reduce((a, b) => a + b);
    List<double> cumulative = [];
    double runningTotal = 0;
    for (var entry in sortedData) {
      runningTotal += entry.value;
      cumulative.add((runningTotal / total) * 100);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('First-Pass Yield: Top Failure Reasons', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: failureData.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        int originalIndex = sortedData[group.x.toInt()].key;
                        return BarTooltipItem(
                          '${_failureReasons[originalIndex]}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toStringAsFixed(1)} failures\n',
                              style: const TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: '${cumulative[group.x.toInt()].toStringAsFixed(1)}% cumulative',
                              style: const TextStyle(color: Colors.yellow),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedData.length) return const Text('');
                          int originalIndex = sortedData[value.toInt()].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _failureReasons[originalIndex].split(' ').take(2).join(' '),
                              style: const TextStyle(fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 60,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(sortedData.length, (index) {
                    int originalIndex = sortedData[index].key;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: sortedData[index].value,
                          color: _failureColors[originalIndex],
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Cumulative line overlay
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(cumulative.length, (i) => FlSpot(i.toDouble(), cumulative[i])),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 16, height: 4, color: Colors.blue),
                const SizedBox(width: 4),
                const Text('Failure Count'),
                const SizedBox(width: 16),
                Container(width: 16, height: 4, color: Colors.orange),
                const SizedBox(width: 4),
                const Text('Cumulative %'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTimeHeatmap(List<List<double>> responseData, List<String> dateLabels) {
    // Find min and max for color scaling
    double minTime = double.infinity;
    double maxTime = 0;
    for (var day in responseData) {
      for (var time in day) {
        if (time < minTime) minTime = time;
        if (time > maxTime) maxTime = time;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guest Service Response Time (Minutes)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 500, // Increased height for bigger heatmap
              child: Column(
                children: [
                  // Hour labels (fixed header)
                  Container(
                    height: 30,
                    child: Row(
                      children: [
                        const SizedBox(width: 80), // Increased space for date labels
                        ...List.generate(24, (hour) => Expanded(
                          child: Text(
                            hour.toString(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Heatmap grid with perfectly synchronized scrolling
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(dateLabels.length, (dayIndex) {
                          return Container(
                            height: 35, // Fixed height for each row
                            child: Row(
                              children: [
                                // Date label (fixed width)
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Text(
                                      dateLabels[dayIndex],
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                // Heatmap cells for this day
                                Expanded(
                                  child: Row(
                                    children: List.generate(24, (hourIndex) {
                                      double responseTime = responseData[dayIndex][hourIndex];
                                      
                                      // Calculate color intensity
                                      double normalized = (responseTime - minTime) / (maxTime - minTime);
                                      Color cellColor = _getHeatmapColor(normalized);
                                      
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () => _showResponseTimeDetails(dayIndex, hourIndex, responseTime, dateLabels[dayIndex]),
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
                                                responseTime.toInt().toString(),
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  color: normalized > 0.6 ? Colors.white : Colors.black,
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
            Row(
              children: [
                const Text('Response Time: '),
                Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))),
                const Text(' Fast (<15min) '),
                Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(2))),
                const Text(' Medium (15-30min) '),
                Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))),
                const Text(' Slow (>30min)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeatmapColor(double normalized) {
    if (normalized < 0.33) {
      return Colors.green.withOpacity(0.3 + normalized * 0.7);
    } else if (normalized < 0.66) {
      return Colors.yellow.withOpacity(0.3 + (normalized - 0.33) * 1.5);
    } else {
      return Colors.red.withOpacity(0.3 + (normalized - 0.66) * 1.5);
    }
  }

  void _showResponseTimeDetails(int day, int hour, double responseTime, String date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Response Time Details'),
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

  Widget _buildReworkRateChart(List<double> reworkData, List<String> dateLabels) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service Rework Rate (%)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
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
                  maxX: (reworkData.length - 1).toDouble(),
                  minY: 0,
                  maxY: reworkData.reduce((a, b) => a > b ? a : b) + 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(reworkData.length, (i) => FlSpot(i.toDouble(), reworkData[i])),
                      isCurved: true,
                      color: Colors.red[400]!,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          Color dotColor = reworkData[index] > 15 ? Colors.red : Colors.orange;
                          return FlDotCirclePainter(
                            radius: 4,
                            color: dotColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red[50]!,
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.red[700]!,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map<LineTooltipItem?>((spot) {
                          String status = reworkData[spot.x.toInt()] > 15 ? 'High' : 'Normal';
                          return LineTooltipItem(
                            '${dateLabels[spot.x.toInt()]}\n${spot.y.toStringAsFixed(1)}% ($status)',
                            const TextStyle(color: Colors.white),
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
                Container(width: 16, height: 4, color: Colors.red[400]),
                const SizedBox(width: 4),
                const Text('Rework Rate'),
                const SizedBox(width: 16),
                Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('High (>15%)'),
                const SizedBox(width: 12),
                Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Normal'),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
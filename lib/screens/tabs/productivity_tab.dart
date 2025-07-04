import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class ProductivityTab extends StatefulWidget {
  const ProductivityTab({Key? key}) : super(key: key);

  @override
  State<ProductivityTab> createState() => _ProductivityTabState();
}

class _ProductivityTabState extends State<ProductivityTab> {
  final List<int> _dateRanges = [7, 14, 30];
  int _selectedRange = 7;

  final List<String> _departments = ['Housekeeping', 'Front Desk', 'Maintenance'];
  final List<Color> _deptColors = [Colors.blue, Colors.orange, Colors.green];

  List<String> get _dateLabels {
    final now = DateTime.now();
    return List.generate(_selectedRange, (i) {
      final date = now.subtract(Duration(days: _selectedRange - 1 - i));
      return DateFormat('MM/dd').format(date);
    });
  }

  List<double> get _mporData {
    final rand = Random(_selectedRange);
    return List.generate(_selectedRange, (i) => 18 + rand.nextDouble() * 17);
  }

  List<double> _movingAverage(List<double> data, int window) {
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

  List<List<double>> get _tasksPerLaborHourData {
    final rand = Random(_selectedRange + 100);
    return List.generate(_departments.length, (deptIdx) {
      return List.generate(_selectedRange, (i) => 1.5 + rand.nextDouble() * 2.5 + deptIdx);
    });
  }

  List<double> get _revenuePerLaborHourData {
    final rand = Random(_selectedRange + 200);
    return List.generate(_selectedRange, (i) => 30 + rand.nextDouble() * 40);
  }

  @override
  Widget build(BuildContext context) {
    final mporData = _mporData;
    final mporAvg = _movingAverage(mporData, _selectedRange);
    final dateLabels = _dateLabels;
    final tasksData = _tasksPerLaborHourData;
    final revenueData = _revenuePerLaborHourData;
    final minIndex = revenueData.indexOf(revenueData.reduce(min));
    final maxIndex = revenueData.indexOf(revenueData.reduce(max));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Productivity Metrics',
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

          // Chart 1: MPOR Line Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Minutes per Occupied Room (MPOR)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              getTitlesWidget: (value, _) => Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int idx = value.toInt();
                                if (idx >= 0 && idx < dateLabels.length) {
                                  return Text(dateLabels[idx], style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                              reservedSize: 32,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                        minX: 0,
                        maxX: (mporData.length - 1).toDouble(),
                        minY: 0,
                        maxY: 40,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(mporData.length, (i) => FlSpot(i.toDouble(), mporData[i])),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: List.generate(mporAvg.length, (i) => FlSpot(i.toDouble(), mporAvg[i])),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                            dashArray: [6, 4],
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.blue[700]!,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map<LineTooltipItem?>((spot) {
                                return LineTooltipItem(
                                  '${dateLabels[spot.x.toInt()]}\n${spot.y.toStringAsFixed(1)} min',
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
                      Container(width: 16, height: 4, color: Colors.blue),
                      const SizedBox(width: 4),
                      const Text('Daily MPOR'),
                      const SizedBox(width: 16),
                      Container(width: 16, height: 4, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text('Moving Avg'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Chart 2: Tasks Completed per Labor Hour (Stacked Bar)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tasks Completed per Labor Hour', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              getTitlesWidget: (value, _) => Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int idx = value.toInt();
                                if (idx >= 0 && idx < dateLabels.length) {
                                  return Text(dateLabels[idx], style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                              reservedSize: 32,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                        minY: 0,
                        maxY: 10,
                        barGroups: List.generate(_selectedRange, (i) {
                          double runningTotal = 0;
                          List<BarChartRodStackItem> stacks = [];
                          for (int d = 0; d < _departments.length; d++) {
                            double from = runningTotal;
                            runningTotal += tasksData[d][i];
                            stacks.add(BarChartRodStackItem(from, runningTotal, _deptColors[d]));
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
                        }),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              double y = rod.toY;
                              double fromY = 0;
                              String dept = '';
                              double value = 0;
                              for (int d = 0; d < _departments.length; d++) {
                                double toY = fromY + tasksData[d][group.x.toInt()];
                                if (y <= toY) {
                                  dept = _departments[d];
                                  value = tasksData[d][group.x.toInt()];
                                  break;
                                }
                                fromY = toY;
                              }
                              return BarTooltipItem(
                                '$dept\n${dateLabels[group.x.toInt()]}\n${value.toStringAsFixed(2)} tasks/hr',
                                const TextStyle(color: Colors.white),
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
                      for (int i = 0; i < _departments.length; i++) ...[
                        Container(width: 16, height: 4, color: _deptColors[i]),
                        const SizedBox(width: 4),
                        Text(_departments[i]),
                        const SizedBox(width: 16),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Chart 3: Revenue per Labor Hour
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Revenue (or GOP) per Labor Hour', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) => Text('\$${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10)),
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int idx = value.toInt();
                                if (idx >= 0 && idx < dateLabels.length) {
                                  return Text(dateLabels[idx], style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                              reservedSize: 32,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                        minX: 0,
                        maxX: (revenueData.length - 1).toDouble(),
                        minY: 0,
                        maxY: (revenueData.reduce(max) + 10),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(revenueData.length, (i) => FlSpot(i.toDouble(), revenueData[i])),
                            isCurved: true,
                            color: Colors.purple,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) {
                                if (index == minIndex) {
                                  return FlDotCirclePainter(radius: 5, color: Colors.red, strokeWidth: 2, strokeColor: Colors.white);
                                } else if (index == maxIndex) {
                                  return FlDotCirclePainter(radius: 5, color: Colors.green, strokeWidth: 2, strokeColor: Colors.white);
                                }
                                return FlDotCirclePainter(radius: 3, color: Colors.purple, strokeWidth: 1, strokeColor: Colors.white);
                              },
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map<LineTooltipItem?>((spot) {
                                String label = '';
                                if (spot.spotIndex == minIndex) {
                                  label = 'Min';
                                } else if (spot.spotIndex == maxIndex) {
                                  label = 'Max';
                                }
                                return LineTooltipItem(
                                  '${dateLabels[spot.x.toInt()]}\n\$${spot.y.toStringAsFixed(2)} $label',
                                  TextStyle(color: label == 'Min' ? Colors.red : label == 'Max' ? Colors.green : Colors.white),
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
                      Container(width: 16, height: 4, color: Colors.purple),
                      const SizedBox(width: 4),
                      const Text('Revenue per Labor Hour'),
                      const SizedBox(width: 16),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Min'),
                      const SizedBox(width: 12),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Max'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

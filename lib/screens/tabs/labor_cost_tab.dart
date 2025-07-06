import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class LaborCostTab extends StatefulWidget {
  const LaborCostTab({Key? key}) : super(key: key);

  @override
  State<LaborCostTab> createState() => _LaborCostTabState();
}

class _LaborCostTabState extends State<LaborCostTab> {
  final List<int> _dateRanges = [7, 14, 30];
  int _selectedRange = 7;

  final List<String> _departments = ['Housekeeping', 'Front Desk', 'F&B', 'Maintenance'];
  final List<Color> _deptColors = [Colors.blue, Colors.red, Colors.green, Colors.purple];

  List<String> get _dateLabels {
    final now = DateTime.now();
    return List.generate(_selectedRange, (i) {
      final date = now.subtract(Duration(days: _selectedRange - 1 - i));
      return DateFormat('MM/dd').format(date);
    });
  }

  List<List<double>> get _laborCostData {
    final rand = Random(_selectedRange);
    return List.generate(_departments.length, (deptIdx) {
      return List.generate(_selectedRange, (i) {
        double baseCost = 800 + (deptIdx * 200);
        bool isWeekend = (DateTime.now().weekday - _selectedRange + i) % 7 >= 5;
        baseCost += isWeekend ? 200 : 0;
        return baseCost + rand.nextDouble() * 400;
      });
    });
  }

  List<double> get _occupancyData {
    final rand = Random(_selectedRange + 100);
    return List.generate(_selectedRange, (i) {
      bool isWeekend = (DateTime.now().weekday - _selectedRange + i) % 7 >= 5;
      double baseOccupancy = isWeekend ? 85 : 65;
      return baseOccupancy + rand.nextDouble() * 20;
    });
  }

  List<double> get _forecastVarianceData {
    final rand = Random(_selectedRange + 200);
    return List.generate(_selectedRange, (i) {
      return -20 + rand.nextDouble() * 40;
    });
  }

  double get _overtimePercentage {
    final rand = Random(_selectedRange + 300);
    return 5 + rand.nextDouble() * 15;
  }

  @override
  Widget build(BuildContext context) {
    final laborCostData = _laborCostData;
    final occupancyData = _occupancyData;
    final varianceData = _forecastVarianceData;
    final overtimePercentage = _overtimePercentage;
    final dateLabels = _dateLabels;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Labor Cost Analysis',
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
          _buildLaborCostStackedAreaChart(laborCostData, occupancyData, dateLabels),
          const SizedBox(height: 24),
          _buildForecastVarianceWaterfallChart(varianceData, dateLabels),
          const SizedBox(height: 24),
          _buildOvertimeGaugeChart(overtimePercentage),
        ],
      ),
    );
  }

  Widget _buildLaborCostStackedAreaChart(List<List<double>> laborCostData, List<double> occupancyData, List<String> dateLabels) {
    List<double> totalLaborCost = [];
    for (int i = 0; i < _selectedRange; i++) {
      double total = 0;
      for (int dept = 0; dept < _departments.length; dept++) {
        total += laborCostData[dept][i];
      }
      totalLaborCost.add(total);
    }

    double maxTotalCost = totalLaborCost.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Labor Cost by Department vs Occupancy', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text('\$${value.toInt()}', style: const TextStyle(fontSize: 10)),
                        reservedSize: 50,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.orange)),
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
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                  minY: 0,
                  maxY: maxTotalCost * 1.1,
                  barGroups: List.generate(_selectedRange, (i) {
                    double runningTotal = 0;
                    List<BarChartRodStackItem> stacks = [];
                    for (int d = 0; d < _departments.length; d++) {
                      double from = runningTotal;
                      runningTotal += laborCostData[d][i];
                      stacks.add(BarChartRodStackItem(from, runningTotal, _deptColors[d]));
                    }
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: runningTotal,
                          rodStackItems: stacks,
                          width: 20,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey[200]!,
                      tooltipRoundedRadius: 8,
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        int x = group.x.toInt();
                        double total = laborCostData[0][x] + laborCostData[1][x] + laborCostData[2][x] + laborCostData[3][x];
                        return BarTooltipItem(
                          'Overall: \$${total.toStringAsFixed(0)}\n',
                          const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '\$${laborCostData[0][x].toStringAsFixed(0)}\n',
                              style: TextStyle(color: _deptColors[0]),
                            ),
                            TextSpan(
                              text: '\$${laborCostData[1][x].toStringAsFixed(0)}\n',
                              style: TextStyle(color: _deptColors[1]),
                            ),
                            TextSpan(
                              text: '\$${laborCostData[2][x].toStringAsFixed(0)}\n',
                              style: TextStyle(color: _deptColors[2]),
                            ),
                            TextSpan(
                              text: '\$${laborCostData[3][x].toStringAsFixed(0)}\n',
                              style: TextStyle(color: _deptColors[3]),
                            ),
                            TextSpan(
                              text: 'Occupancy: ${occupancyData[x].toStringAsFixed(1)}%',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ],
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
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 16, height: 4, color: Colors.orange),
                const SizedBox(width: 4),
                const Text('Occupancy Rate (shown in tooltip)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastVarianceWaterfallChart(List<double> varianceData, List<String> dateLabels) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Forecast vs Actual Labor Hours Variance', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text('${value.toInt()}h', style: const TextStyle(fontSize: 10)),
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
                  minY: -25,
                  maxY: 25,
                  barGroups: List.generate(_selectedRange, (i) {
                    double variance = varianceData[i];
                    Color barColor = variance > 0 ? Colors.red : Colors.green;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: variance,
                          color: barColor,
                          width: 20,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        double variance = varianceData[group.x.toInt()];
                        String status = variance > 0 ? 'Overstaffed' : 'Understaffed';
                        return BarTooltipItem(
                          '${dateLabels[group.x.toInt()]}\n${variance.toStringAsFixed(1)} hours\n$status',
                          TextStyle(color: variance > 0 ? Colors.red : Colors.green),
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
                Container(width: 16, height: 4, color: Colors.green),
                const SizedBox(width: 4),
                const Text('Understaffed (Good)'),
                const SizedBox(width: 16),
                Container(width: 16, height: 4, color: Colors.red),
                const SizedBox(width: 4),
                const Text('Overstaffed (Costly)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOvertimeGaugeChart(double overtimePercentage) {
    // Generate overtime hours data for the chart
    List<double> overtimeHoursData = _generateOvertimeHoursData();
    List<String> dateLabels = _dateLabels;
    
    // Calculate overtime percentage from chart data
    double calculatedOvertimePercentage = _calculateOvertimePercentage(overtimeHoursData);
    
    Color gaugeColor;
    String status;
    if (calculatedOvertimePercentage < 8) {
      gaugeColor = Colors.green;
      status = 'Good';
    } else if (calculatedOvertimePercentage < 12) {
      gaugeColor = Colors.orange;
      status = 'Warning';
    } else {
      gaugeColor = Colors.red;
      status = 'Critical';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overtime Hours Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                // Left side: Overtime Hours Chart (70%)
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      const Text('Daily Overtime Hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) => Text('${value.toInt()}h', style: const TextStyle(fontSize: 10)),
                                  reservedSize: 35,
                                  interval: 10,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, _) {
                                    int idx = value.toInt();
                                    if (idx >= 0 && idx < dateLabels.length) {
                                      return Text(dateLabels[idx], style: const TextStyle(fontSize: 9));
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                            minY: 0,
                            maxY: overtimeHoursData.reduce((a, b) => a > b ? a : b) + 5,
                            barGroups: List.generate(_selectedRange, (i) {
                              double hours = overtimeHoursData[i];
                              Color barColor = hours < 20 ? Colors.green : (hours < 30 ? Colors.orange : Colors.red);
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: hours,
                                    color: barColor,
                                    width: 15,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.grey[300]!,
                                tooltipRoundedRadius: 8,
                                tooltipMargin: 8,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  double hours = overtimeHoursData[group.x.toInt()];
                                  return BarTooltipItem(
                                    '${dateLabels[group.x.toInt()]}\n${hours.toStringAsFixed(1)} hours',
                                    const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side: Gauge Chart (30%)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      const Text('Current Percentage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: calculatedOvertimePercentage / 20,
                                strokeWidth: 10,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${calculatedOvertimePercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: gaugeColor,
                                  ),
                                ),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: gaugeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              const Text('Good <8%', style: TextStyle(fontSize: 9)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              const Text('Warning 8-12%', style: TextStyle(fontSize: 9)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              const Text('Critical >12%', style: TextStyle(fontSize: 9)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<double> _generateOvertimeHoursData() {
    final rand = Random(_selectedRange + 500);
    return List.generate(_selectedRange, (i) {
      double baseHours = 15 + (i * 0.5);
      bool isWeekend = (DateTime.now().weekday - _selectedRange + i) % 7 >= 5;
      baseHours += isWeekend ? 10 : 0;
      return baseHours + rand.nextDouble() * 15;
    });
  }

  double _calculateOvertimePercentage(List<double> overtimeHours) {
    // Assumptions for calculation:
    // - Standard work week: 40 hours per employee
    // - Average 50 employees working
    // - Overtime is hours worked beyond 40 hours per week
    
    double totalOvertimeHours = overtimeHours.reduce((a, b) => a + b);
    double totalStandardHours = 40 * 50 * (_selectedRange / 7); // 40 hours × 50 employees × weeks
    double totalWorkedHours = totalStandardHours + totalOvertimeHours;
    
    // Overtime percentage = (Overtime hours / Total worked hours) × 100
    double overtimePercentage = (totalOvertimeHours / totalWorkedHours) * 100;
    
    return overtimePercentage;
  }
}

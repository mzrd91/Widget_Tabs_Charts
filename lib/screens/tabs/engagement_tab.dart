import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/charts/heat_map2.dart' show CustomHeatMapWidget;

class EngagementTab extends StatefulWidget {
  const EngagementTab({Key? key}) : super(key: key);

  @override
  State<EngagementTab> createState() => _EngagementTabState();
}

class _EngagementTabState extends State<EngagementTab> {
  final List<int> _dateRanges = [4, 8, 12, 16];
  int _selectedRange = 8;

  final List<String> _departments = ['Housekeeping', 'Front Desk', 'F&B', 'Maintenance'];
  final List<Color> _deptColors = [Colors.blue, Colors.red, Colors.green, Colors.purple];

  List<String> get _dateLabels {
    final now = DateTime.now();
    return List.generate(_selectedRange, (i) {
      final date = now.subtract(Duration(days: (_selectedRange - 1 - i) * 7));
      return DateFormat('MM/dd').format(date);
    });
  }

  // Engagement Score Data (1.0 - 5.0 scale)
  List<List<double>> get _engagementScoreData {
    final rand = Random(_selectedRange);
    return List.generate(_departments.length, (deptIdx) {
      return List.generate(_selectedRange, (i) {
        double baseScore = 3.5 + (deptIdx * 0.3);
        bool isRecent = i >= _selectedRange - 2;
        baseScore += isRecent ? 0.2 : 0;
        return (baseScore + rand.nextDouble() * 0.6).clamp(1.0, 5.0);
      });
    });
  }

  // Burnout Risk Index Data (0.0 - 1.0 scale)
  List<double> get _burnoutRiskData {
    final rand = Random(_selectedRange + 100);
    return List.generate(_departments.length, (i) {
      double baseRisk = 0.3 + (i * 0.1);
      return (baseRisk + rand.nextDouble() * 0.4).clamp(0.0, 1.0);
    });
  }

  // Turnover Rate Data (monthly percentages)
  List<double> get _turnoverRateData {
    final rand = Random(_selectedRange + 200);
    return List.generate(_selectedRange, (i) {
      double baseRate = 4.5 + (i * 0.2);
      return baseRate + rand.nextDouble() * 2.0;
    });
  }

  // Industry benchmark (constant line)
  double get _industryBenchmark => 6.2;

  // Engagement Drivers Data (for radar chart)
  List<List<double>> get _engagementDriversData {
    final rand = Random(_selectedRange + 300);
    return List.generate(_departments.length, (deptIdx) {
      return List.generate(5, (driverIdx) {
        double baseScore = 3.0 + (deptIdx * 0.2) + (driverIdx * 0.1);
        return (baseScore + rand.nextDouble() * 0.8).clamp(1.0, 5.0);
      });
    });
  }

  // Break Time Compliance Data (minutes)
  List<double> get _breakTimeData {
    final rand = Random(_selectedRange + 400);
    return List.generate(_departments.length, (i) {
      double baseTime = 25 + (i * 2);
      return baseTime + rand.nextDouble() * 10;
    });
  }

  final List<String> _engagementDrivers = [
    'Recognition',
    'Autonomy',
    'Manager Support',
    'Teamwork',
    'Growth Opportunities'
  ];

  @override
  Widget build(BuildContext context) {
    final engagementData = _engagementScoreData;
    final burnoutData = _burnoutRiskData;
    final turnoverData = _turnoverRateData;
    final driversData = _engagementDriversData;
    final breakTimeData = _breakTimeData;
    final dateLabels = _dateLabels;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Employee Wellness & Engagement',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              DropdownButton<int>(
                value: _selectedRange,
                items: _dateRanges.map((weeks) {
                  return DropdownMenuItem<int>(
                    value: weeks,
                    child: Text('Last $weeks weeks'),
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
          _buildEngagementScoreChart(engagementData, dateLabels),
          const SizedBox(height: 24),
          _buildBurnoutRiskIndex(burnoutData),
          const SizedBox(height: 24),
          _buildTurnoverRateChart(turnoverData, dateLabels),
          const SizedBox(height: 24),
          _buildEngagementDriversRadarChart(driversData),
          const SizedBox(height: 24),
          _buildBreakTimeComplianceChart(breakTimeData),
        ],
      ),
    );
  }

  Widget _buildEngagementScoreChart(List<List<double>> engagementData, List<String> dateLabels) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Employee Engagement Score', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
                        reservedSize: 40,
                        interval: 1,
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
                  minY: 1.0,
                  maxY: 5.0,
                  lineBarsData: List.generate(_departments.length, (deptIdx) {
                    return LineChartBarData(
                      spots: List.generate(_selectedRange, (i) {
                        return FlSpot(i.toDouble(), engagementData[deptIdx][i]);
                      }),
                      isCurved: true,
                      color: _deptColors[deptIdx],
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _deptColors[deptIdx].withOpacity(0.1),
                      ),
                    );
                  }),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.grey[300]!,
                      tooltipRoundedRadius: 8,
                      tooltipMargin: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          int deptIdx = touchedSpot.barIndex;
                          int weekIdx = touchedSpot.x.toInt();
                          return LineTooltipItem(
                            '${engagementData[deptIdx][weekIdx].toStringAsFixed(2)}',
                            TextStyle(color: _deptColors[deptIdx], fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildBurnoutRiskIndex(List<double> burnoutData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Burnout Risk Index', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_departments.length, (index) {
                double risk = burnoutData[index];
                Color tileColor;
                String status;
                String riskLevel;

                if (risk < 0.3) {
                  tileColor = Colors.green;
                  status = 'Low Risk';
                  riskLevel = 'Good';
                } else if (risk < 0.6) {
                  tileColor = Colors.orange;
                  status = 'Moderate Risk';
                  riskLevel = 'Warning';
                } else {
                  tileColor = Colors.red;
                  status = 'High Risk';
                  riskLevel = 'Critical';
                }

                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: tileColor.withOpacity(0.1),
                      border: Border.all(color: tileColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () => _showBurnoutDetails(index, risk),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _departments[index],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(risk * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: tileColor,
                              ),
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                color: tileColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnoverRateChart(List<double> turnoverData, List<String> dateLabels) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Annualized Turnover Rate vs Industry Benchmark', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
                        reservedSize: 40,
                        interval: 2,
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
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    // Your turnover data (area chart)
                    LineChartBarData(
                      spots: List.generate(_selectedRange, (i) {
                        return FlSpot(i.toDouble(), turnoverData[i]);
                      }),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    // Industry benchmark line
                    LineChartBarData(
                      spots: List.generate(_selectedRange, (i) {
                        return FlSpot(i.toDouble(), _industryBenchmark);
                      }),
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.grey[300]!,
                      tooltipRoundedRadius: 8,
                      tooltipMargin: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          if (touchedSpot.barIndex == 0) {
                            int weekIdx = touchedSpot.x.toInt();
                            return LineTooltipItem(
                              'Your Rate\n${turnoverData[weekIdx].toStringAsFixed(1)}%',
                              const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            );
                          } else {
                            return LineTooltipItem(
                              'Industry Avg\n${_industryBenchmark.toStringAsFixed(1)}%',
                              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            );
                          }
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
                const Text('Your Turnover Rate'),
                const SizedBox(width: 16),
                Container(width: 16, height: 4, color: Colors.red),
                const SizedBox(width: 4),
                const Text('Industry Benchmark'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementDriversRadarChart(List<List<double>> driversData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Engagement Drivers Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                // Left side: Heat Map
                Expanded(
                  child: Column(
                    children: [
                      const Text('Heat Map View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: CustomHeatMapWidget(
                          data: driversData,
                          dateLabels: _departments,
                          title: 'Engagement Drivers',
                          xAxisLabel: 'Driver',
                          yAxisLabel: 'Department',
                          height: 300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side: Radar Chart
                Expanded(
                  child: Column(
                    children: [
                      const Text('Radar Chart View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: RotatableRadarChart(
                          data: driversData,
                          drivers: _engagementDrivers,
                          deptColors: _deptColors,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    );
  }

  Widget _buildBreakTimeComplianceChart(List<double> breakTimeData) {
    double policyThreshold = 30.0; // 30 minutes minimum break time

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Average Break Time Compliance', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        getTitlesWidget: (value, _) => Text('${value.toInt()}m', style: const TextStyle(fontSize: 10)),
                        reservedSize: 40,
                        interval: 10,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < _departments.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _departments[idx],
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
                  minY: 0,
                  maxY: 50,
                  barGroups: List.generate(_departments.length, (i) {
                    double breakTime = breakTimeData[i];
                    Color barColor = breakTime >= policyThreshold ? Colors.green : Colors.red;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: breakTime,
                          color: barColor,
                          width: 30,
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
                        double breakTime = breakTimeData[group.x.toInt()];
                        String status = breakTime >= policyThreshold ? 'Compliant' : 'Below Policy';
                        return BarTooltipItem(
                          '${_departments[group.x.toInt()]}\n${breakTime.toStringAsFixed(1)} minutes\n$status',
                          TextStyle(color: breakTime >= policyThreshold ? Colors.green : Colors.red),
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
                const Text('Compliant (≥30min)'),
                const SizedBox(width: 16),
                Container(width: 16, height: 4, color: Colors.red),
                const SizedBox(width: 4),
                const Text('Below Policy (<30min)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBurnoutDetails(int deptIndex, double risk) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[300],
        title: Text('${_departments[deptIndex]} Burnout Risk Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall Risk: ${(risk * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 16),
            const Text('Risk Factors:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildRiskFactor('Long Shifts (>9hrs)', 0.3, risk * 0.3),
            _buildRiskFactor('Missed Breaks', 0.25, risk * 0.25),
            _buildRiskFactor('Late Clock-outs', 0.25, risk * 0.25),
            _buildRiskFactor('Fatigue Survey', 0.2, risk * 0.2),
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

  Widget _buildRiskFactor(String factor, double weight, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(factor)),
          Expanded(
            flex: 1,
            child: Text('${(value * 100).toStringAsFixed(0)}%'),
          ),
        ],
      ),
    );
  }
}

class RotatableRadarChart extends StatefulWidget {
  final List<List<double>> data;
  final List<String> drivers;
  final List<Color> deptColors;

  const RotatableRadarChart({
    Key? key,
    required this.data,
    required this.drivers,
    required this.deptColors,
  }) : super(key: key);

  @override
  State<RotatableRadarChart> createState() => _RotatableRadarChartState();
}

class _RotatableRadarChartState extends State<RotatableRadarChart> 
    with SingleTickerProviderStateMixin {
  double _rotationAngle = 0.0;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    double deltaX = details.delta.dx;
    double rotationSpeed = 0.02; // Increased sensitivity
    
    setState(() {
      _rotationAngle += deltaX * rotationSpeed;
      // Keep angle between 0 and 2π
      _rotationAngle = _rotationAngle % (2 * 3.14159);
    });
  }

  void _resetRotation() {
    setState(() {
      _rotationAngle = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rotation controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Drag to rotate', style: TextStyle(fontSize: 10, color: Colors.grey)),
            TextButton(
              onPressed: _resetRotation,
              child: const Text('Reset', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Rotatable radar chart
        Expanded(
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: Transform.rotate(
              angle: _rotationAngle,
              child: RadarChart(
                RadarChartData(
                  dataSets: List.generate(widget.data.length, (deptIdx) {
                    return RadarDataSet(
                      dataEntries: List.generate(5, (driverIdx) {
                        return RadarEntry(value: widget.data[deptIdx][driverIdx]);
                      }),
                      fillColor: widget.deptColors[deptIdx].withOpacity(0.3),
                      borderColor: widget.deptColors[deptIdx],
                      entryRadius: 3,
                      borderWidth: 2,
                    );
                  }),
                  titleTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  titlePositionPercentageOffset: 0.2,
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(fontSize: 8),
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: widget.drivers[index],
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
          ),
        ),
      ],
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/staff_member.dart';

class StaffWorkedHours extends StatelessWidget {
  final List<StaffMember> staff;

  const StaffWorkedHours({
    Key? key,
    required this.staff,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxHours(),
        barTouchData: BarTouchData(
          enabled: true,
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
                if (value.toInt() >= 0 && value.toInt() < staff.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Transform.rotate(
                      angle: -0.5, // Slight rotation for better readability
                      child: Text(
                        staff[value.toInt()].name.split(' ').first,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        barGroups: _createBarGroups(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  double _getMaxHours() {
    if (staff.isEmpty) return 50;
    double maxHours = staff.map((s) => s.weeklyHours).reduce((a, b) => a > b ? a : b);
    // Round up to nearest 5 and add some padding
    return ((maxHours / 5).ceil() * 5) + 5;
  }

  List<BarChartGroupData> _createBarGroups() {
    return staff.asMap().entries.map((entry) {
      final index = entry.key;
      final member = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: member.weeklyHours,
            color: _getHoursColor(member.weeklyHours),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getHoursColor(double hours) {
    if (hours >= 40) return Colors.green[600]!;
    if (hours >= 35) return Colors.orange[600]!;
    return Colors.red[600]!;
  }
} 
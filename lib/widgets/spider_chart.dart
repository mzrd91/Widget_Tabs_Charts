import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/staff_member.dart';

class SpiderChart extends StatelessWidget {
  final List<StaffMember> staff;
  final Set<int> selectedStaffIds;

  const SpiderChart({
    Key? key,
    required this.staff,
    required this.selectedStaffIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedStaffIds.isEmpty) {
      return _buildEmptyState();
    }

    final selectedStaff = staff.where((s) => selectedStaffIds.contains(s.id)).toList();

    return Column(
      children: [
        _buildLegend(selectedStaff),
        const SizedBox(height: 16),
        Expanded(
          child: RadarChart(
            RadarChartData(
              radarTouchData: RadarTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, response) {
                  // Handle touch events if needed
                },
              ),
              dataSets: _buildDataSets(selectedStaff),
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(color: Colors.transparent),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                const titles = ['Customer\nSatisfaction', 'Evaluation\nRate', 'Weekly\nHours'];
                return RadarChartTitle(
                  text: titles[index],
                  angle: angle,
                );
              },
              tickCount: 5,
              ticksTextStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
              tickBorderData: const BorderSide(color: Colors.grey, width: 1),
              gridBorderData: const BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.radar,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Select staff members from the table\nto compare their performance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click on table rows to select staff',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<StaffMember> selectedStaff) {
    final colors = _getColors();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: selectedStaff.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          final color = colors[index % colors.length];
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                member.firstName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<RadarDataSet> _buildDataSets(List<StaffMember> selectedStaff) {
    final colors = _getColors();
    
    return selectedStaff.asMap().entries.map((entry) {
      final index = entry.key;
      final member = entry.value;
      final color = colors[index % colors.length];
      
      return RadarDataSet(
        fillColor: color.withOpacity(0.1),
        borderColor: color,
        borderWidth: 2,
        entryRadius: 3,
        dataEntries: [
          RadarEntry(value: member.customerSatisfactionRate),
          RadarEntry(value: member.evaluationRate),
          RadarEntry(value: member.weeklyHours / 5), // Normalize hours to 0-10 scale
        ],
      );
    }).toList();
  }

  List<Color> _getColors() {
    return [
      Colors.blue[600]!,
      Colors.red[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.indigo[600]!,
    ];
  }
}
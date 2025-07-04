import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/staff_member.dart';

class HeatMapChart extends StatelessWidget {
  final List<StaffMember> staff;

  const HeatMapChart({Key? key, required this.staff}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLegend(),
          const SizedBox(height: 16),
          _buildHeatMapGrid(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Low', Colors.blue[300]!),
        const SizedBox(width: 16),
        _buildLegendItem('Medium', Colors.orange[400]!),
        const SizedBox(width: 16),
        _buildLegendItem('High', Colors.red[600]!),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildHeatMapGrid() {
    const List<String> metrics = [
      'Customer Satisfaction',
      'Evaluation Rate',
      'Weekly Hours'
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Staff Name', isFirst: true),
                ...metrics.map((metric) => _buildHeaderCell(metric)),
              ],
            ),
          ),
          // Data rows
          ...staff.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final isLast = index == staff.length - 1;
            
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildNameCell(member.firstName),
                  _buildDataCell(
                    member.customerSatisfactionRate,
                    member.customerSatisfactionRate.toStringAsFixed(1),
                    10.0,
                  ),
                  _buildDataCell(
                    member.evaluationRate,
                    member.evaluationRate.toStringAsFixed(1),
                    10.0,
                  ),
                  _buildDataCell(
                    member.weeklyHours,
                    '${member.weeklyHours.toInt()}h',
                    50.0,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {bool isFirst = false}) {
    return Container(
      width: 120,
      height: 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          left: isFirst ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNameCell(String name) {
    return Container(
      width: 120,
      height: 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(double value, String displayText, double maxValue) {
    return Container(
      width: 120,
      height: 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getHeatColor(value, maxValue),
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _getHeatColor(double value, double maxValue) {
    final intensity = value / maxValue;
    
    if (intensity >= 0.8) {
      return Colors.red[600]!;
    } else if (intensity >= 0.6) {
      return Colors.orange[500]!;
    } else if (intensity >= 0.4) {
      return Colors.yellow[600]!;
    } else if (intensity >= 0.2) {
      return Colors.green[400]!;
    } else {
      return Colors.blue[300]!;
    }
  }
}
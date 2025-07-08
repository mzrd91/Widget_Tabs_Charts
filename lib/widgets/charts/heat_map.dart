import 'package:flutter/material.dart';

class HeatMapWidget extends StatelessWidget {
  final List<List<double>> data;
  final List<String> rowTitles;
  final List<String> colTitles;
  final String? title;

  const HeatMapWidget({
    Key? key,
    required this.data,
    required this.rowTitles,
    required this.colTitles,
    this.title = "Department/Engagement",
  }) : super(key: key);

  Widget _buildHeaderCell(String text, {bool isFirst = false}) {
    return Expanded(
      child: Container(
        height: 30,
        padding: const EdgeInsets.all(4),
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
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildNameCell(String name) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
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
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(double value, String displayText, double maxValue) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
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
              color: Colors.black,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Color _getHeatColor(double value, double maxValue) {
    if (value < 3.0) {
      return Colors.red[600]!;
    } else if (value >= 3.0 && value < 4.2) {
      return Colors.yellow[600]!;
    } else {
      return Colors.green[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildHeaderCell(title ?? "", isFirst: true),
                ...colTitles.map((driver) => _buildHeaderCell(driver)),
              ],
            ),
          ),
          // Data rows
          ...rowTitles.asMap().entries.map((entry) {
            final deptIdx = entry.key;
            final deptName = entry.value;
            final isLast = deptIdx == rowTitles.length - 1;

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
                  _buildNameCell(deptName),
                  ...List.generate(colTitles.length, (driverIdx) {
                    final value = data[deptIdx][driverIdx];
                    return _buildDataCell(value, value.toStringAsFixed(1), 5.0);
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

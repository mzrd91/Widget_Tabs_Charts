import 'package:flutter/material.dart';

class InspectionPassRateWidget extends StatefulWidget {
  final double passRate;
  final double targetRate;
  final String title;

  const InspectionPassRateWidget({
    Key? key,
    required this.passRate,
    this.targetRate = 95.0,
    this.title = 'Inspection Pass Rate',
  }) : super(key: key);

  @override
  State<InspectionPassRateWidget> createState() => _InspectionPassRateWidgetState();
}

class _InspectionPassRateWidgetState extends State<InspectionPassRateWidget> {
  @override
  Widget build(BuildContext context) {
    bool isAlert = widget.passRate < widget.targetRate;
    
    return Card(
      color: isAlert ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isAlert ? Colors.red[700] : Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.passRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isAlert ? Colors.red[700] : Colors.green[700],
                        ),
                      ),
                      Text(
                        isAlert ? 'Below target (${widget.targetRate}%)' : 'Above target',
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
          ],
        ),
      ),
    );
  }
} 
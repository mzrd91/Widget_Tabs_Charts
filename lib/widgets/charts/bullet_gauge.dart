import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class BulletGaugeWidget extends StatelessWidget {
  final double value;
  final String title;
  final double minValue;
  final double maxValue;
  final double thickness;
  final Color? trackColor;
  final Color? valueColor;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final EdgeInsets padding;

  const BulletGaugeWidget({
    Key? key,
    required this.value,
    required this.title,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.thickness = 16.0,
    this.trackColor,
    this.valueColor,
    this.titleStyle,
    this.valueStyle,
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key);

  Color _getThresholdColor(double value) {
    if (value > 95) return Colors.green[600]!;
    if (value >= 90) return Colors.amber[700]!;
    return Colors.red[600]!;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: titleStyle ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SfLinearGauge(
              minimum: minValue,
              maximum: maxValue,
              showTicks: false,
              showLabels: false,
              axisTrackStyle: LinearAxisTrackStyle(
                thickness: thickness,
                edgeStyle: LinearEdgeStyle.bothCurve,
                color: trackColor ?? const Color(0xFFE0E0E0),
              ),
              barPointers: [
                LinearBarPointer(
                  value: value,
                  thickness: thickness,
                  color: valueColor ?? _getThresholdColor(value),
                  edgeStyle: LinearEdgeStyle.bothCurve,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: valueStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
} 
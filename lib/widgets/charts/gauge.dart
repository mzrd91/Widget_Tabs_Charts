import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeWidget extends StatefulWidget {
  final double value;
  final String title;
  final double minValue;
  final double maxValue;
  final double startAngle;
  final double endAngle;
  final List<GaugeRange>? ranges;
  final Color? needleColor;
  final Color? knobColor;
  final double height;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  const GaugeWidget({
    Key? key,
    required this.value,
    required this.title,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.startAngle = 180,
    this.endAngle = 0,
    this.ranges,
    this.needleColor,
    this.knobColor,
    this.height = 300,
    this.titleStyle,
    this.valueStyle,
  }) : super(key: key);

  @override
  State<GaugeWidget> createState() => _GaugeWidgetState();
}

class _GaugeWidgetState extends State<GaugeWidget> {
  Color _getThresholdColor(double value) {
    if (value > 95) return Colors.green[600]!;
    if (value >= 90) return Colors.amber[700]!;
    return Colors.red[600]!;
  }

  List<GaugeRange> _getDefaultRanges() {
    return [
      GaugeRange(
        startValue: 0,
        endValue: 90,
        color: Colors.red,
        startWidth: 15.0,
        endWidth: 15.0,
        rangeOffset: 0,
      ),
      GaugeRange(
        startValue: 90,
        endValue: 95,
        color: Colors.amber,
        startWidth: 15,
        endWidth: 15,
        rangeOffset: 0,
      ),
      GaugeRange(
        startValue: 95,
        endValue: 100,
        color: Colors.green,
        startWidth: 15,
        endWidth: 15,
        rangeOffset: 0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.title,
              style: widget.titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: widget.height,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: widget.minValue,
                    maximum: widget.maxValue,
                    startAngle: widget.startAngle,
                    endAngle: widget.endAngle,
                    showTicks: true,
                    showLabels: true,
                    axisLineStyle: const AxisLineStyle(
                      thickness: 0.1,
                      thicknessUnit: GaugeSizeUnit.factor,
                      color: Colors.transparent,
                    ),
                    ranges: widget.ranges ?? _getDefaultRanges(),
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: widget.value,
                        needleColor: widget.needleColor ?? Colors.black87,
                        knobStyle: KnobStyle(
                          color: widget.knobColor ?? Colors.black87,
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.7,
                        widget: Text(
                          '${widget.value.toStringAsFixed(1)}%',
                          style: widget.valueStyle ?? const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DonutGaugeWidget extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final double startAngle;
  final double endAngle;
  final double thickness;
  final Color? trackColor;
  final Color? valueColor;
  final double height;
  final EdgeInsets padding;

  final Widget Function(double value)? centerLabelBuilder;
  final Widget? title;
  final TextStyle? valueStyle;
  final TextStyle? titleStyle;

  const DonutGaugeWidget({
    Key? key,
    required this.value,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.startAngle = 270,
    this.endAngle = 270,
    this.thickness = 0.2,
    this.trackColor,
    this.valueColor,
    this.height = 200,
    this.padding = const EdgeInsets.all(20),
    this.centerLabelBuilder,
    this.title,
    this.valueStyle,
    this.titleStyle,
  }) : super(key: key);

  Color _getDefaultColor(double value) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) title!,
            if (title != null) const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: minValue,
                    maximum: maxValue,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    showTicks: false,
                    showLabels: false,
                    axisLineStyle: AxisLineStyle(
                      thickness: thickness,
                      thicknessUnit: GaugeSizeUnit.factor,
                      color: trackColor ?? const Color(0xFFE0E0E0),
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: value,
                        width: thickness,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: valueColor ?? _getDefaultColor(value),
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.0,
                        widget: centerLabelBuilder != null
                            ? centerLabelBuilder!(value)
                            : Text(
                                '${value.toStringAsFixed(1)}%',
                                style: valueStyle ??
                                    const TextStyle(
                                        fontSize: 24, fontWeight: FontWeight.bold),
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

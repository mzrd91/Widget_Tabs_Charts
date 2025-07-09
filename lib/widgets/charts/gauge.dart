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
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Future: Initialize data loading
    // _loadChartData();
  }

  // Future method for backend integration
  Future<void> _loadChartData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Future: Replace with actual API calls
      // final data = await ApiService.getGaugeData();

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load chart data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: widget.titleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Error message
            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => errorMessage = null),
                      icon: const Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Loading state
            if (isLoading) ...[
              SizedBox(
                height: widget.height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Loading chart data...', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Chart content
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
          ],
        ),
      ),
    );
  }
}

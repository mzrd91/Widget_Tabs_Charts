import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class UtilizationTab extends StatelessWidget {
  const UtilizationTab({Key? key}) : super(key: key);

  Color _getThresholdColor(double value) {
    if (value > 95) return Colors.green[600]!;
    if (value >= 90) return Colors.amber[700]!;
    return Colors.red[600]!;
  }

  @override
  Widget build(BuildContext context) {
    // Example values from screenshots
    final double fteCoverage = 13.0;
    final double scheduleAdherence = 98.0;
    final double taskOccupancy = 94.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Utilization Metrics',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time workforce efficiency and scheduling metrics',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),

          // FTE Coverage (Half Radial Gauge)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'FTE Coverage',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 200,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          startAngle: 180,
                          endAngle: 0,
                          showTicks: true,
                          showLabels: true,
                          axisLineStyle: const AxisLineStyle(
                            thickness: 0.1,
                            thicknessUnit: GaugeSizeUnit.factor,
                            color: Colors.transparent,
                          ),
                          ranges: <GaugeRange>[
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
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(
                              value: fteCoverage,
                              needleColor: Colors.black87,
                              knobStyle: const KnobStyle(
                                color: Colors.black87,
                              ),
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 0.7,
                              widget: Text(
                                '${fteCoverage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 20,
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
          ),

          const SizedBox(height: 24),

          // Schedule Adherence (Horizontal Bar)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule Adherence',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SfLinearGauge(
                    minimum: 0.0,
                    maximum: 100.0,
                    showTicks: false,
                    showLabels: false,
                    axisTrackStyle: const LinearAxisTrackStyle(
                      thickness: 16,
                      edgeStyle: LinearEdgeStyle.bothCurve,
                      color: Color(0xFFE0E0E0),
                    ),
                    barPointers: [
                      LinearBarPointer(
                        value: scheduleAdherence,
                        thickness: 16,
                        color: _getThresholdColor(scheduleAdherence),
                        edgeStyle: LinearEdgeStyle.bothCurve,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${scheduleAdherence.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Task Occupancy Rate (Donut/Circular Gauge)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Task Occupancy Rate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 200,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          startAngle: 270,
                          endAngle: 270,
                          showTicks: false,
                          showLabels: false,
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.2,
                            thicknessUnit: GaugeSizeUnit.factor,
                            color: const Color(0xFFE0E0E0),
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: taskOccupancy,
                              width: 0.2,
                              sizeUnit: GaugeSizeUnit.factor,
                              color: _getThresholdColor(taskOccupancy),
                              cornerStyle: CornerStyle.bothCurve,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 0.0,
                              widget: Text(
                                '${taskOccupancy.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 24,
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
          ),
        ],
      ),
    );
  }
} 
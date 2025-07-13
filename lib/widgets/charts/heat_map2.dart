import 'package:flutter/material.dart';

class CustomHeatMapWidget extends StatefulWidget {
  final List<List<double>> data;
  final List<String> dateLabels;
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final Function(int day, int hour, double value, String date)? onCellTap;

  final Color Function(double normalized)? colorScale;
  final Widget Function(double value)? cellContentBuilder;
  final Widget? customLegend;
  final double? height;

  const CustomHeatMapWidget({
    Key? key,
    required this.data,
    required this.dateLabels,
    required this.title,
    this.xAxisLabel = 'Hour',
    this.yAxisLabel = 'Date',
    this.onCellTap,
    this.colorScale,
    this.cellContentBuilder,
    this.customLegend,
    this.height,
  }) : super(key: key);

  @override
  State<CustomHeatMapWidget> createState() => _CustomHeatMapWidgetState();
}

class _CustomHeatMapWidgetState extends State<CustomHeatMapWidget> {
  double get _minValue {
    double minVal = double.infinity;
    for (var day in widget.data) {
      for (var value in day) {
        if (value < minVal) minVal = value;
      }
    }
    return minVal;
  }

  double get _maxValue {
    double maxVal = 0;
    for (var day in widget.data) {
      for (var value in day) {
        if (value > maxVal) maxVal = value;
      }
    }
    return maxVal;
  }

  Color _defaultColorScale(double normalized) {
    if (normalized < 0.33) {
      return Colors.green.withOpacity(0.3 + normalized * 0.7);
    } else if (normalized < 0.66) {
      return Colors.yellow.withOpacity(0.3 + (normalized - 0.33) * 1.5);
    } else {
      return Colors.red.withOpacity(0.3 + (normalized - 0.66) * 1.5);
    }
  }

  void _showDetails(int day, int hour, double value, String date) {
    if (widget.onCellTap != null) {
      widget.onCellTap!(day, hour, value, date);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cell Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.yAxisLabel}: $date'),
              Text('${widget.xAxisLabel}: $hour'),
              Text('Value: ${value.toStringAsFixed(1)}'),
              const SizedBox(height: 16),
              const Text('Sample Info (customize this):'),
              Text('• Example A - ${(value * 0.8).toStringAsFixed(1)}'),
              Text('• Example B - ${(value * 1.2).toStringAsFixed(1)}'),
              Text('• Example C - ${(value * 1.5).toStringAsFixed(1)}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int columnCount = widget.data.isNotEmpty ? widget.data[0].length : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: widget.height ?? 500,
              child: Column(
                children: [
                  Container(
                    height: 30,
                    child: Row(
                      children: [
                        const SizedBox(width: 80),
                        ...List.generate(columnCount, (i) => Expanded(
                              child: Text(
                                '$i',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(widget.dateLabels.length, (dayIndex) {
                          return Container(
                            height: 35,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Text(
                                      widget.dateLabels[dayIndex],
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: List.generate(columnCount, (hourIndex) {
                                      final value = widget.data[dayIndex][hourIndex];
                                      final normalized = (_maxValue - _minValue) > 0
                                          ? (value - _minValue) / (_maxValue - _minValue)
                                          : 0.0;
                                      final cellColor = widget.colorScale?.call(normalized) ??
                                          _defaultColorScale(normalized);

                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () => _showDetails(dayIndex, hourIndex, value, widget.dateLabels[dayIndex]),
                                          child: Container(
                                            height: 35,
                                            margin: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: cellColor,
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: Colors.grey[300]!, width: 0.5),
                                            ),
                                            child: Center(
                                              child: widget.cellContentBuilder?.call(value) ??
                                                  Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      color: normalized > 0.6 ? Colors.white : Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            widget.customLegend ??
                Row(
                  children: [
                    Text('${widget.title.split(' ').first} Scale: '),
                    Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))),
                    const Text(' Low '),
                    Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(2))),
                    const Text(' Medium '),
                    Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))),
                    const Text(' High'),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
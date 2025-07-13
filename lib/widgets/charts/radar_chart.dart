import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RadarChartCustomWidget extends StatefulWidget {
  final List<List<double>> data;
  final List<String> labels;
  final List<String> legendLabels;
  final List<Color> colors;
  final String title;
  final double maxValue;
  final int tickCount;

  final TextStyle? titleStyle;
  final TextStyle? tickTextStyle;
  final Widget Function(String label, Color color)? legendItemBuilder;

  const RadarChartCustomWidget({
    Key? key,
    required this.data,
    required this.labels,
    required this.legendLabels,
    required this.colors,
    required this.title,
    this.maxValue = 10.0,
    this.tickCount = 5,
    this.titleStyle,
    this.tickTextStyle,
    this.legendItemBuilder,
  }) : super(key: key);

  @override
  State<RadarChartCustomWidget> createState() => _RadarChartCustomWidgetState();
}

class _RadarChartCustomWidgetState extends State<RadarChartCustomWidget> {
  List<RadarDataSet> _buildDataSets() {
    return List.generate(widget.data.length, (index) {
      return RadarDataSet(
        dataEntries: List.generate(widget.labels.length, (i) {
          return RadarEntry(value: widget.data[index][i]);
        }),
        fillColor: widget.colors[index].withOpacity(0.3),
        borderColor: widget.colors[index],
        entryRadius: 3,
        borderWidth: 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: widget.titleStyle ?? const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 400,
              child: RadarChart(
                RadarChartData(
                  dataSets: _buildDataSets(),
                  titleTextStyle: widget.titleStyle ?? const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  titlePositionPercentageOffset: 0.2,
                  tickCount: widget.tickCount,
                  ticksTextStyle: widget.tickTextStyle ?? const TextStyle(fontSize: 8),
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: widget.labels[index],
                      angle: angle,
                    );
                  },
                  tickBorderData: const BorderSide(color: Colors.grey, width: 1),
                  borderData: FlBorderData(show: false),
                  gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  radarTouchData: RadarTouchData(enabled: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildResponsiveLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveLegend() {
    // Calculate how many items can fit per row based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = widget.legendLabels.length > 6 ? 80.0 : 120.0; // Smaller items when more staff
    final itemsPerRow = (screenWidth / itemWidth).floor().clamp(1, 4); // Max 4 items per row
    
    // Split legend items into rows
    final rows = <List<int>>[];
    for (int i = 0; i < widget.legendLabels.length; i += itemsPerRow) {
      rows.add(List.generate(
        (i + itemsPerRow < widget.legendLabels.length) ? itemsPerRow : widget.legendLabels.length - i,
        (j) => i + j,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show total count when many staff are selected
        if (widget.legendLabels.length > 6)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${widget.legendLabels.length} staff members selected',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ...rows.map((rowIndices) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: rowIndices.map((index) {
                return Expanded(
                  child: widget.legendItemBuilder?.call(widget.legendLabels[index], widget.colors[index]) ??
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 3,
                            decoration: BoxDecoration(
                              color: widget.colors[index],
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              _getDisplayName(widget.legendLabels[index]),
                              style: TextStyle(
                                fontSize: widget.legendLabels.length > 6 ? 9 : 10,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getDisplayName(String fullName) {
    // For many staff members, show abbreviated names
    if (widget.legendLabels.length > 6) {
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}. ${parts[1]}'; // First initial + last name
      }
      return fullName.length > 12 ? '${fullName.substring(0, 10)}...' : fullName;
    }
    return fullName;
  }
}

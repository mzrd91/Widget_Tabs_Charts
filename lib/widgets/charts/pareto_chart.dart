import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ParetoChartCustomWidget extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final List<Color> colors;
  final String title;

  final Widget Function(String label, Color color)? legendItemBuilder;
  final Widget Function(String label)? failureLabelBuilder;
  final String Function(double value)? xAxisTickFormatter;

  const ParetoChartCustomWidget({
    Key? key,
    required this.data,
    required this.labels,
    required this.colors,
    required this.title,
    this.legendItemBuilder,
    this.failureLabelBuilder,
    this.xAxisTickFormatter,
  }) : super(key: key);

  @override
  State<ParetoChartCustomWidget> createState() => _ParetoChartCustomWidgetState();
}

class _ParetoChartCustomWidgetState extends State<ParetoChartCustomWidget> {
  @override
  Widget build(BuildContext context) {
    List<MapEntry<int, double>> sortedData = [];
    for (int i = 0; i < widget.data.length; i++) {
      sortedData.add(MapEntry(i, widget.data[i]));
    }
    sortedData.sort((a, b) => b.value.compareTo(a.value));

    double total = widget.data.reduce((a, b) => a + b);
    List<double> cumulative = [];
    double runningTotal = 0;
    for (var entry in sortedData) {
      runningTotal += entry.value;
      cumulative.add((runningTotal / total) * 100);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: List.generate(sortedData.length, (index) {
                        int originalIndex = sortedData[index].key;
                        double maxValue = widget.data.reduce((a, b) => a > b ? a : b);
                        double barWidth = (sortedData[index].value / maxValue) * 0.8;

                        return Container(
                          height: 25,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: widget.failureLabelBuilder?.call(widget.labels[originalIndex]) ??
                                    Text(
                                      widget.labels[originalIndex].split(' ').take(2).join(' '),
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showParetoDetails(originalIndex, sortedData[index].value, cumulative[index]),
                                  child: Container(
                                    height: 20,
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: barWidth,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: widget.colors[originalIndex],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            sortedData[index].value.toInt().toString(),
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  sortedData[index].value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  Container(
                    height: 30,
                    child: Row(
                      children: [
                        const SizedBox(width: 88),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (i) {
                              double value = (widget.data.reduce((a, b) => a > b ? a : b) / 5) * i;
                              return Text(
                                widget.xAxisTickFormatter?.call(value) ?? value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (cumulative.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(cumulative.length, (i) => FlSpot(i.toDouble(), cumulative[i])),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                widget.legendItemBuilder?.call('Failure Count', Colors.blue) ??
                    Row(
                      children: [
                        Container(width: 16, height: 4, color: Colors.blue),
                        const SizedBox(width: 4),
                        const Text('Failure Count'),
                      ],
                    ),
                const SizedBox(width: 16),
                widget.legendItemBuilder?.call('Cumulative %', Colors.orange) ??
                    Row(
                      children: [
                        Container(width: 16, height: 4, color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text('Cumulative %'),
                      ],
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showParetoDetails(int originalIndex, double value, double cumulativePercent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.labels[originalIndex]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Failure Count: ${value.toInt()}'),
            Text('Cumulative Percentage: ${cumulativePercent.toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text('Impact Analysis:'),
            Text('• This issue represents ${(value / widget.data.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}% of all failures'),
            Text('• Addressing this would reduce failures by ${value.toInt()} instances'),
            if (cumulativePercent <= 80)
              const Text('• This is a "vital few" issue that should be prioritized'),
            if (cumulativePercent > 80)
              const Text('• This is part of the "trivial many" issues'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }
}

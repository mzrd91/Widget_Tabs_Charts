import 'package:flutter/material.dart';

class HeatMapThreshold {
  final int columnIndex;
  final double lowThreshold;
  final double mediumThreshold;
  final double highThreshold;

  const HeatMapThreshold({
    required this.columnIndex,
    required this.lowThreshold,
    required this.mediumThreshold,
    required this.highThreshold,
  });
}

class HeatMapWidget extends StatefulWidget {
  final List<List<double>> data;
  final List<String> rowTitles;
  final List<String> colTitles;
  final String? title;
  final List<HeatMapThreshold>? thresholds;

  const HeatMapWidget({
    Key? key,
    required this.data,
    required this.rowTitles,
    required this.colTitles,
    this.title = "Department/Engagement",
    this.thresholds,
  }) : super(key: key);

  @override
  State<HeatMapWidget> createState() => _HeatMapWidgetState();
}

class _HeatMapWidgetState extends State<HeatMapWidget> {
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
      // final data = await ApiService.getHeatMapData();
      
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

  Widget _buildDataCell(double value, String displayText, double maxValue, int columnIndex) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _getHeatColor(value, maxValue, columnIndex),
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

  Color _getHeatColor(double value, double maxValue, int columnIndex) {
    // If thresholds are provided, use them
    if (widget.thresholds != null) {
      final threshold = widget.thresholds!.firstWhere(
        (t) => t.columnIndex == columnIndex,
        orElse: () => HeatMapThreshold(
          columnIndex: columnIndex,
          lowThreshold: maxValue * 0.3,
          mediumThreshold: maxValue * 0.7,
          highThreshold: maxValue,
        ),
      );
      
      if (value < threshold.lowThreshold) {
        return Colors.red[600]!;
      } else if (value < threshold.mediumThreshold) {
        return Colors.orange[600]!;
      } else if (value < threshold.highThreshold) {
        return Colors.yellow[600]!;
      } else {
        return Colors.green[600]!;
      }
    }
    
    // Default logic (percentage-based)
    double percentage = value / maxValue;
    
    if (percentage < 0.3) {
      return Colors.red[600]!;
    } else if (percentage >= 0.3 && percentage < 0.7) {
      return Colors.yellow[600]!;
    } else {
      return Colors.green[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.title ?? 'Heat Map', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            
            // Loading state
            if (isLoading) ...[
              SizedBox(
                height: 300,
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
              Container(
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
                          _buildHeaderCell(widget.title ?? "", isFirst: true),
                          ...widget.colTitles.map((driver) => _buildHeaderCell(driver)),
                        ],
                      ),
                    ),
                    // Data rows
                    ...widget.rowTitles.asMap().entries.map((entry) {
                      final deptIdx = entry.key;
                      final deptName = entry.value;
                      final isLast = deptIdx == widget.rowTitles.length - 1;

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
                            ...List.generate(widget.colTitles.length, (driverIdx) {
                              final value = widget.data[deptIdx][driverIdx];
                              // Calculate max value across all data
                              double maxValue = widget.data.fold(0.0, (max, row) => 
                                row.fold(max, (rowMax, val) => val > rowMax ? val : rowMax));
                              return _buildDataCell(value, value.toStringAsFixed(1), maxValue, driverIdx);
                            }),
                          ],
                        ),
                      );
                    }),
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

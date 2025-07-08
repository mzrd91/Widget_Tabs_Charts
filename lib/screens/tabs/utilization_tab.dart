import 'package:flutter/material.dart';
import '../../widgets/charts/charts.dart';

class UtilizationTab extends StatefulWidget {
  const UtilizationTab({Key? key}) : super(key: key);

  @override
  State<UtilizationTab> createState() => _UtilizationTabState();
}

class _UtilizationTabState extends State<UtilizationTab> {
  // Data variables - will be loaded from backend in the future
  double fteCoverage = 13.0;
  double scheduleAdherence = 98.0;
  double taskOccupancy = 94.0;
  
  // State management variables for future backend integration
  bool isLoading = false;
  String? errorMessage;
  
  // Filter variables for future features
  String selectedTimeRange = 'Last 30 Days';
  String selectedDepartment = 'All Departments';
  
  final List<String> timeRanges = [
    'Last 7 Days',
    'Last 30 Days', 
    'Last 90 Days',
    'Last 6 Months',
    'Last Year'
  ];
  
  final List<String> departments = [
    'All Departments',
    'Housekeeping',
    'Front Desk',
    'F&B',
    'Maintenance'
  ];

  @override
  void initState() {
    super.initState();
    // Future: Load initial data from backend
    // _loadUtilizationData();
  }

  // Future method for backend integration
  Future<void> _loadUtilizationData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Future: Replace with actual API calls
      // final data = await ApiService.getUtilizationData(
      //   timeRange: selectedTimeRange,
      //   department: selectedDepartment,
      // );
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Future: Update with real data
      // setState(() {
      //   fteCoverage = data.fteCoverage;
      //   scheduleAdherence = data.scheduleAdherence;
      //   taskOccupancy = data.taskOccupancy;
      // });
      
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onTimeRangeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedTimeRange = newValue;
      });
      _loadUtilizationData(); // Reload data with new filter
    }
  }

  void _onDepartmentChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedDepartment = newValue;
      });
      _loadUtilizationData(); // Reload data with new filter
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and description
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

          // Filters section - for future backend integration
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Time Range Filter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Range',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedTimeRange,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: timeRanges.map((range) {
                            return DropdownMenuItem<String>(
                              value: range,
                              child: Text(range),
                            );
                          }).toList(),
                          onChanged: _onTimeRangeChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Department Filter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Department',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedDepartment,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: departments.map((dept) {
                            return DropdownMenuItem<String>(
                              value: dept,
                              child: Text(dept),
                            );
                          }).toList(),
                          onChanged: _onDepartmentChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Refresh Button
                  Column(
                    children: [
                      const SizedBox(height: 24), // Align with dropdowns
                      IconButton(
                        onPressed: isLoading ? null : _loadUtilizationData,
                        icon: isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                        tooltip: 'Refresh Data',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Error message display
          if (errorMessage != null) ...[
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => errorMessage = null),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Charts section
          if (isLoading) ...[
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading utilization data...'),
                ],
              ),
            ),
          ] else ...[
            // FTE Coverage (Half Radial Gauge)
            GaugeWidget(
              value: fteCoverage,
              title: 'FTE Coverage',
            ),

            const SizedBox(height: 24),

            // Schedule Adherence (Horizontal Bar)
            BulletGaugeWidget(
              value: scheduleAdherence,
              title: 'Schedule Adherence',
            ),

            const SizedBox(height: 24),

            // Task Occupancy Rate (Donut/Circular Gauge)
            RateDonutWidget(
              value: taskOccupancy,
              title: 'Task Occupancy Rate',
            ),
          ],
        ],
      ),
    );
  }
} 
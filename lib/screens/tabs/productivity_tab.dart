import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../widgets/charts/charts.dart';

class ProductivityTab extends StatefulWidget {
  const ProductivityTab({Key? key}) : super(key: key);

  @override
  State<ProductivityTab> createState() => _ProductivityTabState();
}

class _ProductivityTabState extends State<ProductivityTab> {
  // Filter variables
  String selectedTimeRange = 'Last 7 days';
  DateTime? startDate;
  DateTime? endDate;
  String selectedDepartment = 'All Departments';
  
  // State management variables
  bool isLoading = false;
  String? errorMessage;
  
  final List<String> timeRanges = [
    'Last 7 days',
    'Last 14 days', 
    'Last 30 days',
    'YTD',
    'Custom Range'
  ];
  
  final List<String> departments = [
    'All Departments',
    'Housekeeping',
    'Front Desk',
    'F&B',
    'Maintenance'
  ];

  final List<String> _departments = ['Housekeeping', 'Front Desk', 'F&B', 'Maintenance'];
  final List<Color> _deptColors = [Colors.blue, Colors.orange, Colors.green, Colors.purple];

  @override
  void initState() {
    super.initState();
    // Set default date range
    _updateDateRange();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (selectedTimeRange) {
      case 'Last 7 days':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'Last 14 days':
        startDate = now.subtract(const Duration(days: 14));
        endDate = now;
        break;
      case 'Last 30 days':
        startDate = now.subtract(const Duration(days: 30));
        endDate = now;
        break;
      case 'YTD':
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
        break;
      case 'Custom Range':
        // Keep existing custom dates
        break;
    }
  }

  List<String> get _dateLabels {
    if (startDate == null || endDate == null) return [];
    
    final days = endDate!.difference(startDate!).inDays + 1;
    return List.generate(days, (i) {
      final date = startDate!.add(Duration(days: i));
      return DateFormat('MM/dd').format(date);
    });
  }

  List<double> get _mporData {
    final rand = Random(selectedTimeRange.hashCode);
    final days = _dateLabels.length;
    
    // If specific department is selected, adjust the data accordingly
    if (selectedDepartment != 'All Departments') {
      // Different departments have different MPOR characteristics
      double baseValue = 18.0;
      double variation = 17.0;
      
      switch (selectedDepartment) {
        case 'Housekeeping':
          baseValue = 25.0; // Housekeeping typically takes longer
          variation = 15.0;
          break;
        case 'Front Desk':
          baseValue = 15.0; // Front desk is faster
          variation = 10.0;
          break;
        case 'F&B':
          baseValue = 20.0; // F&B is moderate
          variation = 12.0;
          break;
        case 'Maintenance':
          baseValue = 30.0; // Maintenance takes longest
          variation = 20.0;
          break;
      }
      
      return List.generate(days, (i) => baseValue + rand.nextDouble() * variation);
    }
    
    // Overall data (all departments combined)
    return List.generate(days, (i) => 18 + rand.nextDouble() * 17);
  }

  List<double> _movingAverage(List<double> data, int window) {
    if (data.isEmpty) return [];
    List<double> avg = [];
    for (int i = 0; i < data.length; i++) {
      int start = (i - window + 1).clamp(0, data.length - 1);
      double sum = 0;
      for (int j = start; j <= i; j++) {
        sum += data[j];
      }
      avg.add(sum / (i - start + 1));
    }
    return avg;
  }

  List<List<double>> get _tasksPerLaborHourData {
    final rand = Random(selectedTimeRange.hashCode + 100);
    final days = _dateLabels.length;
    
    // If specific department is selected, show only that department
    if (selectedDepartment != 'All Departments') {
      // Find the index of the selected department
      int deptIndex = _departments.indexOf(selectedDepartment);
      if (deptIndex == -1) deptIndex = 0; // Fallback to first department
      
      // Return single department data
      return [
        List.generate(days, (i) => 1.5 + rand.nextDouble() * 2.5 + deptIndex)
      ];
    }
    
    // All departments data
    return List.generate(_departments.length, (deptIdx) {
      return List.generate(days, (i) => 1.5 + rand.nextDouble() * 2.5 + deptIdx);
    });
  }

  List<double> get _revenuePerLaborHourData {
    final rand = Random(selectedTimeRange.hashCode + 200);
    final days = _dateLabels.length;
    
    // If specific department is selected, adjust the revenue data
    if (selectedDepartment != 'All Departments') {
      // Different departments have different revenue characteristics
      double baseValue = 30.0;
      double variation = 40.0;
      
      switch (selectedDepartment) {
        case 'Housekeeping':
          baseValue = 25.0; // Housekeeping has lower revenue per hour
          variation = 30.0;
          break;
        case 'Front Desk':
          baseValue = 45.0; // Front desk generates more revenue
          variation = 35.0;
          break;
        case 'F&B':
          baseValue = 60.0; // F&B has highest revenue potential
          variation = 50.0;
          break;
        case 'Maintenance':
          baseValue = 35.0; // Maintenance is moderate
          variation = 25.0;
          break;
      }
      
      return List.generate(days, (i) => baseValue + rand.nextDouble() * variation);
    }
    
    // Overall data (all departments combined)
    return List.generate(days, (i) => 30 + rand.nextDouble() * 40);
  }

  // Future method for backend integration
  Future<void> _loadProductivityData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Future: Replace with actual API calls
      // final data = await ApiService.getProductivityData(
      //   startDate: startDate,
      //   endDate: endDate,
      //   department: selectedDepartment,
      // );
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Future: Update with real data
      // setState(() {
      //   // Update data variables with real backend data
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
        if (newValue != 'Custom Range') {
          _updateDateRange();
        }
      });
      _loadProductivityData();
    }
  }

  void _onDepartmentChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedDepartment = newValue;
      });
      _loadProductivityData();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null 
        ? DateTimeRange(start: startDate!, end: endDate!)
        : DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );
    
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        selectedTimeRange = 'Custom Range';
      });
      _loadProductivityData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mporData = _mporData;
    final dateLabels = _dateLabels;
    final tasksData = _tasksPerLaborHourData;
    final revenueData = _revenuePerLaborHourData;
    final minIndex = revenueData.indexOf(revenueData.reduce(min));
    final maxIndex = revenueData.indexOf(revenueData.reduce(max));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Productivity Metrics',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Workforce efficiency and performance metrics',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Filters section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
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
                      // Date Range Picker Button
                      Column(
                        children: [
                          const SizedBox(height: 24), // Align with dropdowns
                          ElevatedButton.icon(
                            onPressed: _selectDateRange,
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: const Text('Date Range'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Refresh Button
                      Column(
                        children: [
                          const SizedBox(height: 24), // Align with dropdowns
                          IconButton(
                            onPressed: isLoading ? null : _loadProductivityData,
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
                  // Date range display
                  if (startDate != null && endDate != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Date Range: ${DateFormat('MM/dd/yyyy').format(startDate!)} - ${DateFormat('MM/dd/yyyy').format(endDate!)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
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
                  Text('Loading productivity data...'),
                ],
              ),
            ),
          ] else ...[
            // Chart 1: MPOR Line Chart
            LineChartWidget(
              data: [mporData],
              dateLabels: dateLabels,
              legendLabels: ['Daily MPOR', 'Moving Avg'],
              colors: [Colors.blue, Colors.orange],
              title: selectedDepartment == 'All Departments' 
                ? 'Minutes per Occupied Room (MPOR)'
                : 'Minutes per Occupied Room (MPOR) - $selectedDepartment',
              minY: 0,
              maxY: 40,
              showMovingAverage: true,
            ),

            const SizedBox(height: 24),

            // Chart 2: Tasks Completed per Labor Hour
            StackedBarWidget(
              data: tasksData,
              dateLabels: dateLabels,
              legendLabels: selectedDepartment == 'All Departments' 
                ? _departments 
                : [selectedDepartment],
              colors: selectedDepartment == 'All Departments' 
                ? _deptColors 
                : [Colors.blue], // Single color for single department
              title: 'Tasks Completed per Labor Hour',
            ),

            const SizedBox(height: 24),

            // Chart 3: Revenue per Labor Hour
            LineChartWidget(
              data: [revenueData],
              dateLabels: dateLabels,
              legendLabels: ['Revenue per Labor Hour'],
              colors: [Colors.purple],
              title: selectedDepartment == 'All Departments' 
                ? 'Revenue (or GOP) per Labor Hour'
                : 'Revenue (or GOP) per Labor Hour - $selectedDepartment',
              minY: 0,
              maxY: revenueData.reduce(max) + 10,
              showMinMaxIndicators: true,
              minMaxIndices: [minIndex, maxIndex],
              currencySymbol: '\$',
            ),
          ],
        ],
      ),
    );
  }
}
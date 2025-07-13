import 'package:flutter/material.dart';
import '../../models/staff_member.dart';
import '../../widgets/charts/charts.dart';
import '../../widgets/charts/staff_heat_map.dart' show StaffHeatMapWidget;

class StaffAnalysisTab extends StatefulWidget {
  const StaffAnalysisTab({Key? key}) : super(key: key);

  @override
  State<StaffAnalysisTab> createState() => _StaffAnalysisTabState();
}

class _StaffAnalysisTabState extends State<StaffAnalysisTab> {
  final List<StaffMember> _staff = [
    StaffMember(id: 1, name: "Alice Johnson", customerSatisfactionRate: 8.5, evaluationRate: 9.0, weeklyHours: 40),
    StaffMember(id: 2, name: "Bob Smith", customerSatisfactionRate: 7.2, evaluationRate: 8.1, weeklyHours: 38),
    StaffMember(id: 3, name: "Carol Davis", customerSatisfactionRate: 9.1, evaluationRate: 8.8, weeklyHours: 42),
    StaffMember(id: 4, name: "David Wilson", customerSatisfactionRate: 6.8, evaluationRate: 7.5, weeklyHours: 35),
    StaffMember(id: 5, name: "Emma Brown", customerSatisfactionRate: 8.9, evaluationRate: 9.2, weeklyHours: 41),
    StaffMember(id: 6, name: "Frank Miller", customerSatisfactionRate: 7.6, evaluationRate: 8.3, weeklyHours: 39),
    StaffMember(id: 7, name: "Grace Lee", customerSatisfactionRate: 9.3, evaluationRate: 9.1, weeklyHours: 43),
    StaffMember(id: 8, name: "Henry Taylor", customerSatisfactionRate: 6.9, evaluationRate: 7.8, weeklyHours: 36),
    StaffMember(id: 9, name: "Ivy Chen", customerSatisfactionRate: 8.7, evaluationRate: 8.9, weeklyHours: 40),
    StaffMember(id: 10, name: "Jack Robinson", customerSatisfactionRate: 7.4, evaluationRate: 8.0, weeklyHours: 37),
  ];

  final Set<int> _selectedStaffIds = {};
  bool _isTableExpanded = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Tasks data
  final List<TaskData> _tasks = [
    TaskData(
      id: 1,
      name: "Room Cleaning – 305",
      progress: 75,
      assignedTo: "Alice Johnson",
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 2)),
    ),
    TaskData(
      id: 2,
      name: "Linen Replacement – 412",
      progress: 100,
      assignedTo: "Bob Smith",
      status: TaskStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    TaskData(
      id: 3,
      name: "Maintenance Check – 208",
      progress: 45,
      assignedTo: "Carol Davis",
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 4)),
    ),
    TaskData(
      id: 4,
      name: "Guest Service – 501",
      progress: 0,
      assignedTo: "David Wilson",
      status: TaskStatus.pending,
      dueDate: DateTime.now().add(const Duration(hours: 30)),
    ),
    TaskData(
      id: 5,
      name: "Inventory Count – Kitchen",
      progress: 90,
      assignedTo: "Emma Brown",
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 1)),
    ),
    TaskData(
      id: 6,
      name: "Security Check – Floor 3",
      progress: 100,
      assignedTo: "Frank Miller",
      status: TaskStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TaskData(
      id: 7,
      name: "Pool Maintenance",
      progress: 25,
      assignedTo: "Grace Lee",
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 6)),
    ),
    TaskData(
      id: 8,
      name: "Front Desk Training",
      progress: 0,
      assignedTo: "Henry Taylor",
      status: TaskStatus.pending,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    TaskData(
      id: 9,
      name: "Room Inspection – 315",
      progress: 60,
      assignedTo: "Ivy Chen",
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 3)),
    ),
    TaskData(
      id: 10,
      name: "Equipment Calibration",
      progress: 100,
      assignedTo: "Jack Robinson",
      status: TaskStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];
  
  int _currentPage = 1;
  final int _tasksPerPage = 5;

  List<StaffMember> get _filteredStaff {
    if (_searchQuery.isEmpty) {
      return _staff;
    }
    return _staff.where((member) =>
        member.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // Data preparation for charts - Swapped axes
  List<List<double>> get _heatMapData {
    return _staff.map((s) => [
      s.customerSatisfactionRate,
      s.evaluationRate,
      s.weeklyHours.toDouble(),
    ]).toList();
  }

  List<String> get _heatMapDateLabels => _staff.map((s) => s.name.split(' ').first).toList();



  List<List<double>> get _radarChartData {
    if (_selectedStaffIds.isEmpty) return [];
    
    return _selectedStaffIds.map((staffId) {
      final staff = _staff.firstWhere((s) => s.id == staffId);
      return [
        staff.customerSatisfactionRate, // Already 0-10 scale
        staff.evaluationRate, // Already 0-10 scale
        (staff.weeklyHours.toDouble() / 50.0) * 10.0, // Normalize hours to 0-10 scale
      ];
    }).toList();
  }

  List<String> get _radarChartLabels => ['Customer Satisfaction (0-10)', 'Evaluation Rate (0-10)', 'Weekly Hours (0-50h)'];
  List<String> get _radarChartLegendLabels => _selectedStaffIds.map((id) {
    return _staff.firstWhere((s) => s.id == id).name;
  }).toList();
  List<Color> get _radarChartColors => [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  List<double> get _barChartData => _staff.map((s) => s.weeklyHours.toDouble()).toList();
  List<String> get _barChartLabels => _staff.map((s) => s.name.split(' ').first).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStaffTable(),
          const SizedBox(height: 24),
          _buildChartsSection(),
        ],
      ),
    );
  }

  Widget _buildStaffTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with dropdown toggle
            Row(
              children: [
                Icon(Icons.people, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Staff Performance Data',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const Spacer(),
                Text(
                  '(${_filteredStaff.length} staff members)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isTableExpanded = !_isTableExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isTableExpanded ? 'Hide Table' : 'Show Table',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isTableExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search staff members...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Table (only shown when expanded)
            if (_isTableExpanded) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(
                        label: Text('Staff Name', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Customer Satisfaction', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Evaluation Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Weekly Hours', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: _filteredStaff.map((member) {
                      final isSelected = _selectedStaffIds.contains(member.id);
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          if (selected == true) {
                            if (_selectedStaffIds.length >= 8) {
                              _showMaxSelectionError();
                            } else {
                              setState(() {
                                _selectedStaffIds.add(member.id);
                              });
                            }
                          } else {
                            setState(() {
                              _selectedStaffIds.remove(member.id);
                            });
                          }
                        },
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    member.name.substring(0, 1),
                                    style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(member.name),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getScoreColor(member.customerSatisfactionRate),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${member.customerSatisfactionRate.toStringAsFixed(1)}/10',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getScoreColor(member.evaluationRate),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${member.evaluationRate.toStringAsFixed(1)}/10',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getHoursColor(member.weeklyHours),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${member.weeklyHours.toInt()}h',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select rows to compare in the spider chart below',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ] else ...[
              // Show summary when table is collapsed
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Table is collapsed. Click "Show Table" to view all staff members. Use the search bar above to filter staff.',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
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

  Widget _buildChartsSection() {
    return Column(
      children: [
        // First row: Heat Map and Radar Chart
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heat Map
            Expanded(
              child: StaffHeatMapWidget(
                data: _heatMapData,
                dateLabels: _heatMapDateLabels,
                title: 'Staff Performance Overview',
                xAxisLabel: 'Metric',
                yAxisLabel: 'Staff Member',
                onCellTap: (day, hour, value, date) {
                  final staffMember = _staff[day];
                  String metricName = '';
                  switch (hour) {
                    case 0:
                      metricName = 'Customer Satisfaction';
                      break;
                    case 1:
                      metricName = 'Evaluation Rate';
                      break;
                    case 2:
                      metricName = 'Weekly Hours';
                      break;
                  }
                  _showStaffPerformanceDetails(day, hour, value, date, metricName);
                },
              ),
            ),
            const SizedBox(width: 16),
            // Radar Chart
            Expanded(
              child: _selectedStaffIds.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff Comparison',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.radar, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Select staff from table to compare',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '(${_selectedStaffIds.length} selected)',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                                 : RadarChartCustomWidget(
                     data: _radarChartData,
                     labels: _radarChartLabels,
                     legendLabels: _radarChartLegendLabels,
                     colors: _radarChartColors.take(_selectedStaffIds.length).toList(),
                     title: 'Staff Comparison (${_selectedStaffIds.length} selected)',
                   ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row: Worked Hours Bar Chart
        BarChartWidget(
          data: _barChartData,
          labels: _barChartLabels,
          title: 'Weekly Worked Hours',
          minY: 0,
          maxY: 50,
          barColor: Colors.green[600], // All bars green
        ),
        const SizedBox(height: 24),
        // Third row: Tasks Snapshot
        _buildTasksSnapshot(),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.5) return Colors.green[600]!;
    if (score >= 7.5) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  Color _getHoursColor(double hours) {
    if (hours >= 40) return Colors.blue[600]!;
    if (hours >= 35) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  void _showStaffPerformanceDetails(int row, int col, double value, String rowTitle, String colTitle) {
    final staffMember = _staff[row];
    String metricName = colTitle;
    String metricValue = '';
    String description = '';

    switch (col) {
      case 0: // Customer Satisfaction
        metricValue = '${value.toStringAsFixed(1)}/10';
        if (value >= 8.5) {
          description = 'Excellent customer satisfaction rating';
        } else if (value >= 7.5) {
          description = 'Good customer satisfaction rating';
        } else {
          description = 'Needs improvement in customer satisfaction';
        }
        break;
      case 1: // Evaluation Rate
        metricValue = '${value.toStringAsFixed(1)}/10';
        if (value >= 9.0) {
          description = 'Outstanding performance evaluation';
        } else if (value >= 8.0) {
          description = 'Good performance evaluation';
        } else {
          description = 'Below average performance evaluation';
        }
        break;
      case 2: // Weekly Hours
        metricValue = '${value.toInt()} hours';
        if (value >= 40) {
          description = 'Full-time staff member';
        } else if (value >= 35) {
          description = 'Part-time staff member';
        } else {
          description = 'Limited hours staff member';
        }
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${staffMember.name} - $metricName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Staff: ${staffMember.name}'),
            Text('Metric: $metricName'),
            Text('Value: $metricValue'),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            const Text('Performance Insights:'),
            Text('• Customer Satisfaction: ${staffMember.customerSatisfactionRate.toStringAsFixed(1)}/10'),
            Text('• Evaluation Rate: ${staffMember.evaluationRate.toStringAsFixed(1)}/10'),
            Text('• Weekly Hours: ${staffMember.weeklyHours}h'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMaxSelectionError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red[50]!,
                Colors.red[100]!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red[300]!, width: 3),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 50,
                        color: Colors.red[700],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Maximum Selection Reached!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'You can only select up to 8 staff members for comparison in the radar chart.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please deselect some staff members before adding new ones.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Action button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksSnapshot() {
    final startIndex = (_currentPage - 1) * _tasksPerPage;
    final endIndex = startIndex + _tasksPerPage;
    final currentTasks = _tasks.sublist(startIndex, endIndex > _tasks.length ? _tasks.length : endIndex);
    final totalPages = (_tasks.length / _tasksPerPage).ceil();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Tasks Snapshot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF214E4B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Task Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF214E4B),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF214E4B),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Assigned To',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF214E4B),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF214E4B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Due Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF214E4B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Task Rows
            ...currentTasks.map((task) => _buildTaskRow(task)),
            
            const SizedBox(height: 16),
            
            // Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${startIndex + 1} to ${endIndex > _tasks.length ? _tasks.length : endIndex} of ${_tasks.length} entries',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    if (_currentPage > 1)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentPage--;
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Previous page',
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF214E4B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$_currentPage',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_currentPage < totalPages)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentPage++;
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Next page',
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskRow(TaskData task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Task Name with bullet
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    task.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          // Progress Bar and %
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    value: task.progress / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(task.progress),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${task.progress}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getProgressColor(task.progress),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          // Add a larger gap between progress and staff
          const SizedBox(width: 24),
          // Assigned To with Avatar
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    task.assignedTo.split(' ').first[0],
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    task.assignedTo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          // Status Badge
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(task.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Due Date
          Expanded(
            flex: 2,
            child: Text(
              _formatDueDate(task.dueDate),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 80) return Colors.green[600]!;
    if (progress >= 50) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return Colors.blue[600]!;
      case TaskStatus.pending:
        return Colors.red[600]!;
      case TaskStatus.completed:
        return Colors.green[600]!;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays > 0) {
      return '${dueDate.day} ${_getMonthName(dueDate.month)} ${dueDate.year}, ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return 'Overdue';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// Data classes for tasks
enum TaskStatus { inProgress, pending, completed }

class TaskData {
  final int id;
  final String name;
  final int progress;
  final String assignedTo;
  final TaskStatus status;
  final DateTime dueDate;

  TaskData({
    required this.id,
    required this.name,
    required this.progress,
    required this.assignedTo,
    required this.status,
    required this.dueDate,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'models/staff_member.dart';
import 'widgets/charts/charts.dart';
import 'widgets/charts/heat_map2.dart' show CustomHeatMapWidget;
import 'widgets/staff_worked_hours.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Hotel Staff Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const DashboardScreen(),
    );
  }
}

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({Key? key}) : super(key: key);

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
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

  List<StaffMember> get _filteredStaff {
    if (_searchQuery.isEmpty) {
      return _staff;
    }
    return _staff.where((member) =>
        member.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Hotel Staff Dashboard'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStaffTable(),
            const SizedBox(height: 24),
            _buildChartsSection(),
          ],
        ),
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
                          setState(() {
                            if (selected == true) {
                              _selectedStaffIds.add(member.id);
                            } else {
                              _selectedStaffIds.remove(member.id);
                            }
                          });
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
        // First row: Heat Map and Spider Chart
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heat Map
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.grid_view, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Performance Heat Map',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: CustomHeatMapWidget(
                          data: _staff.map((s) => [
                            s.customerSatisfactionRate,
                            s.evaluationRate,
                            s.weeklyHours.toDouble(),
                          ]).toList(),
                          dateLabels: _staff.map((s) => s.name.split(' ').first).toList(),
                          title: 'Staff Performance Overview',
                          xAxisLabel: 'Metric',
                          yAxisLabel: 'Staff Member',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Spider Chart
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.radar, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Staff Comparison',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select staff from table to compare (${_selectedStaffIds.length} selected)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: RadarChartCustomWidget(
                          data: _selectedStaffIds.isEmpty ? [] : _selectedStaffIds.map((staffId) {
                            final staff = _staff.firstWhere((s) => s.id == staffId);
                            return [
                              staff.customerSatisfactionRate,
                              staff.evaluationRate,
                              (staff.weeklyHours.toDouble() / 50.0) * 10.0,
                            ];
                          }).toList(),
                          labels: ['Customer Satisfaction', 'Evaluation Rate', 'Weekly Hours'],
                          legendLabels: _selectedStaffIds.isEmpty ? [] : _selectedStaffIds.map((id) {
                            return _staff.firstWhere((s) => s.id == id).name;
                          }).toList(),
                          colors: [
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                            Colors.red,
                          ],
                          title: 'Staff Comparison',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row: Worked Hours Bar Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Worked Hours',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Staff hours comparison - Green: 40+ hours, Orange: 35-39 hours, Red: <35 hours',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: StaffWorkedHours(staff: _staff),
                ),
              ],
            ),
          ),
        ),
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
}
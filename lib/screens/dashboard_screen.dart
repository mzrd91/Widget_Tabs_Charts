import 'package:flutter/material.dart';
import '../models/staff_member.dart';
import '../widgets/heat_map_chart.dart';
import '../widgets/spider_chart.dart';
import '../widgets/staff_worked_hours.dart';
import 'tabs/utilization_tab.dart';
import 'tabs/productivity_tab.dart';
import 'tabs/staff_analysis_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Utilization Metrics',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Productivity Metrics',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Staff Analysis',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UtilizationTab(),
          ProductivityTab(),
          StaffAnalysisTab(),
        ],
      ),
    );
  }
} 
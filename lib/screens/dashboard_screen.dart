import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../models/staff_member.dart';
import '../widgets/charts/charts.dart';
import '../widgets/staff_worked_hours.dart';
import 'tabs/utilization_tab.dart';
import 'tabs/productivity_tab.dart';
import 'tabs/staff_analysis_tab.dart';
import 'tabs/quality_tab.dart';
import 'tabs/labor_cost_tab.dart';
import 'tabs/engagement_tab.dart';

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
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Hotel Staff Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    themeProvider.themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.white,
                  ),
                  Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      themeProvider.toggleTheme(val);
                    },
                  ),
                ],
              ),
            ),
            Material(
              color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.blue[700],
              child: TabBar(
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
                  Tab(
                    icon: Icon(Icons.verified),
                    text: 'Quality Metrics',
                  ),
                  Tab(
                    icon: Icon(Icons.attach_money),
                    text: 'Labor Cost',
                  ),
                  Tab(
                    icon: Icon(Icons.psychology),
                    text: 'Engagement',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  UtilizationTab(),
                  ProductivityTab(),
                  StaffAnalysisTab(),
                  QualityTab(),
                  LaborCostTab(),
                  EngagementTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
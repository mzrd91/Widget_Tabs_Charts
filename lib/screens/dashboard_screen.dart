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
import 'tabs/hotel_room_overview_tab.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.analytics,
      title: 'Utilization Metrics',
      widget: const UtilizationTab(),
    ),
    NavigationItem(
      icon: Icons.trending_up,
      title: 'Productivity Metrics',
      widget: const ProductivityTab(),
    ),
    NavigationItem(
      icon: Icons.people,
      title: 'Staff Analysis',
      widget: const StaffAnalysisTab(),
    ),
    NavigationItem(
      icon: Icons.verified,
      title: 'Quality Metrics',
      widget: const QualityTab(),
    ),
    NavigationItem(
      icon: Icons.attach_money,
      title: 'Labor Cost',
      widget: const LaborCostTab(),
    ),
    NavigationItem(
      icon: Icons.psychology,
      title: 'Engagement',
      widget: const EngagementTab(),
    ),
    NavigationItem(
      icon: Icons.hotel,
      title: 'Hotel Room Overview',
      widget: const HotelRoomOverviewTab(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            // Left Sidebar Navigation
            Container(
              width: 250,
              color: Colors.blue[700],
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.dashboard,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 18,
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
                          size: 20,
                        ),
                        Switch(
                          value: themeProvider.themeMode == ThemeMode.dark,
                          onChanged: (val) {
                            themeProvider.toggleTheme(val);
                          },
                          activeColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _navigationItems.length,
                      itemBuilder: (context, index) {
                        final item = _navigationItems[index];
                        final isSelected = _selectedIndex == index;
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Settings Button at Bottom of Sidebar
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 20,
                      ),
                      title: const Text(
                        'Revenue & Pricing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Header
                  Container(
                    color: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          _navigationItems[_selectedIndex].title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: _navigationItems[_selectedIndex].widget,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String title;
  final Widget widget;

  NavigationItem({
    required this.icon,
    required this.title,
    required this.widget,
  });
} 
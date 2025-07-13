import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../widgets/charts/dynamic_pricing_matrix.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedRoomType = 'Standard';
  String _selectedSeason = 'Peak Season';
  double _basePrice = 150.0;
  double _demandMultiplier = 1.2;

  final List<String> _roomTypes = ['Standard', 'Deluxe', 'Suite', 'Presidential'];
  final List<String> _seasons = ['Off-Peak', 'Shoulder', 'Peak Season', 'Holiday'];
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Revenue Management & Pricing',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Revenue Optimized',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Row(
                children: [
                  // Left Panel - Controls
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Scrollable Content Area
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pricing Strategy Controls',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Room Type Selection
                                _buildControlSection(
                                  'Room Type',
                                  DropdownButton<String>(
                                    value: _selectedRoomType,
                                    isExpanded: true,
                                    items: _roomTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRoomType = value!;
                                      });
                                    },
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Season Selection
                                _buildControlSection(
                                  'Season',
                                  DropdownButton<String>(
                                    value: _selectedSeason,
                                    isExpanded: true,
                                    items: _seasons.map((season) {
                                      return DropdownMenuItem(
                                        value: season,
                                        child: Text(season),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSeason = value!;
                                      });
                                    },
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Base Price Slider
                                _buildControlSection(
                                  'Base Price (\$)',
                                  Column(
                                    children: [
                                      Slider(
                                        value: _basePrice,
                                        min: 50.0,
                                        max: 500.0,
                                        divisions: 45,
                                        label: '\$${_basePrice.toInt()}',
                                        onChanged: (value) {
                                          setState(() {
                                            _basePrice = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        '\$${_basePrice.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Demand Multiplier
                                _buildControlSection(
                                  'Demand Multiplier',
                                  Column(
                                    children: [
                                      Slider(
                                        value: _demandMultiplier,
                                        min: 0.5,
                                        max: 2.0,
                                        divisions: 15,
                                        label: _demandMultiplier.toStringAsFixed(1),
                                        onChanged: (value) {
                                          setState(() {
                                            _demandMultiplier = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        '${_demandMultiplier.toStringAsFixed(1)}x',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Revenue Summary
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Revenue Impact',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildRevenueMetric('Current Revenue', '\$12,450'),
                                      _buildRevenueMetric('Optimized Revenue', '\$15,680'),
                                      _buildRevenueMetric('Increase', '+26%', isPositive: true),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 32), // Extra space at bottom for scrolling
                              ],
                            ),
                          ),
                        ),
                        
                        // Fixed Action Buttons at Bottom
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(
                              top: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Apply pricing strategy
                                  },
                                  icon: const Icon(Icons.save),
                                  label: const Text('Apply'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Export report
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text('Export'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Right Panel - Dynamic Pricing Matrix
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dynamic Pricing Strategy Matrix',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Optimize pricing based on demand, seasonality, and market conditions',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: DynamicPricingMatrix(
                              roomType: _selectedRoomType,
                              season: _selectedSeason,
                              basePrice: _basePrice,
                              demandMultiplier: _demandMultiplier,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection(String title, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        control,
      ],
    );
  }

  Widget _buildRevenueMetric(String label, String value, {bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green[700] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
} 
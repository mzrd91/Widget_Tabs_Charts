import 'package:flutter/material.dart';
import 'dart:math' as math;

class DynamicPricingMatrix extends StatefulWidget {
  final String roomType;
  final String season;
  final double basePrice;
  final double demandMultiplier;

  const DynamicPricingMatrix({
    Key? key,
    required this.roomType,
    required this.season,
    required this.basePrice,
    required this.demandMultiplier,
  }) : super(key: key);

  @override
  State<DynamicPricingMatrix> createState() => _DynamicPricingMatrixState();
}

class _DynamicPricingMatrixState extends State<DynamicPricingMatrix>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int? _selectedDay;
  int? _selectedWeek;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${widget.roomType} - ${widget.season}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildLegend(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      ...List.generate(4, (weekIndex) => Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            'W${weekIndex + 1}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        height: 7 * 100, // 7 rows × 100px
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Column(
                                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                                  return Container(
                                    height: 100,
                                    alignment: Alignment.center,
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: List.generate(7, (day) {
                                  return SizedBox(
                                    height: 100,
                                    child: Row(
                                      children: List.generate(4, (week) {
                                        final price = _calculatePrice(day, week);
                                        final isSelected = _selectedDay == day && _selectedWeek == week;
                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedDay = day;
                                                _selectedWeek = week;
                                              });
                                              _showPriceDetails(day, week, price);
                                            },
                                            child: AnimatedBuilder(
                                              animation: _pulseAnimation,
                                              builder: (context, child) {
                                                return Container(
                                                  margin: const EdgeInsets.all(0.5),
                                                  decoration: BoxDecoration(
                                                    color: _getPriceColor(price),
                                                    borderRadius: BorderRadius.circular(2),
                                                    border: isSelected
                                                        ? Border.all(color: Colors.blue, width: 1)
                                                        : null,
                                                    boxShadow: isSelected
                                                        ? [
                                                            BoxShadow(
                                                              color: Colors.blue.withOpacity(0.3),
                                                              blurRadius: 3,
                                                              spreadRadius: 1,
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '\$${price.toInt()}',
                                                      style: TextStyle(
                                                        fontSize: isSelected ? 10 : 9,
                                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                        color: _getTextColor(price),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('Low', Colors.green[100]!, Colors.green[800]!),
        const SizedBox(width: 8),
        _buildLegendItem('Medium', Colors.yellow[100]!, Colors.orange[800]!),
        const SizedBox(width: 8),
        _buildLegendItem('High', Colors.red[100]!, Colors.red[800]!),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _calculatePrice(int day, int week) {
    double price = widget.basePrice;
    if (day >= 4) price *= 1.3;
    switch (week) {
      case 0: price *= 0.9; break;
      case 1: price *= 1.0; break;
      case 2: price *= 1.2; break;
      case 3: price *= 1.4; break;
    }
    switch (widget.season) {
      case 'Off-Peak': price *= 0.7; break;
      case 'Shoulder': price *= 0.9; break;
      case 'Peak Season': price *= 1.2; break;
      case 'Holiday': price *= 1.5; break;
    }
    price *= widget.demandMultiplier;
    switch (widget.roomType) {
      case 'Deluxe': price *= 1.3; break;
      case 'Suite': price *= 2.0; break;
      case 'Presidential': price *= 4.0; break;
    }
    return price;
  }

  Color _getPriceColor(double price) {
    final basePrice = widget.basePrice;
    final ratio = price / basePrice;
    if (ratio < 0.8) return Colors.green[100]!;
    if (ratio < 1.2) return Colors.yellow[100]!;
    if (ratio < 1.5) return Colors.orange[100]!;
    return Colors.red[100]!;
  }

  Color _getTextColor(double price) {
    final basePrice = widget.basePrice;
    final ratio = price / basePrice;
    if (ratio < 0.8) return Colors.green[800]!;
    if (ratio < 1.2) return Colors.orange[800]!;
    if (ratio < 1.5) return Colors.orange[900]!;
    return Colors.red[800]!;
  }

  String _getDemandLevel(int day, int week) {
    if (day >= 4) return 'High';
    if (week >= 2) return 'High';
    return 'Low';
  }

  void _showPriceDetails(int day, int week, double price) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${days[day]} - Week ${week + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Price: \$${price.toInt()}'),
            const SizedBox(height: 16),
            const Text('Pricing Factors:'),
            Text('• Base Price: \$${widget.basePrice.toInt()}'),
            Text('• Season: ${widget.season}'),
            Text('• Demand: ${_getDemandLevel(day, week)}'),
            Text('• Room Type: ${widget.roomType}'),
            const SizedBox(height: 16),
            const Text('Recommendations:'),
            if (price < widget.basePrice * 0.8)
              const Text('• Consider increasing price - below market rate'),
            if (price > widget.basePrice * 1.5)
              const Text('• Monitor occupancy - price may be too high'),
            if (day >= 4)
              const Text('• Weekend pricing - premium applied'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

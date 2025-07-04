class StaffMember {
  final int id;
  final String name;
  final double customerSatisfactionRate;
  final double evaluationRate;
  final double weeklyHours;

  StaffMember({
    required this.id,
    required this.name,
    required this.customerSatisfactionRate,
    required this.evaluationRate,
    required this.weeklyHours,
  });

  String get firstName => name.split(' ').first;
  String get initials => name.split(' ').map((n) => n[0]).join('');

  // Normalize values for chart display (0-1 scale)
  double get normalizedCustomerSatisfaction => customerSatisfactionRate / 10.0;
  double get normalizedEvaluation => evaluationRate / 10.0;
  double get normalizedWeeklyHours => weeklyHours / 50.0; // Assuming max 50 hours

  // Get performance level
  String get performanceLevel {
    final avg = (customerSatisfactionRate + evaluationRate) / 2;
    if (avg >= 8.5) return 'Excellent';
    if (avg >= 7.5) return 'Good';
    if (avg >= 6.5) return 'Average';
    return 'Needs Improvement';
  }

  // Get all metrics as a list for easy iteration
  List<double> get metrics => [
    customerSatisfactionRate,
    evaluationRate,
    weeklyHours,
  ];

  List<double> get normalizedMetrics => [
    normalizedCustomerSatisfaction,
    normalizedEvaluation,
    normalizedWeeklyHours,
  ];
}
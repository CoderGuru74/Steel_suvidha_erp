class PlanModel {
  final String id;
  final String badge;
  final String price;
  final int amountInPaise;
  final String billingCycle;
  final List<String> limits;
  final List<String> features;

  const PlanModel({
    required this.id,
    required this.badge,
    required this.price,
    required this.amountInPaise,
    this.billingCycle = 'Per Month',
    required this.limits,
    required this.features,
  });

  static const List<PlanModel> defaultPlans = [
    PlanModel(
      id: 'plan_base',
      badge: 'BASE',
      price: '₹1,999',
      amountInPaise: 199900,
      limits: [
        '1 Admin',
        '1 Sales Panel',
        '2 Processing Panels',
      ],
      features: [
        'Standard Order Taking',
        'Basic Inventory Management',
        'Daily Daybook Export',
      ],
    ),
    PlanModel(
      id: 'plan_growth',
      badge: 'GROWTH',
      price: '₹2,999',
      amountInPaise: 299900,
      limits: [
        '2 Admin',
        '3 Sales Panel',
        '2 Processing Panels',
      ],
      features: [
        'Standard Order Taking',
        'Basic Inventory Management',
        'Daily Daybook Export',
      ],
    ),
    PlanModel(
      id: 'plan_enterprise',
      badge: 'ENTERPRISE',
      price: '₹4,999',
      amountInPaise: 499900,
      limits: [
        'Unlimited Admin',
        'Unlimited Sales Panels',
        'Unlimited Processing Panels',
      ],
      features: [
        'Advanced Multi-Yard Inventory',
        'Automated GST & E-Way Billing',
        'Full Daybook & Party Ledger Analytics',
      ],
    ),
  ];
}
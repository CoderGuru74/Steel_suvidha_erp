class StoreRecord {
  final String id;
  final String storeName;
  final String ownerName;
  final String email;
  final String phone;
  final String city;
  final String planId; // 'plan_base', 'plan_growth', 'plan_enterprise'
  final String planBadge; // 'BASE', 'GROWTH', 'ENTERPRISE'
  final String planTierLabel; // 'Basic', 'Growth', 'Enterprise'
  final String validity;
  final String lastActive;
  final int activeUsersCount;
  final int salesUsed;
  final int salesQuota;
  final int procureUsed;
  final int procureQuota;
  final int customersCount;
  final int ordersCount;
  final bool isActive;
  final DateTime createdAt;

  const StoreRecord({
    required this.id,
    required this.storeName,
    required this.ownerName,
    this.email = 'hello@shreeramsteel.com',
    this.phone = '+91 29348 52893',
    required this.city,
    required this.planId,
    required this.planBadge,
    this.planTierLabel = 'Basic',
    required this.validity,
    this.lastActive = '2 hrs ago',
    required this.activeUsersCount,
    this.salesUsed = 4,
    this.salesQuota = 5,
    this.procureUsed = 6,
    this.procureQuota = 10,
    this.customersCount = 64,
    this.ordersCount = 64,
    this.isActive = true,
    required this.createdAt,
  });

  StoreRecord copyWith({
    String? storeName,
    String? ownerName,
    String? email,
    String? phone,
    String? city,
    String? planId,
    String? planBadge,
    String? planTierLabel,
    String? validity,
    String? lastActive,
    int? activeUsersCount,
    int? salesUsed,
    int? salesQuota,
    int? procureUsed,
    int? procureQuota,
    int? customersCount,
    int? ordersCount,
    bool? isActive,
  }) {
    return StoreRecord(
      id: id,
      storeName: storeName ?? this.storeName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      planId: planId ?? this.planId,
      planBadge: planBadge ?? this.planBadge,
      planTierLabel: planTierLabel ?? this.planTierLabel,
      validity: validity ?? this.validity,
      lastActive: lastActive ?? this.lastActive,
      activeUsersCount: activeUsersCount ?? this.activeUsersCount,
      salesUsed: salesUsed ?? this.salesUsed,
      salesQuota: salesQuota ?? this.salesQuota,
      procureUsed: procureUsed ?? this.procureUsed,
      procureQuota: procureQuota ?? this.procureQuota,
      customersCount: customersCount ?? this.customersCount,
      ordersCount: ordersCount ?? this.ordersCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

class SubscriptionPlanConfig {
  final String id;
  final String name;
  final String badge;
  final int monthlyPriceInr;
  final int maxAdmins;
  final int maxSalesPanels;
  final int maxProcessingPanels;
  final String featuresSummary;

  const SubscriptionPlanConfig({
    required this.id,
    this.name = 'Basic',
    required this.badge,
    required this.monthlyPriceInr,
    required this.maxAdmins,
    required this.maxSalesPanels,
    required this.maxProcessingPanels,
    this.featuresSummary = 'Admin | Sales | Procurement + Basic day book (with download)',
  });

  SubscriptionPlanConfig copyWith({
    String? name,
    String? badge,
    int? monthlyPriceInr,
    int? maxAdmins,
    int? maxSalesPanels,
    int? maxProcessingPanels,
    String? featuresSummary,
  }) {
    return SubscriptionPlanConfig(
      id: id,
      name: name ?? this.name,
      badge: badge ?? this.badge,
      monthlyPriceInr: monthlyPriceInr ?? this.monthlyPriceInr,
      maxAdmins: maxAdmins ?? this.maxAdmins,
      maxSalesPanels: maxSalesPanels ?? this.maxSalesPanels,
      maxProcessingPanels: maxProcessingPanels ?? this.maxProcessingPanels,
      featuresSummary: featuresSummary ?? this.featuresSummary,
    );
  }
}

class AuditLogEntry {
  final String id;
  final String action;
  final String detail;
  final DateTime timestamp;
  final bool isUnread;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.detail,
    required this.timestamp,
    this.isUnread = true,
  });

  AuditLogEntry copyWith({bool? isUnread}) {
    return AuditLogEntry(
      id: id,
      action: action,
      detail: detail,
      timestamp: timestamp,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

class GroupedChartSeries {
  final String label;
  final double valueA;
  final double valueB;
  final double valueC;

  const GroupedChartSeries({
    required this.label,
    required this.valueA,
    required this.valueB,
    required this.valueC,
  });
}
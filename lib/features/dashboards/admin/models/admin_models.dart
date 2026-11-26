enum AdminStaffRole {
  admin('Admin'),
  salesTeam('Sales Team'),
  orderProcessing('Order Processing Team');

  final String label;
  const AdminStaffRole(this.label);
}

class AdminStaffMember {
  final String id;
  final String name;
  final String roleLabel;
  final String phone;
  final bool isActive;

  const AdminStaffMember({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.phone,
    this.isActive = true,
  });

  AdminStaffMember copyWith({
    String? name,
    String? roleLabel,
    String? phone,
    bool? isActive,
  }) {
    return AdminStaffMember(
      id: id,
      name: name ?? this.name,
      roleLabel: roleLabel ?? this.roleLabel,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }
}

class AdminActivityItem {
  final String id;
  final String title;
  final String status;
  final bool isCompleted;

  const AdminActivityItem({
    required this.id,
    required this.title,
    required this.status,
    this.isCompleted = false,
  });
}

class StoreBrandingProfile {
  final String storeName;
  final String gstin;
  final String contactNumber;
  final String physicalAddress;
  final String avatarLabel;

  const StoreBrandingProfile({
    this.storeName = 'Shree Ram Steel',
    this.gstin = '10AABCS1429B1Z5',
    this.contactNumber = '+91 29348 52893',
    this.physicalAddress = 'Boring Canal Road, Patna, Bihar 800001',
    this.avatarLabel = 'Selected Photo',
  });

  StoreBrandingProfile copyWith({
    String? storeName,
    String? gstin,
    String? contactNumber,
    String? physicalAddress,
    String? avatarLabel,
  }) {
    return StoreBrandingProfile(
      storeName: storeName ?? this.storeName,
      gstin: gstin ?? this.gstin,
      contactNumber: contactNumber ?? this.contactNumber,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      avatarLabel: avatarLabel ?? this.avatarLabel,
    );
  }
}

class StoreSubscriptionInfo {
  final String planName;
  final String badge;
  final int monthlyPriceInr;
  final String staffPanelSummary;
  final String featuresSummary;
  final int adminSeatsUsed;
  final int adminSeatsLimit;
  final int salesSeatsUsed;
  final int salesSeatsLimit;
  final int procurementSeatsUsed;
  final int procurementSeatsLimit;

  const StoreSubscriptionInfo({
    this.planName = 'Basic',
    this.badge = 'BASE',
    this.monthlyPriceInr = 5000,
    this.staffPanelSummary = '2 Admin | 4 Sales | 8 Procurement',
    this.featuresSummary =
        'Admin | Sales | Procurement + Basic day book (with download)',
    this.adminSeatsUsed = 2,
    this.adminSeatsLimit = 2,
    this.salesSeatsUsed = 3,
    this.salesSeatsLimit = 5,
    this.procurementSeatsUsed = 4,
    this.procurementSeatsLimit = 5,
  });

  StoreSubscriptionInfo copyWith({
    String? planName,
    String? badge,
    int? monthlyPriceInr,
    String? staffPanelSummary,
    String? featuresSummary,
    int? adminSeatsUsed,
    int? salesSeatsUsed,
    int? procurementSeatsUsed,
  }) {
    return StoreSubscriptionInfo(
      planName: planName ?? this.planName,
      badge: badge ?? this.badge,
      monthlyPriceInr: monthlyPriceInr ?? this.monthlyPriceInr,
      staffPanelSummary: staffPanelSummary ?? this.staffPanelSummary,
      featuresSummary: featuresSummary ?? this.featuresSummary,
      adminSeatsUsed: adminSeatsUsed ?? this.adminSeatsUsed,
      salesSeatsUsed: salesSeatsUsed ?? this.salesSeatsUsed,
      procurementSeatsUsed: procurementSeatsUsed ?? this.procurementSeatsUsed,
    );
  }
}
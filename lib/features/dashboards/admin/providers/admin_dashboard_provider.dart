import 'package:flutter/foundation.dart';
import '../models/admin_models.dart';

enum AdminPanelSection {
  overview('Dashboard'),
  staffDirectory('Staff Directory'),
  staffProfile('Staff Profile'),
  brandingProfile('Branding & Profile'),
  subscription('Manage Subscription');

  final String label;
  const AdminPanelSection(this.label);
}

enum StaffFilterTab {
  allStaff('All Staff'),
  sales('Sales'),
  procurement('Procurement');

  final String label;
  const StaffFilterTab(this.label);
}

class AdminDashboardProvider extends ChangeNotifier {
  AdminPanelSection _currentSection = AdminPanelSection.overview;
  StaffFilterTab _staffTab = StaffFilterTab.allStaff;
  bool _isSidebarOpen = false;
  bool _showDataUtilitiesSubView = false;

  int _todaysSaleInr = 168000;
  int _orderCount = 25;
  int _pendingOrdersTop = 5;
  int _pendingOrdersBottom = 3;
  int _ordersInProcess = 2;
  int _ordersDispatched = 18;
  int _cashReceivedInr = 108000;
  int _salesReceivableInr = 58000;
  int _cashPaidInr = 108000;
  int _expensesInr = 108000;
  int _lowStockAlerts = 3;

  StoreBrandingProfile _branding = const StoreBrandingProfile();
  StoreSubscriptionInfo _subscription = const StoreSubscriptionInfo();
  AdminStaffMember? _editingStaff;

  final List<AdminActivityItem> _activities = [
    const AdminActivityItem(
      id: 'ACT-1',
      title: 'Order #SS102',
      status: 'In Processing',
      isCompleted: false,
    ),
    const AdminActivityItem(
      id: 'ACT-2',
      title: 'Order #SS103',
      status: 'Completed',
      isCompleted: true,
    ),
  ];

  final List<AdminStaffMember> _staffList = List.generate(
    9,
    (index) => AdminStaffMember(
      id: 'STF-${index + 1}',
      name: 'Amit Patel',
      roleLabel: 'Sales Team',
      phone: '+91 98765 4321$index',
      isActive: true,
    ),
  );

  AdminPanelSection get currentSection => _currentSection;
  StaffFilterTab get staffTab => _staffTab;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get showDataUtilitiesSubView => _showDataUtilitiesSubView;

  int get todaysSaleInr => _todaysSaleInr;
  int get orderCount => _orderCount;
  int get pendingOrdersTop => _pendingOrdersTop;
  int get pendingOrdersBottom => _pendingOrdersBottom;
  int get ordersInProcess => _ordersInProcess;
  int get ordersDispatched => _ordersDispatched;
  int get cashReceivedInr => _cashReceivedInr;
  int get salesReceivableInr => _salesReceivableInr;
  int get cashPaidInr => _cashPaidInr;
  int get expensesInr => _expensesInr;
  int get lowStockAlerts => _lowStockAlerts;

  StoreBrandingProfile get branding => _branding;
  StoreSubscriptionInfo get subscription => _subscription;
  AdminStaffMember? get editingStaff => _editingStaff;
  List<AdminActivityItem> get activities => List.unmodifiable(_activities);

  List<AdminStaffMember> get filteredStaff {
    switch (_staffTab) {
      case StaffFilterTab.allStaff:
        return List.unmodifiable(_staffList);
      case StaffFilterTab.sales:
        return _staffList
            .where((s) => s.roleLabel.toLowerCase().contains('sales'))
            .toList();
      case StaffFilterTab.procurement:
        return _staffList
            .where((s) =>
                s.roleLabel.toLowerCase().contains('procurement') ||
                s.roleLabel.toLowerCase().contains('processing'))
            .toList();
    }
  }

  String get formattedTodaysSale => _formatInrSpace(_todaysSaleInr);
  String get formattedCashReceived => _formatInrSpace(_cashReceivedInr);
  String get formattedSalesReceivable => _formatInrSpace(_salesReceivableInr);
  String get formattedCashPaid => _formatInrSpace(_cashPaidInr);
  String get formattedExpenses => _formatInrSpace(_expensesInr);

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void setSidebarOpen(bool open) {
    _isSidebarOpen = open;
    notifyListeners();
  }

  void openSection(AdminPanelSection section) {
    _currentSection = section;
    if (section != AdminPanelSection.subscription) {
      _showDataUtilitiesSubView = false;
    }
    notifyListeners();
  }

  void setStaffTab(StaffFilterTab tab) {
    _staffTab = tab;
    notifyListeners();
  }

  void toggleDataUtilitiesSubView(bool showUtilities) {
    _showDataUtilitiesSubView = showUtilities;
    notifyListeners();
  }

  void openAddStaffForm() {
    _editingStaff = null;
    _currentSection = AdminPanelSection.staffProfile;
    notifyListeners();
  }

  void openEditStaffForm(AdminStaffMember member) {
    _editingStaff = member;
    _currentSection = AdminPanelSection.staffProfile;
    notifyListeners();
  }

  void saveStaffMember({
    required String fullName,
    required String phone,
    required AdminStaffRole role,
  }) {
    final cleanName = fullName.trim().isEmpty ? 'Amit Patel' : fullName.trim();
    final cleanPhone =
        phone.trim().isEmpty ? '+91 98765 00000' : phone.trim();

    if (_editingStaff != null) {
      final idx = _staffList.indexWhere((s) => s.id == _editingStaff!.id);
      if (idx != -1) {
        _staffList[idx] = _staffList[idx].copyWith(
          name: cleanName,
          roleLabel: role.label,
          phone: cleanPhone,
        );
      }
      _editingStaff = null;
    } else {
      _staffList.insert(
        0,
        AdminStaffMember(
          id: 'STF-${_staffList.length + 1}',
          name: cleanName,
          roleLabel: role.label,
          phone: cleanPhone,
          isActive: true,
        ),
      );
    }

    _activities.insert(
      0,
      AdminActivityItem(
        id: 'ACT-${_activities.length + 1}',
        title: 'Staff • $cleanName',
        status: role.label,
        isCompleted: true,
      ),
    );
    _currentSection = AdminPanelSection.staffDirectory;
    notifyListeners();
  }

  void deleteStaffMember(String id) {
    _staffList.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void cycleStaffRole(String id) {
    final idx = _staffList.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final current = _staffList[idx];
    final nextRole = current.roleLabel == 'Sales Team'
        ? 'Order Processing Team'
        : current.roleLabel == 'Order Processing Team'
            ? 'Admin'
            : 'Sales Team';
    _staffList[idx] = current.copyWith(roleLabel: nextRole);
    notifyListeners();
  }

  void addStockEntry(int amountInr, int addedUnits) {
    _todaysSaleInr += amountInr;
    _orderCount += addedUnits;
    _lowStockAlerts = (_lowStockAlerts - 1).clamp(0, 99);
    _activities.insert(
      0,
      AdminActivityItem(
        id: 'ACT-${_activities.length + 1}',
        title: 'Stock +$addedUnits MT',
        status: 'Completed',
        isCompleted: true,
      ),
    );
    notifyListeners();
  }

  void updateBranding({
    required String storeName,
    required String gstin,
    required String contactNumber,
    required String physicalAddress,
  }) {
    _branding = _branding.copyWith(
      storeName: storeName.trim().isEmpty ? _branding.storeName : storeName.trim(),
      gstin: gstin.trim().isEmpty ? _branding.gstin : gstin.trim(),
      contactNumber: contactNumber.trim().isEmpty
          ? _branding.contactNumber
          : contactNumber.trim(),
      physicalAddress: physicalAddress.trim().isEmpty
          ? _branding.physicalAddress
          : physicalAddress.trim(),
    );
    notifyListeners();
  }

  void updatePhotoLabel(String label) {
    _branding = _branding.copyWith(avatarLabel: label);
    notifyListeners();
  }

  void upgradePlanSample() {
    final isBasic = _subscription.planName == 'Basic';
    _subscription = _subscription.copyWith(
      planName: isBasic ? 'Growth' : 'Basic',
      badge: isBasic ? 'GROWTH' : 'BASE',
      monthlyPriceInr: isBasic ? 8500 : 5000,
      staffPanelSummary: isBasic
          ? '4 Admin | 8 Sales | 12 Procurement'
          : '2 Admin | 4 Sales | 8 Procurement',
    );
    notifyListeners();
  }

  void executeDangerAction(String actionTitle) {
    if (actionTitle == 'Delete Customer Database') {
      _salesReceivableInr = 0;
    } else if (actionTitle == 'Clear Sales History') {
      _todaysSaleInr = 0;
      _orderCount = 0;
    } else if (actionTitle == 'Reset Everything') {
      _todaysSaleInr = 0;
      _orderCount = 0;
      _pendingOrdersTop = 0;
      _pendingOrdersBottom = 0;
      _ordersInProcess = 0;
      _ordersDispatched = 0;
      _cashReceivedInr = 0;
      _salesReceivableInr = 0;
      _cashPaidInr = 0;
      _expensesInr = 0;
      _lowStockAlerts = 0;
    }
    _activities.insert(
      0,
      AdminActivityItem(
        id: 'ACT-${_activities.length + 1}',
        title: actionTitle,
        status: 'Completed',
        isCompleted: true,
      ),
    );
    notifyListeners();
  }

  String _formatInrSpace(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return '₹ $s';
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) {
        buf.write(',');
      }
      buf.write(rest[i]);
    }
    return '₹ ${buf.toString()},$last3';
  }
}
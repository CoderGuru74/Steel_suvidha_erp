import 'package:flutter/foundation.dart';
import '../data/super_admin_repository.dart';
import '../models/super_admin_models.dart';

enum SuperAdminNavTab {
  dashboard('Dashboard'),
  stores('Stores'),
  plans('Plans'),
  logs('Logs'),
  notification('Notification'),
  settings('Settings');

  final String label;
  const SuperAdminNavTab(this.label);
}

class SuperAdminProvider extends ChangeNotifier {
  final SuperAdminRepository _repository;

  SuperAdminProvider({SuperAdminRepository? repository})
      : _repository = repository ?? SuperAdminRepository() {
    loadInitialData();
  }

  SuperAdminNavTab _selectedTab = SuperAdminNavTab.dashboard;
  bool _isSidebarOpen = false;
  bool _isLoading = true;
  String _storeSearchQuery = '';
  String _storeStatusFilter = 'All';
  bool _autoApproveStores = true;
  bool _maintenanceMode = false;
  String? _selectedStoreIdForDetails;

  List<StoreRecord> _stores = [];
  List<SubscriptionPlanConfig> _plans = [];
  final List<AuditLogEntry> _logs = [];

  SuperAdminNavTab get selectedTab => _selectedTab;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isLoading => _isLoading;
  String get storeSearchQuery => _storeSearchQuery;
  String get storeStatusFilter => _storeStatusFilter;
  bool get autoApproveStores => _autoApproveStores;
  bool get maintenanceMode => _maintenanceMode;

  StoreRecord? get selectedStoreForDetails {
    if (_selectedStoreIdForDetails == null) return null;
    try {
      return _stores.firstWhere((s) => s.id == _selectedStoreIdForDetails);
    } catch (_) {
      return null;
    }
  }

  List<StoreRecord> get allStores => List.unmodifiable(_stores);
  List<SubscriptionPlanConfig> get plans => List.unmodifiable(_plans);
  List<AuditLogEntry> get logs => List.unmodifiable(_logs);
  int get unreadNotificationCount => _logs.where((l) => l.isUnread).length;

  List<StoreRecord> get filteredStores {
    return _stores.where((store) {
      final matchesFilter = _storeStatusFilter == 'All' ||
          (_storeStatusFilter == 'Active' && store.isActive) ||
          (_storeStatusFilter == 'Suspended' && !store.isActive);
      final q = _storeSearchQuery.toLowerCase();
      final matchesQuery = q.isEmpty ||
          store.storeName.toLowerCase().contains(q) ||
          store.ownerName.toLowerCase().contains(q) ||
          store.city.toLowerCase().contains(q) ||
          store.planBadge.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  int get activeStoresCount => _stores.where((s) => s.isActive).length;

  int get monthlyRecurringRevenueInr {
    if (_plans.isEmpty) return 0;
    int total = 0;
    for (final store in _stores.where((s) => s.isActive)) {
      final plan = _plans.firstWhere(
        (p) => p.id == store.planId,
        orElse: () => _plans.first,
      );
      total += plan.monthlyPriceInr;
    }
    return total;
  }

  String get formattedMrr => _formatIndianCurrency(monthlyRecurringRevenueInr);

  int get totalUsersCount =>
      _stores.fold<int>(0, (sum, store) => sum + store.activeUsersCount);

  List<double> get activeStoreChartBars {
    final base = activeStoresCount.clamp(1, 50);
    return [
      (base * 0.35 / 10).clamp(0.2, 0.95),
      (base * 0.65 / 10).clamp(0.3, 0.95),
      (base * 0.85 / 10).clamp(0.4, 0.98),
      (base * 0.55 / 10).clamp(0.25, 0.95),
      (base * 0.32 / 10).clamp(0.2, 0.95),
      (base * 0.68 / 10).clamp(0.3, 0.95),
      (base * 0.92 / 10).clamp(0.45, 1.0),
      (activeStoresCount / (_stores.isEmpty ? 1 : _stores.length))
          .clamp(0.25, 1.0),
    ];
  }

  List<double> get mrrTrendPoints {
    final ratio = (monthlyRecurringRevenueInr / 50000).clamp(0.25, 1.0);
    return [
      0.16,
      0.32,
      0.40,
      0.27,
      0.35,
      0.54,
      0.70,
      (ratio * 0.88).clamp(0.3, 0.95),
      ratio,
    ];
  }

  List<double> get totalUsersTrendPoints {
    final ratio = (totalUsersCount / 90).clamp(0.25, 1.0);
    return [
      0.14,
      0.30,
      0.39,
      0.25,
      0.34,
      0.52,
      0.69,
      (ratio * 0.89).clamp(0.3, 0.95),
      ratio,
    ];
  }

  List<GroupedChartSeries> get userGrowthSeries {
    final factor = (totalUsersCount / 84.0).clamp(0.5, 1.4);
    const months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
    return months
        .map(
          (m) => GroupedChartSeries(
            label: m,
            valueA: (2.81 * factor).clamp(1.0, 4.8),
            valueB: (3.58 * factor).clamp(1.2, 4.9),
            valueC: (4.30 * factor).clamp(1.5, 5.0),
          ),
        )
        .toList();
  }

  List<GroupedChartSeries> get recentRevenueSeries {
    final activeRatio =
        (activeStoresCount / (_stores.isEmpty ? 1 : _stores.length))
            .clamp(0.5, 1.3);
    const months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
    return months
        .map(
          (m) => GroupedChartSeries(
            label: m,
            valueA: (2.81 * activeRatio).clamp(1.0, 4.8),
            valueB: (3.58 * activeRatio).clamp(1.2, 4.9),
            valueC: (4.30 * activeRatio).clamp(1.5, 5.0),
          ),
        )
        .toList();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    _plans = await _repository.fetchPlans();
    _stores = await _repository.fetchStores();

    _logs.insert(
      0,
      AuditLogEntry(
        id: 'LOG-001',
        action: 'Platform Synced',
        detail:
            'Loaded ${_stores.length} stores (${activeStoresCount} active) • MRR $formattedMrr',
        timestamp: DateTime.now(),
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  void selectTab(SuperAdminNavTab tab) {
    _selectedTab = tab;
    if (tab != SuperAdminNavTab.stores) {
      _selectedStoreIdForDetails = null;
    }
    if (tab == SuperAdminNavTab.notification) {
      markAllNotificationsRead();
    }
    notifyListeners();
  }

  void openStoreDetails(String storeId) {
    _selectedTab = SuperAdminNavTab.stores;
    _selectedStoreIdForDetails = storeId;
    notifyListeners();
  }

  void closeStoreDetails() {
    _selectedStoreIdForDetails = null;
    notifyListeners();
  }

  void updateStoreDetails({
    required String storeId,
    required String storeName,
    required String ownerName,
    required String email,
    required String phone,
    required String validity,
  }) {
    final index = _stores.indexWhere((s) => s.id == storeId);
    if (index == -1) return;

    final updated = _stores[index].copyWith(
      storeName: storeName.trim(),
      ownerName: ownerName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      validity: validity.trim(),
    );
    _stores[index] = updated;
    _addLog(
      'Store Details Updated',
      'Updated details for ${updated.storeName} (${updated.ownerName}).',
    );
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void setSidebarOpen(bool open) {
    _isSidebarOpen = open;
    notifyListeners();
  }

  void setStoreSearchQuery(String query) {
    _storeSearchQuery = query;
    notifyListeners();
  }

  void setStoreStatusFilter(String filter) {
    _storeStatusFilter = filter;
    notifyListeners();
  }

  void addStore({
    required String storeName,
    required String ownerName,
    required String city,
    String planId = 'plan_base_1',
    int initialUsers = 5,
  }) {
    final plan = _plans.isEmpty
        ? const SubscriptionPlanConfig(
            id: 'plan_base_1',
            name: 'Basic',
            badge: 'BASE',
            monthlyPriceInr: 5000,
            maxAdmins: 2,
            maxSalesPanels: 4,
            maxProcessingPanels: 8,
          )
        : _plans.firstWhere(
            (p) => p.id == planId,
            orElse: () => _plans.first,
          );

    final newStore = StoreRecord(
      id: 'ST-${101 + _stores.length}',
      storeName: storeName.trim(),
      ownerName: ownerName.trim().isEmpty ? 'Store Owner' : ownerName.trim(),
      city: city.trim().isEmpty ? 'Patna, Bihar' : city.trim(),
      planId: plan.id,
      planBadge: plan.badge,
      planTierLabel: plan.name,
      validity: '12 Nov 2026',
      lastActive: 'Just now',
      activeUsersCount: initialUsers,
      isActive: _autoApproveStores,
      createdAt: DateTime.now(),
    );

    _stores.insert(0, newStore);
    _addLog(
      'New Store Registered',
      '${newStore.storeName} (${newStore.city}) added on ${newStore.planBadge} plan.',
    );
    notifyListeners();
  }

  void toggleStoreStatus(String storeId) {
    final index = _stores.indexWhere((s) => s.id == storeId);
    if (index == -1) return;

    final current = _stores[index];
    final updated = current.copyWith(isActive: !current.isActive);
    _stores[index] = updated;

    _addLog(
      updated.isActive ? 'Store Activated' : 'Store Suspended',
      '${updated.storeName} is now ${updated.isActive ? 'Active' : 'Suspended'}.',
    );
    notifyListeners();
  }

  void changeStorePlan(String storeId, String newPlanId) {
    final index = _stores.indexWhere((s) => s.id == storeId);
    if (index == -1 || _plans.isEmpty) return;

    final plan = _plans.firstWhere((p) => p.id == newPlanId);
    final updated = _stores[index].copyWith(
      planId: plan.id,
      planBadge: plan.badge,
      planTierLabel: plan.name,
    );
    _stores[index] = updated;

    _addLog(
      'Store Plan Updated',
      '${updated.storeName} switched to ${plan.badge} (₹${plan.monthlyPriceInr}/mo).',
    );
    notifyListeners();
  }

  void createPlan({
    required String name,
    required String badge,
    required int monthlyPriceInr,
    required int maxAdmins,
    required int maxSalesPanels,
    required int maxProcessingPanels,
    required String featuresSummary,
  }) {
    final newPlan = SubscriptionPlanConfig(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Basic' : name.trim(),
      badge: badge.trim().isEmpty ? 'BASE' : badge.trim().toUpperCase(),
      monthlyPriceInr: monthlyPriceInr,
      maxAdmins: maxAdmins,
      maxSalesPanels: maxSalesPanels,
      maxProcessingPanels: maxProcessingPanels,
      featuresSummary: featuresSummary.trim().isEmpty
          ? 'Admin | Sales | Procurement + Basic day book (with download)'
          : featuresSummary.trim(),
    );
    _plans.add(newPlan);
    _addLog(
      'Plan Created',
      'Created ${newPlan.name} (${newPlan.badge}) at ₹${newPlan.monthlyPriceInr}/mo.',
    );
    notifyListeners();
  }

  void updatePlanConfig({
    required String planId,
    required String name,
    required String badge,
    required int monthlyPriceInr,
    required int maxAdmins,
    required int maxSalesPanels,
    required int maxProcessingPanels,
    required String featuresSummary,
  }) {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index == -1 || monthlyPriceInr <= 0) return;

    final updated = _plans[index].copyWith(
      name: name.trim(),
      badge: badge.trim().toUpperCase(),
      monthlyPriceInr: monthlyPriceInr,
      maxAdmins: maxAdmins,
      maxSalesPanels: maxSalesPanels,
      maxProcessingPanels: maxProcessingPanels,
      featuresSummary: featuresSummary.trim(),
    );
    _plans[index] = updated;

    _addLog(
      'Plan Updated',
      '${updated.name} (${updated.badge}) updated to ₹$monthlyPriceInr/month.',
    );
    notifyListeners();
  }

  void removePlan(String planId) {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index == -1) return;
    final removed = _plans.removeAt(index);
    _addLog(
      'Plan Removed',
      'Removed ${removed.name} (${removed.badge}) plan.',
    );
    notifyListeners();
  }

  void setAutoApproveStores(bool value) {
    _autoApproveStores = value;
    _addLog(
      'Platform Setting Changed',
      'Auto-approve new store registrations set to ${value ? 'ON' : 'OFF'}.',
    );
    notifyListeners();
  }

  void setMaintenanceMode(bool value) {
    _maintenanceMode = value;
    _addLog(
      'Platform Setting Changed',
      'Global maintenance mode set to ${value ? 'ON' : 'OFF'}.',
    );
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (int i = 0; i < _logs.length; i++) {
      _logs[i] = _logs[i].copyWith(isUnread: false);
    }
    notifyListeners();
  }

  void _addLog(String action, String detail) {
    _logs.insert(
      0,
      AuditLogEntry(
        id: 'LOG-${(_logs.length + 1).toString().padLeft(3, '0')}',
        action: action,
        detail: detail,
        timestamp: DateTime.now(),
      ),
    );
  }

  String _formatIndianCurrency(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return '₹ $str';
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    return '₹ ${buffer.toString()},$lastThree';
  }
}
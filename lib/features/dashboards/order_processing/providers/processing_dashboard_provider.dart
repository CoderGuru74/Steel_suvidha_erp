import 'package:flutter/foundation.dart';
import '../models/processing_models.dart';

class ProcessingDashboardProvider extends ChangeNotifier {
  ProcessingOrderStatus _selectedFilter = ProcessingOrderStatus.all;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _isSidebarOpen = false;
  String? _activeDetailOrderId;

  static List<ProcessingWeightLine> _defaultWeightLines() {
    return List.generate(
      5,
      (i) => ProcessingWeightLine(
        id: 'WL-${i + 1}',
        productNameAndCategory: 'TMT Bars X 250 Bundles',
        estimatedLabel: '2400Kg',
      ),
    );
  }

  final List<ProcessingOrderItem> _orders = [
    ProcessingOrderItem(
      id: 'P-1',
      orderCode: 'Order #SS1033',
      status: 'In Progress',
      timeAgo: '12 mins ago',
      customerName: 'Ram Kishor Sharma',
      companyName: 'Vijay metals',
      itemsSummary: 'TMT Bars X 250 Bundles',
      weightLines: _defaultWeightLines(),
    ),
    ProcessingOrderItem(
      id: 'P-2',
      orderCode: 'Order #SS1033',
      status: 'In Progress',
      timeAgo: '12 mins ago',
      customerName: 'Ram Kishor Sharma',
      companyName: 'Vijay metals',
      itemsSummary: 'TMT Bars X 250 Bundles',
      weightLines: _defaultWeightLines(),
    ),
    ProcessingOrderItem(
      id: 'P-3',
      orderCode: 'Order #SS1033',
      status: 'In Progress',
      timeAgo: '12 mins ago',
      customerName: 'Ram Kishor Sharma',
      companyName: 'Vijay metals',
      itemsSummary: 'TMT Bars X 250 Bundles',
      weightLines: _defaultWeightLines(),
    ),
    ProcessingOrderItem(
      id: 'P-4',
      orderCode: 'Order #SS1033',
      status: 'Pending',
      timeAgo: '12 mins ago',
      customerName: 'Ram Kishor Sharma',
      companyName: 'Vijay metals',
      itemsSummary: 'TMT Bars X 250 Bundles',
      weightLines: _defaultWeightLines(),
    ),
    ProcessingOrderItem(
      id: 'P-5',
      orderCode: 'Order #SS1032',
      status: 'Pending',
      timeAgo: '12 mins ago',
      customerName: 'Ganesh Raj',
      companyName: 'Ganesh metal Co.',
      itemsSummary: 'TMT Bars X 250 Bundles',
      weightLines: _defaultWeightLines(),
    ),
    ProcessingOrderItem(
      id: 'P-6',
      orderCode: 'Order #SS1033',
      status: 'In Progress',
      timeAgo: '12 mins ago',
      customerName: 'Ram Kishor Sharma',
      companyName: 'Vijay metals',
      itemsSummary: 'TMT Bars X 250 Bundles',
      weightLines: _defaultWeightLines(),
    ),
    ProcessingOrderItem(
      id: 'P-7',
      orderCode: 'Order #SS1034',
      status: 'Pending',
      timeAgo: '18 mins ago',
      customerName: 'A. B. Sinha',
      companyName: 'A.B. Construction Pvt. Ltd',
      itemsSummary: 'TMT Bars X 250 Bundles',
      weightLines: _defaultWeightLines(),
    ),
    ProcessingOrderItem(
      id: 'P-8',
      orderCode: 'Order #SS1035',
      status: 'In Progress',
      timeAgo: '24 mins ago',
      customerName: 'Suresh Yadav',
      companyName: 'Patna Steel Traders',
      itemsSummary: 'TMT Bars X 250 Bundles',
      weightLines: _defaultWeightLines(),
    ),
  ];

  ProcessingOrderStatus get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isDetailView => _activeDetailOrderId != null;

  ProcessingOrderItem? get activeOrder {
    if (_activeDetailOrderId == null) return null;
    try {
      return _orders.firstWhere((o) => o.id == _activeDetailOrderId);
    } catch (_) {
      return _orders.first;
    }
  }

  List<ProcessingOrderItem> get _filteredOrders {
    final q = _searchQuery.trim().toLowerCase();
    return _orders.where((item) {
      final matchesStatus = switch (_selectedFilter) {
        ProcessingOrderStatus.all => true,
        ProcessingOrderStatus.pending =>
          item.status.toLowerCase() == 'pending',
        ProcessingOrderStatus.inProgress =>
          item.status.toLowerCase() == 'in progress',
      };
      final matchesQuery = q.isEmpty ||
          item.orderCode.toLowerCase().contains(q) ||
          item.customerName.toLowerCase().contains(q) ||
          item.companyName.toLowerCase().contains(q) ||
          item.itemsSummary.toLowerCase().contains(q);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  int get totalPages => (_filteredOrders.length / 6).ceil().clamp(1, 2);

  List<ProcessingOrderItem> get pagedOrders {
    final list = _filteredOrders;
    if (list.isEmpty) return const [];
    const perPage = 6;
    if (_currentPage > totalPages) _currentPage = 1;
    final start = (_currentPage - 1) * perPage;
    final end = (start + perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void setSidebarOpen(bool open) {
    _isSidebarOpen = open;
    notifyListeners();
  }

  void setFilter(ProcessingOrderStatus filter) {
    _selectedFilter = filter;
    _currentPage = 1;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page.clamp(1, totalPages);
    notifyListeners();
  }

  void nextPage() {
    _currentPage = _currentPage >= totalPages ? 1 : _currentPage + 1;
    notifyListeners();
  }

  void openOrderDetails(String orderId) {
    _activeDetailOrderId = orderId;
    notifyListeners();
  }

  void backToOrdersList() {
    _activeDetailOrderId = null;
    notifyListeners();
  }

  void submitMeasuredWeights({
    required String orderId,
    required List<String> weights,
    required List<String> notes,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final current = _orders[idx];
      final updatedLines = List.generate(current.weightLines.length, (i) {
        final w = i < weights.length ? weights[i].trim() : '';
        final n = i < notes.length ? notes[i].trim() : '';
        return current.weightLines[i].copyWith(
          exactWeightKg: w,
          notes: n,
        );
      });
      _orders[idx] = current.copyWith(
        status: 'In Progress',
        timeAgo: 'Just now',
        weightLines: updatedLines,
      );
    }
    _activeDetailOrderId = null;
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import '../models/sales_models.dart';

enum SalesPanelPage {
  storeDashboard('Store Dashboard'),
  customersDashboard('Customers dashboard'),
  inventoryManagement('Inventory Management'),
  orderInvoice('Order Invoice'),
  orderDetails('Order Details');

  final String label;
  const SalesPanelPage(this.label);
}

enum OrderFilterChip {
  all('All'),
  sentToProcessing('Sent to Processing'),
  readyForBilling('Ready for Billing');

  final String label;
  const OrderFilterChip(this.label);
}

class SalesDashboardProvider extends ChangeNotifier {
  SalesPanelPage _currentPage = SalesPanelPage.storeDashboard;
  OrderFilterChip _orderFilter = OrderFilterChip.all;
  bool _isSidebarOpen = false;

  String _customerSearch = '';
  String _orderSearch = '';
  int _customerPage = 1;
  int _orderPage = 1;

  int _todaysOrdersCount = 15;
  int _ordersInProcessingCount = 5;
  int _pendingEstimatesCount = 4;

  final List<SalesOrderRecord> _orders = List.generate(
    16,
    (index) {
      final statusCycle = [
        'In Processing',
        'Estimate Shared',
        'In Processing',
        'Ready for Billing',
      ];
      return SalesOrderRecord(
        id: 'ORD-${index + 1}',
        orderCode: 'Order #SS102',
        customerName: 'A. B. Construction Pvt. Ltd',
        contactPerson: index == 0 ? 'Abhay Sharma' : 'A. B. Sinha',
        phone: index == 0 ? '+91 9432809981' : '9999999999',
        gstin: index == 0 ? '2194714019249' : '1223094802759',
        itemsSummary: '12mm FE500D TMT Bar',
        orderDate: '12/05/2026',
        statusLabel: statusCycle[index % statusCycle.length],
        lineItems: const [
          SalesOrderItem(name: '12mm FE500D TMT Bar', qty: 1, rate: 55),
          SalesOrderItem(name: '22mm FE500D TMT Bar', qty: 1, rate: 55),
        ],
        gstAmount: 40,
      );
    },
  );

  final List<SalesCustomerRecord> _customers = List.generate(
    12,
    (index) => SalesCustomerRecord(
      id: 'CUS-${index + 1}',
      companyName: 'A.B. Construction Pvt. Ltd',
      contactPerson: 'A. B. Sinha',
      phone: '9999999999',
      gstin: '1223094802759',
    ),
  );

  final List<SalesInventoryDraftItem> _draftItems = [];
  late SalesOrderRecord _selectedInvoiceOrder;

  SalesDashboardProvider() {
    _selectedInvoiceOrder = _orders.first;
  }

  SalesPanelPage get currentPage => _currentPage;
  OrderFilterChip get orderFilter => _orderFilter;
  bool get isSidebarOpen => _isSidebarOpen;

  int get todaysOrdersCount => _todaysOrdersCount;
  int get ordersInProcessingCount => _ordersInProcessingCount;
  int get pendingEstimatesCount => _pendingEstimatesCount;

  List<SalesOrderRecord> get allOrders => List.unmodifiable(_orders);
  List<SalesCustomerRecord> get allCustomers => List.unmodifiable(_customers);
  List<SalesInventoryDraftItem> get draftItems => List.unmodifiable(_draftItems);
  SalesOrderRecord get selectedInvoiceOrder => _selectedInvoiceOrder;

  int get customerPage => _customerPage;
  int get orderPage => _orderPage;

  List<SalesCustomerRecord> get pagedCustomers {
    final q = _customerSearch.trim().toLowerCase();
    final filtered = q.isEmpty
        ? _customers
        : _customers
            .where((c) =>
                c.companyName.toLowerCase().contains(q) ||
                c.contactPerson.toLowerCase().contains(q) ||
                c.phone.toLowerCase().contains(q) ||
                c.gstin.toLowerCase().contains(q))
            .toList();

    const perPage = 9;
    final totalPages = (filtered.length / perPage).ceil().clamp(1, 99);
    if (_customerPage > totalPages) _customerPage = 1;
    final start = (_customerPage - 1) * perPage;
    final end = (start + perPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get totalCustomerPages {
    final q = _customerSearch.trim().toLowerCase();
    final count = q.isEmpty
        ? _customers.length
        : _customers
            .where((c) =>
                c.companyName.toLowerCase().contains(q) ||
                c.contactPerson.toLowerCase().contains(q))
            .length;
    return (count / 9).ceil().clamp(1, 99);
  }

  List<SalesOrderRecord> get pagedOrders {
    final q = _orderSearch.trim().toLowerCase();
    final filtered = _orders.where((o) {
      final matchesFilter = switch (_orderFilter) {
        OrderFilterChip.all => true,
        OrderFilterChip.sentToProcessing =>
          o.statusLabel.toLowerCase().contains('processing') ||
              o.statusLabel.toLowerCase().contains('estimate'),
        OrderFilterChip.readyForBilling =>
          o.statusLabel.toLowerCase().contains('billing'),
      };
      final matchesSearch = q.isEmpty ||
          o.orderCode.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.itemsSummary.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();

    const perPage = 12;
    final totalPages = (filtered.length / perPage).ceil().clamp(1, 99);
    if (_orderPage > totalPages) _orderPage = 1;
    final start = (_orderPage - 1) * perPage;
    final end = (start + perPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get totalOrderPages {
    final filteredCount = _orders.where((o) {
      switch (_orderFilter) {
        case OrderFilterChip.all:
          return true;
        case OrderFilterChip.sentToProcessing:
          return o.statusLabel.toLowerCase().contains('processing') ||
              o.statusLabel.toLowerCase().contains('estimate');
        case OrderFilterChip.readyForBilling:
          return o.statusLabel.toLowerCase().contains('billing');
      }
    }).length;
    return (filteredCount / 12).ceil().clamp(1, 99);
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void setSidebarOpen(bool open) {
    _isSidebarOpen = open;
    notifyListeners();
  }

  void openPage(SalesPanelPage page) {
    _currentPage = page;
    notifyListeners();
  }

  void setOrderFilter(OrderFilterChip chip) {
    _orderFilter = chip;
    _orderPage = 1;
    notifyListeners();
  }

  void setCustomerSearch(String query) {
    _customerSearch = query;
    _customerPage = 1;
    notifyListeners();
  }

  void setOrderSearch(String query) {
    _orderSearch = query;
    _orderPage = 1;
    notifyListeners();
  }

  void setCustomerPage(int page) {
    _customerPage = page.clamp(1, totalCustomerPages);
    notifyListeners();
  }

  void nextCustomerPage() {
    _customerPage =
        _customerPage >= totalCustomerPages ? 1 : _customerPage + 1;
    notifyListeners();
  }

  void setOrderPage(int page) {
    _orderPage = page.clamp(1, totalOrderPages);
    notifyListeners();
  }

  void nextOrderPage() {
    _orderPage = _orderPage >= totalOrderPages ? 1 : _orderPage + 1;
    notifyListeners();
  }

  void openInvoiceForOrder(SalesOrderRecord order) {
    _selectedInvoiceOrder = order;
    _currentPage = SalesPanelPage.orderInvoice;
    notifyListeners();
  }

  void addCustomer({
    required String companyName,
    required String contactPerson,
    required String phone,
    required String gstin,
  }) {
    _customers.insert(
      0,
      SalesCustomerRecord(
        id: 'CUS-${_customers.length + 1}',
        companyName:
            companyName.trim().isEmpty ? 'A.B. Construction Pvt. Ltd' : companyName.trim(),
        contactPerson:
            contactPerson.trim().isEmpty ? 'A. B. Sinha' : contactPerson.trim(),
        phone: phone.trim().isEmpty ? '9999999999' : phone.trim(),
        gstin: gstin.trim().isEmpty ? '1223094802759' : gstin.trim(),
      ),
    );
    _customerPage = 1;
    notifyListeners();
  }

  void addDraftInventoryItem(SalesInventoryDraftItem item) {
    _draftItems.add(item);
    notifyListeners();
  }

  void createOrderFromDraftAndOpenInvoice() {
    final items = _draftItems.isNotEmpty
        ? _draftItems
            .map(
              (d) => SalesOrderItem(
                name: d.displayName,
                qty: d.parsedQty,
                rate: d.parsedRate,
              ),
            )
            .toList()
        : _selectedInvoiceOrder.lineItems;

    final newOrder = SalesOrderRecord(
      id: 'ORD-${_orders.length + 1}',
      orderCode: 'Order #SS${103 + _orders.length}',
      customerName: 'A.B. Construction Pvt. Ltd',
      contactPerson: 'Abhay Sharma',
      phone: '+91 9432809981',
      gstin: '2194714019249',
      itemsSummary: items.first.name,
      orderDate: '12/05/2026',
      statusLabel: 'Estimate Shared',
      lineItems: items,
      gstAmount: 40,
    );

    _orders.insert(0, newOrder);
    _selectedInvoiceOrder = newOrder;
    _todaysOrdersCount += 1;
    _pendingEstimatesCount += 1;
    _draftItems.clear();
    _currentPage = SalesPanelPage.orderInvoice;
    notifyListeners();
  }

  void sendSelectedOrderToProcessing() {
    final idx = _orders.indexWhere((o) => o.id == _selectedInvoiceOrder.id);
    final updated = _selectedInvoiceOrder.copyWith(statusLabel: 'In Processing');
    if (idx != -1) {
      _orders[idx] = updated;
    }
    _selectedInvoiceOrder = updated;
    _ordersInProcessingCount += 1;
    _currentPage = SalesPanelPage.orderDetails;
    notifyListeners();
  }
}
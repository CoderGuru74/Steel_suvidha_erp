import 'package:flutter/foundation.dart';

enum DaybookSubPage {
  overview('Overview'),
  deletion('Daybook Deletion');

  final String label;
  const DaybookSubPage(this.label);
}

enum DaybookDangerAction {
  deleteDaybook('Delete Daybook'),
  clearDaybookHistory('Clear daybook History');

  final String buttonLabel;
  const DaybookDangerAction(this.buttonLabel);
}

class DaybookLineEntry {
  final String itemLabel;
  final String qtyLabel;

  const DaybookLineEntry({
    required this.itemLabel,
    required this.qtyLabel,
  });
}

class DaybookOrderEntry {
  final String id;
  final String companyName;
  final String orderCode;
  final String statusLabel;
  final List<DaybookLineEntry> lines;
  final String customerName;
  final String phone;
  final String referenceCode;
  final String amountLabel;
  final String timestampLabel;

  const DaybookOrderEntry({
    required this.id,
    required this.companyName,
    required this.orderCode,
    required this.statusLabel,
    required this.lines,
    required this.customerName,
    required this.phone,
    required this.referenceCode,
    required this.amountLabel,
    required this.timestampLabel,
  });
}

class DaybookManagementProvider extends ChangeNotifier {
  DaybookSubPage _currentPage = DaybookSubPage.overview;
  bool _isSidebarOpen = false;

  String _totalSalesFormatted = '₹2,45,938';
  int _ordersInItems = 35;
  int _ordersInTonns = 410;
  String _cashSalesTopFormatted = '₹ 45,938';
  String _cashSalesBottomFormatted = '₹ 2,00,000';

  String? _dateFrom;
  String? _dateTo;
  String? _deletionDateFrom;
  String? _deletionDateTo;
  String _searchQuery = '';

  final List<String> _availableDates = const [
    'Sep 21, 2026',
    'Sep 20, 2026',
    'Sep 19, 2026',
    'Sep 18, 2026',
  ];

  final List<DaybookOrderEntry> _orders = [
    const DaybookOrderEntry(
      id: 'DB-1',
      companyName: 'Vijay Metals',
      orderCode: '#S51030',
      statusLabel: 'Paid/Billed',
      lines: [
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
      ],
      customerName: 'Vijay Raj',
      phone: '+91 7223945264',
      referenceCode: '1232481698147',
      amountLabel: '₹ 1259.55',
      timestampLabel: 'September 21,2026 | 12:34',
    ),
    const DaybookOrderEntry(
      id: 'DB-2',
      companyName: 'Vijay Metals',
      orderCode: '#S51030',
      statusLabel: 'Paid/Billed',
      lines: [
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
      ],
      customerName: 'Vijay Raj',
      phone: '+91 7223945264',
      referenceCode: '1232481698147',
      amountLabel: '₹ 1259.55',
      timestampLabel: 'September 21,2026 | 12:34',
    ),
    const DaybookOrderEntry(
      id: 'DB-3',
      companyName: 'Vijay Metals',
      orderCode: '#S51030',
      statusLabel: 'Paid/Billed',
      lines: [
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
      ],
      customerName: 'Vijay Raj',
      phone: '+91 7223945264',
      referenceCode: '1232481698147',
      amountLabel: '₹ 1259.55',
      timestampLabel: 'September 21,2026 | 12:34',
    ),
    const DaybookOrderEntry(
      id: 'DB-4',
      companyName: 'Ganesh Metal Co.',
      orderCode: '#S51031',
      statusLabel: 'Paid/Billed',
      lines: [
        DaybookLineEntry(itemLabel: 'TMT 16FE500D', qtyLabel: '20pcs'),
        DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '15pcs'),
        DaybookLineEntry(itemLabel: 'TMT 10FE500D', qtyLabel: '10pcs'),
      ],
      customerName: 'Ganesh Raj',
      phone: '+91 9835011223',
      referenceCode: '1232481698188',
      amountLabel: '₹ 4820.00',
      timestampLabel: 'September 21,2026 | 13:10',
    ),
  ];

  DaybookSubPage get currentPage => _currentPage;
  bool get isSidebarOpen => _isSidebarOpen;
  String get totalSalesFormatted => _totalSalesFormatted;
  int get ordersInItems => _ordersInItems;
  int get ordersInTonns => _ordersInTonns;
  String get cashSalesTopFormatted => _cashSalesTopFormatted;
  String get cashSalesBottomFormatted => _cashSalesBottomFormatted;
  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;
  String? get deletionDateFrom => _deletionDateFrom;
  String? get deletionDateTo => _deletionDateTo;
  String get searchQuery => _searchQuery;
  List<String> get availableDates => _availableDates;

  List<DaybookOrderEntry> get filteredOrders {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _orders;
    return _orders.where((o) {
      return o.companyName.toLowerCase().contains(q) ||
          o.orderCode.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.phone.toLowerCase().contains(q) ||
          o.referenceCode.toLowerCase().contains(q) ||
          o.lines.any((l) => l.itemLabel.toLowerCase().contains(q));
    }).toList();
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void setSidebarOpen(bool open) {
    _isSidebarOpen = open;
    notifyListeners();
  }

  void openPage(DaybookSubPage page) {
    _currentPage = page;
    notifyListeners();
  }

  void setDateFrom(String? value) {
    _dateFrom = value;
    notifyListeners();
  }

  void setDateTo(String? value) {
    _dateTo = value;
    notifyListeners();
  }

  void setDeletionDateFrom(String? value) {
    _deletionDateFrom = value;
    notifyListeners();
  }

  void setDeletionDateTo(String? value) {
    _deletionDateTo = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool confirmDangerAction({
    required DaybookDangerAction action,
    required String password,
  }) {
    if (password.trim().isEmpty) return false;

    if (action == DaybookDangerAction.deleteDaybook) {
      if (_orders.isNotEmpty) {
        _orders.removeAt(0);
      }
      _ordersInItems = (_ordersInItems - 1).clamp(0, 999999);
    } else if (action == DaybookDangerAction.clearDaybookHistory) {
      _orders.clear();
      _totalSalesFormatted = '₹0';
      _ordersInItems = 0;
      _ordersInTonns = 0;
      _cashSalesTopFormatted = '₹ 0';
      _cashSalesBottomFormatted = '₹ 0';
    }

    notifyListeners();
    return true;
  }
}
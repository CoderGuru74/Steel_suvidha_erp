import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';

enum _DaybookSubPage {
  overview('Overview'),
  deletion('Daybook Deletion');

  final String label;
  const _DaybookSubPage(this.label);
}

enum _DaybookDangerAction {
  deleteDaybook('Delete Daybook'),
  clearDaybookHistory('Clear daybook History');

  final String buttonLabel;
  const _DaybookDangerAction(this.buttonLabel);
}

class _DaybookLineEntry {
  final String itemLabel;
  final String qtyLabel;

  const _DaybookLineEntry({
    required this.itemLabel,
    required this.qtyLabel,
  });
}

class _DaybookOrderEntry {
  final String id;
  final String companyName;
  final String orderCode;
  final String statusLabel;
  final List<_DaybookLineEntry> lines;
  final String customerName;
  final String phone;
  final String referenceCode;
  final String amountLabel;
  final String timestampLabel;

  const _DaybookOrderEntry({
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

class _DaybookController extends ChangeNotifier {
  _DaybookSubPage _currentPage = _DaybookSubPage.overview;
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

  final List<_DaybookOrderEntry> _orders = [
    const _DaybookOrderEntry(
      id: 'DB-1',
      companyName: 'Vijay Metals',
      orderCode: '#S51030',
      statusLabel: 'Paid/Billed',
      lines: [
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
      ],
      customerName: 'Vijay Raj',
      phone: '+91 7223945264',
      referenceCode: '1232481698147',
      amountLabel: '₹ 1259.55',
      timestampLabel: 'September 21,2026 | 12:34',
    ),
    const _DaybookOrderEntry(
      id: 'DB-2',
      companyName: 'Vijay Metals',
      orderCode: '#S51030',
      statusLabel: 'Paid/Billed',
      lines: [
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
      ],
      customerName: 'Vijay Raj',
      phone: '+91 7223945264',
      referenceCode: '1232481698147',
      amountLabel: '₹ 1259.55',
      timestampLabel: 'September 21,2026 | 12:34',
    ),
    const _DaybookOrderEntry(
      id: 'DB-3',
      companyName: 'Vijay Metals',
      orderCode: '#S51030',
      statusLabel: 'Paid/Billed',
      lines: [
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '12pcs'),
      ],
      customerName: 'Vijay Raj',
      phone: '+91 7223945264',
      referenceCode: '1232481698147',
      amountLabel: '₹ 1259.55',
      timestampLabel: 'September 21,2026 | 12:34',
    ),
    const _DaybookOrderEntry(
      id: 'DB-4',
      companyName: 'Ganesh Metal Co.',
      orderCode: '#S51031',
      statusLabel: 'Paid/Billed',
      lines: [
        _DaybookLineEntry(itemLabel: 'TMT 16FE500D', qtyLabel: '20pcs'),
        _DaybookLineEntry(itemLabel: 'TMT 12FE500D', qtyLabel: '15pcs'),
        _DaybookLineEntry(itemLabel: 'TMT 10FE500D', qtyLabel: '10pcs'),
      ],
      customerName: 'Ganesh Raj',
      phone: '+91 9835011223',
      referenceCode: '1232481698188',
      amountLabel: '₹ 4820.00',
      timestampLabel: 'September 21,2026 | 13:10',
    ),
  ];

  _DaybookSubPage get currentPage => _currentPage;
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
  List<String> get availableDates => _availableDates;

  List<_DaybookOrderEntry> get filteredOrders {
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

  void openPage(_DaybookSubPage page) {
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
    required _DaybookDangerAction action,
    required String password,
  }) {
    if (password.trim().isEmpty) return false;

    if (action == _DaybookDangerAction.deleteDaybook) {
      if (_orders.isNotEmpty) {
        _orders.removeAt(0);
      }
      _ordersInItems = (_ordersInItems - 1).clamp(0, 999999);
    } else if (action == _DaybookDangerAction.clearDaybookHistory) {
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

class DaybookManagementDashboard extends DaybookDashboard {
  const DaybookManagementDashboard({
    super.key,
    super.title = 'Daybook Management',
  });
}

class DaybookDashboard extends StatelessWidget {
  final String title;

  const DaybookDashboard({super.key, this.title = 'Daybook Management'});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _DaybookController(),
      child: const _DaybookDashboardScaffold(),
    );
  }
}

class _DaybookDashboardScaffold extends StatelessWidget {
  const _DaybookDashboardScaffold();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<_DaybookController>();
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPad = controller.isSidebarOpen && !isMobile
                ? 20.0
                : (isMobile ? 12.0 : 58.0);
            final availHeight =
                (constraints.maxHeight - 28).clamp(460.0, 1200.0);

            return Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (controller.isSidebarOpen && !isMobile)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                        child: _DaybookBlackSidebar(
                          currentPage: controller.currentPage,
                          onSelectPage: (page) {
                            controller.openPage(page);
                            controller.setSidebarOpen(false);
                          },
                          onClose: () => controller.setSidebarOpen(false),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPad,
                          12,
                          isMobile ? 12 : 24,
                          14,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: availHeight),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _DaybookTopHeader(
                                showLogo: !controller.isSidebarOpen,
                                onTitleTap: () => controller
                                    .openPage(_DaybookSubPage.overview),
                              ),
                              const SizedBox(height: 12),
                              if (controller.currentPage ==
                                  _DaybookSubPage.overview)
                                _DaybookOverviewBody(
                                  controller: controller,
                                  isMobile: isMobile,
                                  bodyHeight:
                                      (availHeight - 74).clamp(400.0, 760.0),
                                )
                              else
                                _DaybookDeletionBody(
                                  controller: controller,
                                  isMobile: isMobile,
                                  bodyHeight:
                                      (availHeight - 74).clamp(360.0, 680.0),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Top-left Black Hamburger Button
                if (!controller.isSidebarOpen)
                  Positioned(
                    top: 12,
                    left: 0,
                    child: Material(
                      color: Colors.black,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        onTap: controller.toggleSidebar,
                        child: const SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Mobile Drawer
                if (controller.isSidebarOpen && isMobile)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => controller.setSidebarOpen(false),
                      child: Container(
                        color: Colors.black54,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () {},
                          child: _DaybookBlackSidebar(
                            currentPage: controller.currentPage,
                            onSelectPage: (page) {
                              controller.openPage(page);
                              controller.setSidebarOpen(false);
                            },
                            onClose: () => controller.setSidebarOpen(false),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DaybookTopHeader extends StatelessWidget {
  final bool showLogo;
  final VoidCallback onTitleTap;

  const _DaybookTopHeader({
    required this.showLogo,
    required this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTitleTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daybook Management',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6BA3D6),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 25,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(
                      text: 'Welcome back, ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: 'Rupesh!',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showLogo)
          Image.asset(
            'assets/images/logo.png',
            height: 46,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'Steel suvidha',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class _DaybookBlackSidebar extends StatelessWidget {
  final _DaybookSubPage currentPage;
  final ValueChanged<_DaybookSubPage> onSelectPage;
  final VoidCallback onClose;

  const _DaybookBlackSidebar({
    required this.currentPage,
    required this.onSelectPage,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'Steel suvidha',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (final p in _DaybookSubPage.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () => onSelectPage(p),
                child: Row(
                  children: [
                    Icon(
                      p == _DaybookSubPage.overview
                          ? Icons.menu_book_outlined
                          : Icons.delete_sweep_outlined,
                      size: 18,
                      color: currentPage == p
                          ? const Color(0xFF60A5FA)
                          : Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: currentPage == p
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: currentPage == p
                              ? const Color(0xFF60A5FA)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          InkWell(
            onTap: () => context.go('/workspace'),
            child: const Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                SizedBox(width: 12),
                Text(
                  'Switch Panel',
                  style: TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 1. DAYBOOK OVERVIEW
/// ---------------------------------------------------------------------------
class _DaybookOverviewBody extends StatelessWidget {
  final _DaybookController controller;
  final bool isMobile;
  final double bodyHeight;

  const _DaybookOverviewBody({
    required this.controller,
    required this.isMobile,
    required this.bodyHeight,
  });

  void _triggerAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _topKpiCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: _daybookCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cashKpiCard({
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: _daybookCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Today’s Sales\n(in Cash)',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportActionButton({
    required Widget leading,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: _daybookCardDecoration(radius: 14),
        child: Row(
          children: [
            SizedBox(width: 24, child: Center(child: leading)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = controller.filteredOrders;

    final topRowKpis = Row(
      children: [
        Expanded(
          child: _topKpiCard(
            title: 'Today’s\nTotal Sales',
            value: controller.totalSalesFormatted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _topKpiCard(
            title: 'Today’s Orders\n(in items)',
            value: '${controller.ordersInItems}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _topKpiCard(
            title: 'Today’s Orders\n(in tonns)',
            value: '${controller.ordersInTonns}',
          ),
        ),
      ],
    );

    final lowerLeftExports = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DateSelectField(
          label: 'Date From',
          value: controller.dateFrom,
          items: controller.availableDates,
          onChanged: controller.setDateFrom,
        ),
        const SizedBox(height: 8),
        _DateSelectField(
          label: 'Date To',
          value: controller.dateTo,
          items: controller.availableDates,
          onChanged: controller.setDateTo,
        ),
        const SizedBox(height: 12),
        _exportActionButton(
          leading: const Icon(
            Icons.print_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
          label: 'Print Daybook',
          onTap: () => _triggerAction(context, 'Printing Daybook report...'),
        ),
        const SizedBox(height: 8),
        _exportActionButton(
          leading: const Icon(
            Icons.storage_rounded,
            size: 20,
            color: Color(0xFF2563EB),
          ),
          label: 'Export to External DB',
          onTap: () =>
              _triggerAction(context, 'Exporting Daybook to External DB...'),
        ),
        const SizedBox(height: 8),
        _exportActionButton(
          leading: const Icon(
            Icons.picture_as_pdf_rounded,
            size: 20,
            color: Color(0xFFDC2626),
          ),
          label: 'Export in .PDF',
          onTap: () => _triggerAction(context, 'Exporting Daybook as .PDF...'),
        ),
        const SizedBox(height: 8),
        _exportActionButton(
          leading: const Icon(
            Icons.table_chart_rounded,
            size: 20,
            color: Color(0xFF15803D),
          ),
          label: 'Export in .xlsx',
          onTap: () => _triggerAction(context, 'Exporting Daybook as .xlsx...'),
        ),
      ],
    );

    final lowerMiddleCashAndDelete = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cashKpiCard(value: controller.cashSalesTopFormatted),
        const SizedBox(height: 10),
        _cashKpiCard(value: controller.cashSalesBottomFormatted),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => controller.openPage(_DaybookSubPage.deletion),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 76,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: const Text(
              'Daybook\ndeletion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );

    final rightOrdersColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 36,
          child: TextField(
            onChanged: controller.setSearchQuery,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 17,
                color: Color(0xFF94A3B8),
              ),
              hintText: 'Search orders',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2B88C6)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: _daybookCardDecoration(),
            child: const Center(
              child: Text(
                'No daybook orders found.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          for (int i = 0; i < orders.take(3).length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _DaybookOrderSummaryCard(order: orders[i]),
          ],
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          topRowKpis,
          const SizedBox(height: 14),
          lowerLeftExports,
          const SizedBox(height: 14),
          lowerMiddleCashAndDelete,
          const SizedBox(height: 14),
          rightOrdersColumn,
        ],
      );
    }

    return SizedBox(
      height: bodyHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 64,
            child: Column(
              children: [
                topRowKpis,
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 52, child: lowerLeftExports),
                    const SizedBox(width: 12),
                    Expanded(flex: 48, child: lowerMiddleCashAndDelete),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            flex: 36,
            child: rightOrdersColumn,
          ),
        ],
      ),
    );
  }
}

class _DaybookOrderSummaryCard extends StatelessWidget {
  final _DaybookOrderEntry order;

  const _DaybookOrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _daybookCardDecoration(radius: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(width: 5, height: 124, color: const Color(0xFF2B88C6)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.companyName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          order.orderCode,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBBF7D0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.statusLabel,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final line in order.lines)
                              Text(
                                '${line.itemLabel}    ${line.qtyLabel}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              order.phone,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              order.referenceCode,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              order.amountLabel,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.timestampLabel,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 2. DAYBOOK DELETION & DANGER ZONE + MODAL
/// ---------------------------------------------------------------------------
class _DaybookDeletionBody extends StatelessWidget {
  final _DaybookController controller;
  final bool isMobile;
  final double bodyHeight;

  const _DaybookDeletionBody({
    required this.controller,
    required this.isMobile,
    required this.bodyHeight,
  });

  void _openConfirmDialog(BuildContext context, _DaybookDangerAction action) {
    final passwordCtrl = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 390,
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Are you Sure want to do this ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This will permanently wipe chosen data !\nEnter admin password to confirm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      hintText: 'Enter Password :',
                      hintStyle: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                      errorText: errorText,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF93C5FD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2B88C6)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: () {
                            final ok = controller.confirmDangerAction(
                              action: action,
                              password: passwordCtrl.text,
                            );
                            if (!ok) {
                              setModalState(() {
                                errorText = 'Please enter admin password';
                              });
                              return;
                            }
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${action.buttonLabel} completed.'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDF3B47),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B88C6),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deletionCard = Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
      decoration: _daybookCardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Daybook Deletion',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _DateSelectField(
            label: 'Date From',
            value: controller.deletionDateFrom,
            items: controller.availableDates,
            onChanged: controller.setDeletionDateFrom,
          ),
          const SizedBox(height: 14),
          _DateSelectField(
            label: 'Date To',
            value: controller.deletionDateTo,
            items: controller.availableDates,
            onChanged: controller.setDeletionDateTo,
          ),
        ],
      ),
    );

    final dangerZoneCard = Container(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 26),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_rounded,
                color: Color(0xFFFACC15),
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'DANGER ZONE',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          for (int i = 0; i < _DaybookDangerAction.values.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () =>
                    _openConfirmDialog(context, _DaybookDangerAction.values[i]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDF3B47),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _DaybookDangerAction.values[i].buttonLabel,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          deletionCard,
          const SizedBox(height: 18),
          dangerZoneCard,
        ],
      );
    }

    return SizedBox(
      height: bodyHeight,
      child: Padding(
        padding: const EdgeInsets.only(top: 42, left: 32, right: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 46, child: deletionCard),
            const SizedBox(width: 48),
            Expanded(flex: 50, child: dangerZoneCard),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// SHARED DAYBOOK WIDGETS
/// ---------------------------------------------------------------------------
BoxDecoration _daybookCardDecoration({double radius = 16}) {
  return BoxDecoration(
    color: const Color(0xFFFAFAFA),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

class _DateSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DateSelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF93C5FD)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: Colors.black87,
              ),
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textPrimary,
              ),
              items: items
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
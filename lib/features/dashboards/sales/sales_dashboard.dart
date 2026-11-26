import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'models/sales_models.dart';
import 'providers/sales_dashboard_provider.dart';

class SalesPanelDashboard extends SalesDashboard {
  const SalesPanelDashboard({super.key, super.title = 'Sales Panel'});
}

class SalesDashboard extends StatelessWidget {
  final String title;

  const SalesDashboard({super.key, this.title = 'Sales'});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesDashboardProvider(),
      child: const _SalesDashboardScaffold(),
    );
  }
}

class _SalesDashboardScaffold extends StatelessWidget {
  const _SalesDashboardScaffold();

  String _headerTopTitle(SalesPanelPage page) {
    return page == SalesPanelPage.inventoryManagement
        ? 'Inventory Management'
        : 'Store Dashboard';
  }

  String _headerMainTitle(SalesPanelPage page) {
    switch (page) {
      case SalesPanelPage.storeDashboard:
      case SalesPanelPage.inventoryManagement:
        return 'Welcome back, Rupesh!';
      case SalesPanelPage.customersDashboard:
        return 'Customers dashboard';
      case SalesPanelPage.orderInvoice:
        return 'Order Invoice';
      case SalesPanelPage.orderDetails:
        return 'Order Details';
    }
  }

  bool _isMainTitleGreeting(SalesPanelPage page) {
    return page == SalesPanelPage.storeDashboard ||
        page == SalesPanelPage.inventoryManagement;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesDashboardProvider>();
    final bool isMobile = Responsive.isMobile(context);
    final page = provider.currentPage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPad = provider.isSidebarOpen && !isMobile
                ? 20.0
                : (isMobile ? 14.0 : 58.0);

            return Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (provider.isSidebarOpen && !isMobile)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                        child: _SalesBlackSidebar(
                          currentPage: page,
                          onSelectPage: provider.openPage,
                          onClose: () => provider.setSidebarOpen(false),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPad,
                          14,
                          isMobile ? 14 : 26,
                          18,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _SalesTopHeader(
                                    topLabel: _headerTopTitle(page),
                                    mainLabel: _headerMainTitle(page),
                                    isGreeting: _isMainTitleGreeting(page),
                                    showLogo: page != SalesPanelPage.orderInvoice &&
                                        !provider.isSidebarOpen,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildPageBody(
                                    context,
                                    provider,
                                    isMobile,
                                    constraints.maxHeight,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Top-left Black Hamburger Button
                if (!provider.isSidebarOpen)
                  Positioned(
                    top: 14,
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
                        onTap: provider.toggleSidebar,
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
                if (provider.isSidebarOpen && isMobile)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => provider.setSidebarOpen(false),
                      child: Container(
                        color: Colors.black54,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () {},
                          child: _SalesBlackSidebar(
                            currentPage: page,
                            onSelectPage: (p) {
                              provider.openPage(p);
                              provider.setSidebarOpen(false);
                            },
                            onClose: () => provider.setSidebarOpen(false),
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

  Widget _buildPageBody(
    BuildContext context,
    SalesDashboardProvider provider,
    bool isMobile,
    double viewportHeight,
  ) {
    switch (provider.currentPage) {
      case SalesPanelPage.storeDashboard:
        return _StoreDashboardView(
          provider: provider,
          isMobile: isMobile,
          viewportHeight: viewportHeight,
        );
      case SalesPanelPage.customersDashboard:
        return _CustomersDashboardView(
          provider: provider,
          isMobile: isMobile,
        );
      case SalesPanelPage.inventoryManagement:
        return _InventoryManagementView(
          provider: provider,
          isMobile: isMobile,
          viewportHeight: viewportHeight,
        );
      case SalesPanelPage.orderInvoice:
        return _OrderInvoiceView(
          provider: provider,
          isMobile: isMobile,
          viewportHeight: viewportHeight,
        );
      case SalesPanelPage.orderDetails:
        return _OrderDetailsView(
          provider: provider,
          isMobile: isMobile,
        );
    }
  }
}

class _SalesTopHeader extends StatelessWidget {
  final String topLabel;
  final String mainLabel;
  final bool isGreeting;
  final bool showLogo;

  const _SalesTopHeader({
    required this.topLabel,
    required this.mainLabel,
    required this.isGreeting,
    required this.showLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topLabel,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6BA3D6),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 2),
            if (!isGreeting)
              Text(
                mainLabel,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              )
            else
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

class _SalesBlackSidebar extends StatelessWidget {
  final SalesPanelPage currentPage;
  final ValueChanged<SalesPanelPage> onSelectPage;
  final VoidCallback onClose;

  const _SalesBlackSidebar({
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
          for (final p in SalesPanelPage.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () => onSelectPage(p),
                child: Row(
                  children: [
                    Icon(
                      _iconForPage(p),
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

  IconData _iconForPage(SalesPanelPage page) {
    switch (page) {
      case SalesPanelPage.storeDashboard:
        return Icons.storefront_outlined;
      case SalesPanelPage.customersDashboard:
        return Icons.groups_2_outlined;
      case SalesPanelPage.inventoryManagement:
        return Icons.inventory_2_outlined;
      case SalesPanelPage.orderInvoice:
        return Icons.receipt_long_outlined;
      case SalesPanelPage.orderDetails:
        return Icons.list_alt_rounded;
    }
  }
}

/// ---------------------------------------------------------------------------
/// 1. STORE DASHBOARD
/// ---------------------------------------------------------------------------
class _StoreDashboardView extends StatelessWidget {
  final SalesDashboardProvider provider;
  final bool isMobile;
  final double viewportHeight;

  const _StoreDashboardView({
    required this.provider,
    required this.isMobile,
    required this.viewportHeight,
  });

  void _showAddCustomerDialog(BuildContext context) {
    final companyCtrl = TextEditingController(text: 'A.B. Construction Pvt. Ltd');
    final contactCtrl = TextEditingController(text: 'A. B. Sinha');
    final phoneCtrl = TextEditingController(text: '9999999999');
    final gstinCtrl = TextEditingController(text: '1223094802759');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add New Customer',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contactCtrl,
                decoration: const InputDecoration(labelText: 'Contact Person'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: gstinCtrl,
                decoration: const InputDecoration(labelText: 'GSTIN'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B88C6),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.addCustomer(
                companyName: companyCtrl.text,
                contactPerson: contactCtrl.text,
                phone: phoneCtrl.text,
                gstin: gstinCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Customer'),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: _elevatedCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentOrders = provider.allOrders.take(4).toList();
    final recentCustomers = provider.allCustomers.take(3).toList();
    final sectionHeight = (viewportHeight - 125).clamp(430.0, 660.0);

    final leftKpiCol = SizedBox(
      height: isMobile ? null : sectionHeight,
      child: Column(
        children: [
          Expanded(
            child: _kpiCard(
              title: "Today's orders",
              count: provider.todaysOrdersCount,
              onTap: () => provider.openPage(SalesPanelPage.orderDetails),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _kpiCard(
              title: 'Orders in Processing',
              count: provider.ordersInProcessingCount,
              onTap: () => provider.openPage(SalesPanelPage.orderDetails),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _kpiCard(
              title: 'Pending Estimates',
              count: provider.pendingEstimatesCount,
              onTap: () => provider.openPage(SalesPanelPage.orderInvoice),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () =>
                  provider.openPage(SalesPanelPage.inventoryManagement),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Create New Order',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B88C6),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final middleOrdersCol = SizedBox(
      height: isMobile ? null : sectionHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current orders',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < currentOrders.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _BlueAccentOrderCard(
                order: currentOrders[i],
                onTap: () => provider.openInvoiceForOrder(currentOrders[i]),
              ),
            ),
          ],
        ],
      ),
    );

    final rightCustomersCol = SizedBox(
      height: isMobile ? null : sectionHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Customers',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < recentCustomers.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _BlueAccentCustomerCard(
                customer: recentCustomers[i],
                onTap: () =>
                    provider.openPage(SalesPanelPage.customersDashboard),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _showAddCustomerDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Add New Customer',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B88C6),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          leftKpiCol,
          const SizedBox(height: 16),
          middleOrdersCol,
          const SizedBox(height: 16),
          rightCustomersCol,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 25, child: leftKpiCol),
        const SizedBox(width: 14),
        Expanded(flex: 39, child: middleOrdersCol),
        const SizedBox(width: 14),
        Expanded(flex: 36, child: rightCustomersCol),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 2. CUSTOMERS DASHBOARD
/// ---------------------------------------------------------------------------
class _CustomersDashboardView extends StatelessWidget {
  final SalesDashboardProvider provider;
  final bool isMobile;

  const _CustomersDashboardView({
    required this.provider,
    required this.isMobile,
  });

  void _openAddCustomerModal(BuildContext context) {
    final companyCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '+ Add Customer',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: companyCtrl,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contactCtrl,
              decoration: const InputDecoration(labelText: 'Contact Person'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: gstinCtrl,
              decoration: const InputDecoration(labelText: 'GSTIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDF3B47),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.addCustomer(
                companyName: companyCtrl.text,
                contactPerson: contactCtrl.text,
                phone: phoneCtrl.text,
                gstin: gstinCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = provider.pagedCustomers;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: () => _openAddCustomerModal(context),
                icon: const Icon(Icons.add, size: 15),
                label: const Text(
                  'Add Customer',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDF3B47),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: isMobile ? 165 : 220,
              height: 36,
              child: TextField(
                onChanged: provider.setCustomerSearch,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                  hintText: 'Search Customers',
                  hintStyle: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF2B88C6)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: isMobile ? 2.8 : 2.55,
          ),
          itemBuilder: (context, idx) => _BlueAccentCustomerCard(
            customer: items[idx],
            onTap: () => provider.openPage(SalesPanelPage.orderInvoice),
          ),
        ),
        const SizedBox(height: 14),
        _PaginationFooter(
          currentPage: provider.customerPage,
          totalPages: provider.totalCustomerPages,
          onSelectPage: provider.setCustomerPage,
          onNext: provider.nextCustomerPage,
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 3. INVENTORY MANAGEMENT
/// ---------------------------------------------------------------------------
class _InventoryManagementView extends StatefulWidget {
  final SalesDashboardProvider provider;
  final bool isMobile;
  final double viewportHeight;

  const _InventoryManagementView({
    required this.provider,
    required this.isMobile,
    required this.viewportHeight,
  });

  @override
  State<_InventoryManagementView> createState() =>
      _InventoryManagementViewState();
}

class _InventoryManagementViewState extends State<_InventoryManagementView> {
  String? _productType;
  String? _brand;
  String? _specification;
  String? _grade;

  final _lengthCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _weightPrefixCtrl = TextEditingController();
  final _actualWeightCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _quantityCtrl.dispose();
    _weightPrefixCtrl.dispose();
    _actualWeightCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    super.dispose();
  }

  void _handleAddItem() {
    widget.provider.addDraftInventoryItem(
      SalesInventoryDraftItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productType: _productType ?? 'TMT Bar',
        brand: _brand ?? 'Tata Tiscon',
        specification: _specification ?? '12mm',
        grade: _grade ?? 'FE500D',
        length:
            _lengthCtrl.text.trim().isEmpty ? '12m' : _lengthCtrl.text.trim(),
        quantity:
            _quantityCtrl.text.trim().isEmpty ? '1' : _quantityCtrl.text.trim(),
        weightPrefix: _weightPrefixCtrl.text.trim(),
        actualWeight: _actualWeightCtrl.text.trim(),
        purchasePrice: _purchasePriceCtrl.text.trim(),
        sellingPrice: _sellingPriceCtrl.text.trim().isEmpty
            ? '55'
            : _sellingPriceCtrl.text.trim(),
      ),
    );
    _lengthCtrl.clear();
    _quantityCtrl.clear();
    _weightPrefixCtrl.clear();
    _actualWeightCtrl.clear();
    _purchasePriceCtrl.clear();
    _sellingPriceCtrl.clear();
  }

  Widget _dropdownBox({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: Colors.black87,
          ),
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _miniField(TextEditingController ctrl, {bool showArrows = false}) {
    return SizedBox(
      height: 28,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          suffixIcon: showArrows
              ? const Icon(
                  Icons.unfold_more_rounded,
                  size: 13,
                  color: Colors.black54,
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 18, minHeight: 24),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF93C5FD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF2563EB)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drafts = widget.provider.draftItems;
    final cardMinHeight = (widget.viewportHeight - 190).clamp(320.0, 520.0);

    final labels = const [
      'Product Type',
      'Brand',
      'Specification',
      'Grade',
      'Lenght',
      'Quantity',
      'Weight Pre-fixed',
      'Actual Weight',
      'Purchase Price',
      'Selling Price',
    ];

    final inputs = [
      _dropdownBox(
        value: _productType,
        items: const ['TMT Bar', 'Angle', 'Channel', 'Plate'],
        onChanged: (v) => setState(() => _productType = v),
      ),
      _dropdownBox(
        value: _brand,
        items: const ['Tata Tiscon', 'JSW Steel', 'SAIL', 'Shyam'],
        onChanged: (v) => setState(() => _brand = v),
      ),
      _dropdownBox(
        value: _specification,
        items: const ['8mm', '10mm', '12mm', '16mm', '22mm'],
        onChanged: (v) => setState(() => _specification = v),
      ),
      _dropdownBox(
        value: _grade,
        items: const ['FE500', 'FE500D', 'FE550D'],
        onChanged: (v) => setState(() => _grade = v),
      ),
      _miniField(_lengthCtrl),
      _miniField(_quantityCtrl, showArrows: true),
      _miniField(_weightPrefixCtrl),
      _miniField(_actualWeightCtrl),
      _miniField(_purchasePriceCtrl, showArrows: true),
      _miniField(_sellingPriceCtrl, showArrows: true),
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: cardMinHeight),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
          decoration: _elevatedCardDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!widget.isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < labels.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            inputs[i],
                          ],
                        ),
                      ),
                    ],
                  ],
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < labels.length; i++)
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              labels[i],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            inputs[i],
                          ],
                        ),
                      ),
                  ],
                ),
              if (drafts.isNotEmpty) ...[
                const SizedBox(height: 16),
                for (final item in drafts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.displayName}  •  Qty: ${item.parsedQty}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Rate: ₹${item.parsedRate}  |  ₹${item.parsedQty * item.parsedRate}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2B88C6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: 118,
                height: 36,
                child: ElevatedButton(
                  onPressed: _handleAddItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDF3B47),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Add Item',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 220,
          height: 36,
          child: ElevatedButton(
            onPressed: widget.provider.createOrderFromDraftAndOpenInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B88C6),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View Estimate',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 4. ORDER INVOICE
/// ---------------------------------------------------------------------------
class _OrderInvoiceView extends StatelessWidget {
  final SalesDashboardProvider provider;
  final bool isMobile;
  final double viewportHeight;

  const _OrderInvoiceView({
    required this.provider,
    required this.isMobile,
    required this.viewportHeight,
  });

  @override
  Widget build(BuildContext context) {
    final order = provider.selectedInvoiceOrder;

    final leftActionColumn = Column(
      children: [
        const SizedBox(height: 120),
        SizedBox(
          width: isMobile ? double.infinity : 250,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invoice sent to printer.')),
            ),
            icon: const Icon(
              Icons.print_outlined,
              size: 16,
              color: Color(0xFF2B88C6),
            ),
            label: const Text(
              'Print Invoice',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B88C6),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF60A5FA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: isMobile ? double.infinity : 250,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Shared ${order.orderCode} invoice.')),
            ),
            icon: const Icon(Icons.ios_share_rounded, size: 16),
            label: const Text(
              'Share',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B88C6),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: isMobile ? double.infinity : 250,
          height: 40,
          child: ElevatedButton(
            onPressed: provider.sendSelectedOrderToProcessing,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDF3B47),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Send to Processing Team',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );

    final rightInvoiceSheet = Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: (viewportHeight - 105).clamp(440.0, 680.0),
      ),
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Store:',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Shree Ram Steel',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Shree Ram Sharma',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Phone : 8234813590',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'GSTIN : 239240975209',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 46,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Steel suvidha',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Customer :',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                order.contactPerson,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Phone : ${order.phone}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'GSTIN : ${order.gstin}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFF2B88C6),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        'Item',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Qty.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Rate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Amount',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (final line in order.lineItems) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          line.name,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${line.qty}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹ ${line.rate}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹ ${line.amount}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 170,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sub-total',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹ ${order.subTotal}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'GST',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹ ${order.gstAmount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: const Color(0xFFBDBDBD),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'TOTAL AMOUNT    ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '₹ ${order.totalAmount}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disclaimer :',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'The weights shown on this invoice are standard company estimates.\nActual weights may vary upon final measurement.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          rightInvoiceSheet,
          const SizedBox(height: 16),
          leftActionColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 38, child: leftActionColumn),
        const SizedBox(width: 24),
        Expanded(flex: 62, child: rightInvoiceSheet),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 5. ORDER DETAILS GRID
/// ---------------------------------------------------------------------------
class _OrderDetailsView extends StatelessWidget {
  final SalesDashboardProvider provider;
  final bool isMobile;

  const _OrderDetailsView({
    required this.provider,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final orders = provider.pagedOrders;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < OrderFilterChip.values.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      _FilterChipButton(
                        label: OrderFilterChip.values[i].label,
                        isSelected:
                            provider.orderFilter == OrderFilterChip.values[i],
                        onTap: () =>
                            provider.setOrderFilter(OrderFilterChip.values[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: isMobile ? 150 : 225,
              height: 34,
              child: TextField(
                onChanged: provider.setOrderSearch,
                style: const TextStyle(fontSize: 11.5),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                  hintText: 'Search orders',
                  hintStyle: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF2B88C6)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 10,
            childAspectRatio: isMobile ? 2.9 : 2.95,
          ),
          itemBuilder: (context, idx) => _BlueAccentOrderCard(
            order: orders[idx],
            onTap: () => provider.openInvoiceForOrder(orders[idx]),
          ),
        ),
        const SizedBox(height: 12),
        _PaginationFooter(
          currentPage: provider.orderPage,
          totalPages: provider.totalOrderPages,
          onSelectPage: provider.setOrderPage,
          onNext: provider.nextOrderPage,
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// SHARED SALES CARDS & PAGINATION
/// ---------------------------------------------------------------------------
BoxDecoration _elevatedCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

class _BlueAccentOrderCard extends StatelessWidget {
  final SalesOrderRecord order;
  final VoidCallback onTap;

  const _BlueAccentOrderCard({
    required this.order,
    required this.onTap,
  });

  (Color bg, Color fg) _badgeColors(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('estimate')) {
      return (const Color(0xFF86EFAC), const Color(0xFF166534));
    }
    if (lower.contains('billing')) {
      return (const Color(0xFFFDE68A), const Color(0xFF92400E));
    }
    return (const Color(0xFF93A5FD), const Color(0xFF1E3A8A));
  }

  @override
  Widget build(BuildContext context) {
    final colors = _badgeColors(order.statusLabel);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: _elevatedCardDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(width: 5, color: const Color(0xFF2B88C6)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderCode,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.$1,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              order.statusLabel,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: colors.$2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customer Name - ${order.contactPerson}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Items - ${order.itemsSummary}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Order Date - ${order.orderDate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
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
      ),
    );
  }
}

class _BlueAccentCustomerCard extends StatelessWidget {
  final SalesCustomerRecord customer;
  final VoidCallback onTap;

  const _BlueAccentCustomerCard({
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: _elevatedCardDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(width: 5, color: const Color(0xFF2B88C6)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        customer.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Contact Person - ${customer.contactPerson}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Phone - ${customer.phone}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'GSTIN - ${customer.gstin}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
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
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2B88C6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF60A5FA)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF2B88C6),
          ),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onSelectPage;
  final VoidCallback onNext;

  const _PaginationFooter({
    required this.currentPage,
    required this.totalPages,
    required this.onSelectPage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final count = totalPages.clamp(1, 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int p = 1; p <= count; p++) ...[
          if (p > 1) const SizedBox(width: 10),
          InkWell(
            onTap: () => onSelectPage(p),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: currentPage == p
                      ? const Color(0xFF2B88C6)
                      : const Color(0xFFCBD5E1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$p',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight:
                      currentPage == p ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 10),
        InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
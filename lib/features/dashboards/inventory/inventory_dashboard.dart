import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'models/inventory_models.dart';
import 'providers/inventory_management_provider.dart';

class InventoryManagementDashboard extends InventoryDashboard {
  const InventoryManagementDashboard({
    super.key,
    super.title = 'Inventory Management',
  });
}

class InventoryDashboard extends StatelessWidget {
  final String title;

  const InventoryDashboard({super.key, this.title = 'Inventory Management'});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryManagementProvider(),
      child: const _InventoryDashboardScaffold(),
    );
  }
}

class _InventoryDashboardScaffold extends StatelessWidget {
  const _InventoryDashboardScaffold();

  String _mainTitleForPage(InventorySubPage page) {
    switch (page) {
      case InventorySubPage.overview:
      case InventorySubPage.dangerZone:
        return 'Welcome back, Rupesh!';
      case InventorySubPage.createSku:
        return 'Create SKU';
      case InventorySubPage.updatingInventory:
        return 'Updating Inventory';
    }
  }

  bool _isGreeting(InventorySubPage page) {
    return page == InventorySubPage.overview ||
        page == InventorySubPage.dangerZone;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryManagementProvider>();
    final bool isMobile = Responsive.isMobile(context);
    final page = provider.currentPage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPad = provider.isSidebarOpen && !isMobile
                ? 22.0
                : (isMobile ? 14.0 : 62.0);
            final availHeight = (constraints.maxHeight - 32).clamp(420.0, 1200.0);

            return Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (provider.isSidebarOpen && !isMobile)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                        child: _InventoryBlackSidebar(
                          currentPage: page,
                          onSelectPage: (p) {
                            provider.openPage(p);
                            provider.setSidebarOpen(false);
                          },
                          onClose: () => provider.setSidebarOpen(false),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPad,
                          14,
                          isMobile ? 14 : 30,
                          18,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: availHeight),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _InventoryHeader(
                                    mainLabel: _mainTitleForPage(page),
                                    isGreeting: _isGreeting(page),
                                    showLogo: !provider.isSidebarOpen,
                                    onTitleTap: () => provider
                                        .openPage(InventorySubPage.overview),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSubPage(
                                    context,
                                    provider,
                                    isMobile,
                                    availHeight,
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
                          width: 48,
                          height: 48,
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
                          child: _InventoryBlackSidebar(
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

  Widget _buildSubPage(
    BuildContext context,
    InventoryManagementProvider provider,
    bool isMobile,
    double availHeight,
  ) {
    final bodyHeight = (availHeight - 86).clamp(340.0, 680.0);

    switch (provider.currentPage) {
      case InventorySubPage.overview:
        return _InventoryOverviewView(
          provider: provider,
          isMobile: isMobile,
          bodyHeight: bodyHeight,
        );
      case InventorySubPage.createSku:
        return _CreateSkuFormView(
          provider: provider,
          isMobile: isMobile,
          bodyHeight: bodyHeight,
        );
      case InventorySubPage.updatingInventory:
        return _UpdatingInventoryFormView(
          provider: provider,
          isMobile: isMobile,
          bodyHeight: bodyHeight,
        );
      case InventorySubPage.dangerZone:
        return _SkuDangerZoneView(
          provider: provider,
          isMobile: isMobile,
          bodyHeight: bodyHeight,
        );
    }
  }
}

class _InventoryHeader extends StatelessWidget {
  final String mainLabel;
  final bool isGreeting;
  final bool showLogo;
  final VoidCallback onTitleTap;

  const _InventoryHeader({
    required this.mainLabel,
    required this.isGreeting,
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
                'Inventory Management',
                style: TextStyle(
                  fontSize: 16,
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
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                )
              else
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 26,
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
            height: 48,
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

class _InventoryBlackSidebar extends StatelessWidget {
  final InventorySubPage currentPage;
  final ValueChanged<InventorySubPage> onSelectPage;
  final VoidCallback onClose;

  const _InventoryBlackSidebar({
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
          for (final p in InventorySubPage.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () => onSelectPage(p),
                child: Row(
                  children: [
                    Icon(
                      _iconFor(p),
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

  IconData _iconFor(InventorySubPage p) {
    switch (p) {
      case InventorySubPage.overview:
        return Icons.dashboard_customize_outlined;
      case InventorySubPage.createSku:
        return Icons.add_circle_outline_rounded;
      case InventorySubPage.updatingInventory:
        return Icons.sync_alt_rounded;
      case InventorySubPage.dangerZone:
        return Icons.warning_amber_rounded;
    }
  }
}

/// ---------------------------------------------------------------------------
/// 1. INVENTORY OVERVIEW (image_a8b8e5.png)
/// ---------------------------------------------------------------------------
class _InventoryOverviewView extends StatelessWidget {
  final InventoryManagementProvider provider;
  final bool isMobile;
  final double bodyHeight;

  const _InventoryOverviewView({
    required this.provider,
    required this.isMobile,
    required this.bodyHeight,
  });

  void _showSkuInspectModal(BuildContext context, InventorySkuRecord sku) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          sku.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sku.specsSummary, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Text('Stock: ${sku.stockLabel}', style: const TextStyle(fontSize: 13)),
            Text('Brand: ${sku.brand}', style: const TextStyle(fontSize: 13)),
            if (sku.storageLocation.isNotEmpty)
              Text(
                'Location: ${sku.storageLocation}',
                style: const TextStyle(fontSize: 13),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.selectSku(sku.id);
              provider.openPage(InventorySubPage.updatingInventory);
            },
            child: const Text('Update Stock'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.selectSku(sku.id);
              provider.openPage(InventorySubPage.dangerZone);
            },
            child: const Text(
              'SKU Actions',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B88C6),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required int value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: _invCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$value',
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

  Widget _actionTileCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: _invCardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.textPrimary),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleSkus = provider.skus.take(3).toList();

    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                label: 'Total SKU Count',
                value: provider.totalSkuCount,
                onTap: () => provider.openPage(InventorySubPage.createSku),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _statCard(
                label: 'Inventory Current value',
                value: provider.inventoryCurrentValue,
                onTap: () =>
                    provider.openPage(InventorySubPage.updatingInventory),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () => provider.openPage(InventorySubPage.updatingInventory),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: _invCardDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.priority_high_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 18),
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${provider.lowStockAlertsCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _actionTileCard(
                icon: Icons.add_circle_outline_rounded,
                label: 'Create SKU',
                onTap: () => provider.openPage(InventorySubPage.createSku),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _actionTileCard(
                icon: Icons.note_add_outlined,
                label: 'Update Inventory Stock',
                onTap: () =>
                    provider.openPage(InventorySubPage.updatingInventory),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Bottom-left soft blue pill card (matching image_a8b8e5.png)
        InkWell(
          onTap: () => provider.openPage(InventorySubPage.dangerZone),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFDFEFFC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Manage SKU & Danger Zone',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B88C6),
              ),
            ),
          ),
        ),
      ],
    );

    final rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Inventory',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < visibleSkus.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _CurrentInventorySkuRowCard(
            sku: visibleSkus[i],
            onView: () => _showSkuInspectModal(context, visibleSkus[i]),
          ),
        ],
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          leftColumn,
          const SizedBox(height: 18),
          rightColumn,
        ],
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: bodyHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 52, child: leftColumn),
          const SizedBox(width: 34),
          Expanded(flex: 48, child: rightColumn),
        ],
      ),
    );
  }
}

class _CurrentInventorySkuRowCard extends StatelessWidget {
  final InventorySkuRecord sku;
  final VoidCallback onView;

  const _CurrentInventorySkuRowCard({
    required this.sku,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _invCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.view_stream_rounded,
              color: Color(0xFFCBD5E1),
              size: 38,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sku.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sku.specsSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sku.stockLabel,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(
                      height: 26,
                      width: 72,
                      child: ElevatedButton(
                        onPressed: onView,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFF2B88C6),
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
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
/// 2. CREATE SKU FORM (image_a8c0a4.png)
/// ---------------------------------------------------------------------------
class _CreateSkuFormView extends StatefulWidget {
  final InventoryManagementProvider provider;
  final bool isMobile;
  final double bodyHeight;

  const _CreateSkuFormView({
    required this.provider,
    required this.isMobile,
    required this.bodyHeight,
  });

  @override
  State<_CreateSkuFormView> createState() => _CreateSkuFormViewState();
}

class _CreateSkuFormViewState extends State<_CreateSkuFormView> {
  final _materialTypeCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _weightPrefixCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _buyingPriceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedBrand;
  String? _selectedSpec;
  String? _selectedGrade;

  @override
  void dispose() {
    _materialTypeCtrl.dispose();
    _lengthCtrl.dispose();
    _quantityCtrl.dispose();
    _weightPrefixCtrl.dispose();
    _thresholdCtrl.dispose();
    _supplierCtrl.dispose();
    _locationCtrl.dispose();
    _buyingPriceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onSaveSku() {
    widget.provider.createSku(
      materialType: _materialTypeCtrl.text,
      brand: _selectedBrand ?? 'Tata Tiscon',
      specification: _selectedSpec ?? 'Dia 12',
      grade: _selectedGrade ?? 'FE500D',
      length: _lengthCtrl.text,
      quantityText: _quantityCtrl.text,
      weightPrefix: _weightPrefixCtrl.text,
      lowStockThresholdText: _thresholdCtrl.text,
      supplier: _supplierCtrl.text,
      storageLocation: _locationCtrl.text,
      buyingPriceText: _buyingPriceCtrl.text,
      notes: _notesCtrl.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New SKU created and added to inventory.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leftFields = [
      _InvLabeledInput(
        label: 'Material Type',
        controller: _materialTypeCtrl,
        hintText: 'TMT Bar, G.I. Sheet, Binding Wire, Etc.',
      ),
      _InvLabeledDropdown(
        label: 'Brand',
        hintText: 'Choose Brand',
        value: _selectedBrand,
        items: const ['Tata Tiscon', 'JSW Steel', 'SAIL', 'Shyam'],
        onChanged: (v) => setState(() => _selectedBrand = v),
      ),
      _InvLabeledDropdown(
        label: 'Specification',
        hintText: '12mm FE500D TMT Bar',
        value: _selectedSpec,
        items: const ['Dia 12', 'Dia 10', 'Dia 16', 'Dia 8'],
        onChanged: (v) => setState(() => _selectedSpec = v),
      ),
      _InvLabeledDropdown(
        label: 'Grade',
        hintText: 'Choose Grade',
        value: _selectedGrade,
        items: const ['FE500', 'FE500D', 'FE550D'],
        onChanged: (v) => setState(() => _selectedGrade = v),
      ),
      _InvLabeledInput(
        label: 'Lenght',
        controller: _lengthCtrl,
        hintText: 'Auto fixed Length',
      ),
      _InvLabeledInput(
        label: 'Quantity',
        controller: _quantityCtrl,
        hintText: 'Enter Quantity',
        keyboardType: TextInputType.number,
      ),
    ];

    final rightFields = [
      _InvLabeledInput(
        label: 'Weight Pre-fixed',
        controller: _weightPrefixCtrl,
        hintText: 'Auto weight will be shown here',
      ),
      _InvLabeledInput(
        label: 'Low Stock Threshold',
        controller: _thresholdCtrl,
        hintText: 'Low Stock Threshold',
        keyboardType: TextInputType.number,
      ),
      _InvLabeledInput(
        label: 'Supplier',
        controller: _supplierCtrl,
        hintText: 'Optional',
      ),
      _InvLabeledInput(
        label: 'Storage Location',
        controller: _locationCtrl,
        hintText: 'location in the warehouse',
      ),
      _InvLabeledInput(
        label: 'Buying Price',
        controller: _buyingPriceCtrl,
        hintText: 'Buying Price',
        keyboardType: TextInputType.number,
      ),
      _InvLabeledInput(
        label: 'Notes',
        controller: _notesCtrl,
        hintText: '',
      ),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: widget.bodyHeight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.isMobile)
            Column(
              children: [
                for (final f in [...leftFields, ...rightFields]) ...[
                  f,
                  const SizedBox(height: 8),
                ],
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (int i = 0; i < leftFields.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          leftFields[i],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 86),
                  Expanded(
                    child: Column(
                      children: [
                        for (int i = 0; i < rightFields.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          rightFields[i],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: 315,
            height: 40,
            child: ElevatedButton(
              onPressed: _onSaveSku,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B88C6),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save & Create SKU',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 3. UPDATING INVENTORY FORM (image_a8c0c7.png)
/// ---------------------------------------------------------------------------
class _UpdatingInventoryFormView extends StatefulWidget {
  final InventoryManagementProvider provider;
  final bool isMobile;
  final double bodyHeight;

  const _UpdatingInventoryFormView({
    required this.provider,
    required this.isMobile,
    required this.bodyHeight,
  });

  @override
  State<_UpdatingInventoryFormView> createState() =>
      _UpdatingInventoryFormViewState();
}

class _UpdatingInventoryFormViewState
    extends State<_UpdatingInventoryFormView> {
  final _quantityCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _buyingPriceCtrl = TextEditingController();

  String? _adjustmentForm;
  String? _unit;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _supplierCtrl.dispose();
    _locationCtrl.dispose();
    _buyingPriceCtrl.dispose();
    super.dispose();
  }

  void _onUpdateStock() {
    widget.provider.updateInventoryStock(
      skuId: widget.provider.selectedSkuId,
      adjustmentForm: _adjustmentForm ?? 'Restock/manual correction',
      unit: _unit ?? 'rolls',
      quantityText: _quantityCtrl.text,
      supplier: _supplierCtrl.text,
      storageLocation: _locationCtrl.text,
      buyingPriceText: _buyingPriceCtrl.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventory stock updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skuItems = widget.provider.skus;
    final currentSelected = skuItems.any((s) => s.id == widget.provider.selectedSkuId)
        ? widget.provider.selectedSkuId
        : null;

    final selectSkuDropdown = _InvLabeledDropdown(
      label: 'Select SKU',
      hintText: 'Choose Brand',
      value: currentSelected,
      items: skuItems.map((s) => s.id).toList(),
      itemLabelBuilder: (id) {
        final match = skuItems.firstWhere((s) => s.id == id);
        return '${match.brand} — ${match.title}';
      },
      onChanged: widget.provider.selectSku,
    );

    final leftAdjFields = [
      _InvLabeledDropdown(
        label: 'Adjustment Form',
        hintText: 'Restock/manual correction',
        value: _adjustmentForm,
        items: const [
          'Restock/manual correction',
          'Damage/write-off',
          'Return to supplier',
        ],
        onChanged: (v) => setState(() => _adjustmentForm = v),
      ),
      _InvLabeledDropdown(
        label: 'Choose Unit',
        hintText: 'Unit',
        value: _unit,
        items: const ['Rolls', 'Bundles', 'Kg', 'Tonnes'],
        onChanged: (v) => setState(() => _unit = v),
      ),
      _InvLabeledInput(
        label: 'Quantity',
        controller: _quantityCtrl,
        hintText: 'Enter Quantity',
        keyboardType: TextInputType.number,
      ),
    ];

    final rightAdjFields = [
      _InvLabeledInput(
        label: 'Supplier',
        controller: _supplierCtrl,
        hintText: 'Optional',
      ),
      _InvLabeledInput(
        label: 'Storage Location',
        controller: _locationCtrl,
        hintText: 'location in the warehouse',
      ),
      _InvLabeledInput(
        label: 'Buying Price',
        controller: _buyingPriceCtrl,
        hintText: 'Buying Price',
        keyboardType: TextInputType.number,
      ),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: widget.bodyHeight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 0 : 54),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isMobile)
                  selectSkuDropdown
                else
                  Row(
                    children: [
                      Expanded(child: selectSkuDropdown),
                      const SizedBox(width: 86),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                const SizedBox(height: 18),
                if (widget.isMobile)
                  Column(
                    children: [
                      for (final f in [...leftAdjFields, ...rightAdjFields]) ...[
                        f,
                        const SizedBox(height: 10),
                      ],
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            for (int i = 0; i < leftAdjFields.length; i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              leftAdjFields[i],
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 86),
                      Expanded(
                        child: Column(
                          children: [
                            for (int i = 0; i < rightAdjFields.length; i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              rightAdjFields[i],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 315,
            height: 40,
            child: ElevatedButton(
              onPressed: _onUpdateStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B88C6),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Update Stock',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 4. SKU ACTIONS & DANGER ZONE + ADMIN CONFIRM MODAL (image_a8c100.png & image_a8c120.png)
/// ---------------------------------------------------------------------------
class _SkuDangerZoneView extends StatelessWidget {
  final InventoryManagementProvider provider;
  final bool isMobile;
  final double bodyHeight;

  const _SkuDangerZoneView({
    required this.provider,
    required this.isMobile,
    required this.bodyHeight,
  });

  void _openConfirmDialog(BuildContext context, DangerActionType action) {
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
                            final ok = provider.confirmDangerAction(
                              actionType: action,
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
    final skuItems = provider.skus;
    final currentSelected = skuItems.any((s) => s.id == provider.selectedSkuId)
        ? provider.selectedSkuId
        : null;

    final leftSelect = _InvLabeledDropdown(
      label: 'Select SKU',
      hintText: 'Choose Brand',
      value: currentSelected,
      items: skuItems.map((s) => s.id).toList(),
      itemLabelBuilder: (id) {
        final match = skuItems.firstWhere((s) => s.id == id);
        return '${match.brand} — ${match.title}';
      },
      onChanged: provider.selectSku,
    );

    final dangerZoneCard = Container(
      width: isMobile ? double.infinity : 365,
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
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
          const SizedBox(height: 18),
          for (int i = 0; i < DangerActionType.values.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () =>
                    _openConfirmDialog(context, DangerActionType.values[i]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDF3B47),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  DangerActionType.values[i].buttonLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
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
          leftSelect,
          const SizedBox(height: 24),
          dangerZoneCard,
        ],
      );
    }

    return SizedBox(
      height: bodyHeight,
      child: Padding(
        padding: const EdgeInsets.only(top: 32, left: 54, right: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 42, child: leftSelect),
            const SizedBox(width: 48),
            Expanded(
              flex: 58,
              child: Align(
                alignment: Alignment.topCenter,
                child: dangerZoneCard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// SHARED FORM INPUTS & CARD DECORATION
/// ---------------------------------------------------------------------------
BoxDecoration _invCardDecoration() {
  return BoxDecoration(
    color: const Color(0xFFFAFAFA),
    borderRadius: BorderRadius.circular(18),
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

class _InvLabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  const _InvLabeledInput({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 3),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 30,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 11.5),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
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
      ],
    );
  }
}

class _InvLabeledDropdown extends StatelessWidget {
  final String label;
  final String hintText;
  final String? value;
  final List<String> items;
  final String Function(String)? itemLabelBuilder;
  final ValueChanged<String?> onChanged;

  const _InvLabeledDropdown({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    this.itemLabelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 3),
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
          height: 30,
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
              hint: Text(
                hintText,
                style: const TextStyle(
                  fontSize: 11,
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
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        itemLabelBuilder != null ? itemLabelBuilder!(e) : e,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
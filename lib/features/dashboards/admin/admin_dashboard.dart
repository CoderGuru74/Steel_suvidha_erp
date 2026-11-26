import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'models/admin_models.dart';
import 'providers/admin_dashboard_provider.dart';

class AdminDashboard extends StatelessWidget {
  final String title;

  const AdminDashboard({super.key, this.title = 'Admin'});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardProvider(),
      child: const _AdminDashboardScaffold(),
    );
  }
}

class _AdminDashboardScaffold extends StatelessWidget {
  const _AdminDashboardScaffold();

  String _resolveHeading(AdminDashboardProvider provider) {
    switch (provider.currentSection) {
      case AdminPanelSection.overview:
        return 'Welcome back, Rupesh!';
      case AdminPanelSection.staffDirectory:
        return 'Staff Directory';
      case AdminPanelSection.staffProfile:
        return 'Staff Profile';
      case AdminPanelSection.brandingProfile:
        return 'Branding & Profile';
      case AdminPanelSection.subscription:
        return 'Manage Subscription';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final bool isMobile = Responsive.isMobile(context);
    final bool isOverview = provider.currentSection == AdminPanelSection.overview;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.isSidebarOpen && !isMobile)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                    child: _AdminBlackSidebar(
                      currentSection: provider.currentSection,
                      onSelectSection: provider.openSection,
                      onClose: () => provider.setSidebarOpen(false),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      provider.isSidebarOpen && !isMobile
                          ? 22
                          : (isMobile ? 16 : 64),
                      16,
                      isMobile ? 16 : 28,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AdminHeaderBar(
                          headingText: _resolveHeading(provider),
                          isGreeting: isOverview,
                          showBrandLogo: !provider.isSidebarOpen,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionContent(context, provider, isMobile),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top-left Black Hamburger Button
            if (!provider.isSidebarOpen)
              Positioned(
                top: 16,
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
                      child: _AdminBlackSidebar(
                        currentSection: provider.currentSection,
                        onSelectSection: (sec) {
                          provider.openSection(sec);
                          provider.setSidebarOpen(false);
                        },
                        onClose: () => provider.setSidebarOpen(false),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(
    BuildContext context,
    AdminDashboardProvider provider,
    bool isMobile,
  ) {
    switch (provider.currentSection) {
      case AdminPanelSection.overview:
        return _AdminOverviewGrid(provider: provider, isMobile: isMobile);
      case AdminPanelSection.staffDirectory:
        return _StaffDirectorySection(provider: provider, isMobile: isMobile);
      case AdminPanelSection.staffProfile:
        return _StaffProfileFormSection(provider: provider, isMobile: isMobile);
      case AdminPanelSection.brandingProfile:
        return _BrandingProfileFormSection(
          provider: provider,
          isMobile: isMobile,
        );
      case AdminPanelSection.subscription:
        return provider.showDataUtilitiesSubView
            ? _ExportAndDangerZoneSection(
                provider: provider,
                isMobile: isMobile,
              )
            : _ManageSubscriptionSection(
                provider: provider,
                isMobile: isMobile,
              );
    }
  }
}

class _AdminHeaderBar extends StatelessWidget {
  final String headingText;
  final bool isGreeting;
  final bool showBrandLogo;

  const _AdminHeaderBar({
    required this.headingText,
    required this.isGreeting,
    required this.showBrandLogo,
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
            const Text(
              'Admin Dashboard',
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
                headingText,
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
        if (showBrandLogo)
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

class _AdminBlackSidebar extends StatelessWidget {
  final AdminPanelSection currentSection;
  final ValueChanged<AdminPanelSection> onSelectSection;
  final VoidCallback onClose;

  const _AdminBlackSidebar({
    required this.currentSection,
    required this.onSelectSection,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
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
                      fontSize: 15,
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
          const SizedBox(height: 28),
          for (final sec in AdminPanelSection.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => onSelectSection(sec),
                child: Row(
                  children: [
                    Icon(
                      _iconForSection(sec),
                      size: 18,
                      color: currentSection == sec
                          ? const Color(0xFF60A5FA)
                          : Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sec.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: currentSection == sec
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: currentSection == sec
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
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForSection(AdminPanelSection sec) {
    switch (sec) {
      case AdminPanelSection.overview:
        return Icons.grid_view_rounded;
      case AdminPanelSection.staffDirectory:
        return Icons.people_outline_rounded;
      case AdminPanelSection.staffProfile:
        return Icons.person_add_alt_1_outlined;
      case AdminPanelSection.brandingProfile:
        return Icons.storefront_outlined;
      case AdminPanelSection.subscription:
        return Icons.card_membership_outlined;
    }
  }
}

/// ---------------------------------------------------------------------------
/// 1. ADMIN DASHBOARD OVERVIEW (image_8acbe5.png)
/// ---------------------------------------------------------------------------
class _AdminOverviewGrid extends StatelessWidget {
  final AdminDashboardProvider provider;
  final bool isMobile;

  const _AdminOverviewGrid({
    required this.provider,
    required this.isMobile,
  });

  void _showAddStockDialog(BuildContext context) {
    final unitsCtrl = TextEditingController(text: '10');
    final amountCtrl = TextEditingController(text: '45000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Stock Entry',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: unitsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity (Orders/MT)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sale Value (₹)'),
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
              backgroundColor: const Color(0xFF2B88C6),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final units = int.tryParse(unitsCtrl.text.trim()) ?? 1;
              final amt = int.tryParse(amountCtrl.text.trim()) ?? 0;
              provider.addStockEntry(amt, units);
              Navigator.pop(ctx);
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiTile({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: _PanelCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
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

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: _PanelCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: AppColors.textPrimary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashLedgerCard() {
    return _PanelCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LedgerRow(
            label: 'Cash Received',
            value: provider.formattedCashReceived,
          ),
          const SizedBox(height: 12),
          _LedgerRow(
            label: 'Sales Receivable',
            value: provider.formattedSalesReceivable,
          ),
          const SizedBox(height: 12),
          _LedgerRow(
            label: 'Cash Paid',
            value: provider.formattedCashPaid,
          ),
          const SizedBox(height: 12),
          _LedgerRow(
            label: 'Expenses',
            value: provider.formattedExpenses,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context) {
    final visible = provider.activities.take(2).toList();
    return _PanelCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < visible.length; i++) ...[
            if (i > 0)
              const Divider(height: 12, color: Color(0xFFE2E8F0)),
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: visible[i].isCompleted
                        ? const Color(0xFF2B88C6)
                        : const Color(0xFF1D63ED),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  visible[i].title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '•  ${visible[i].status}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              onTap: () => provider.openSection(AdminPanelSection.subscription),
              child: const Text(
                'View More',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B88C6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leftColumn = Column(
      children: [
        // Row 1: Today's Sale | Order Count | Pending Orders
        Row(
          children: [
            Expanded(
              child: _buildKpiTile(
                label: "Today's Sale",
                value: provider.formattedTodaysSale,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiTile(
                label: 'Order Count',
                value: '${provider.orderCount}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiTile(
                label: 'Pending Orders',
                value: '${provider.pendingOrdersTop}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Pending Orders | Orders in Process | Orders Dispatched
        Row(
          children: [
            Expanded(
              child: _buildKpiTile(
                label: 'Pending Orders',
                value: '${provider.pendingOrdersBottom}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiTile(
                label: 'Orders\nin Process',
                value: '${provider.ordersInProcess}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiTile(
                label: 'Orders\nDispatched',
                value: '${provider.ordersDispatched}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Low Stock Alerts Banner
        _PanelCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF59E0B),
                size: 26,
              ),
              const SizedBox(width: 12),
              const Text(
                'Low Stock Alerts  :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '${provider.lowStockAlerts}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDF3B47),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Row 4: View Staff | Add Stock | View Daybook
        Row(
          children: [
            Expanded(
              child: _buildQuickActionTile(
                icon: Icons.person_rounded,
                label: 'View Staff',
                onTap: () =>
                    provider.openSection(AdminPanelSection.staffDirectory),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionTile(
                icon: Icons.inventory_2_outlined,
                label: 'Add Stock',
                onTap: () => _showAddStockDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionTile(
                icon: Icons.assignment_outlined,
                label: 'View Daybook',
                onTap: () =>
                    provider.openSection(AdminPanelSection.subscription),
              ),
            ),
          ],
        ),
      ],
    );

    final rightColumn = Column(
      children: [
        _buildCashLedgerCard(),
        const SizedBox(height: 14),
        _buildRecentActivityCard(context),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          leftColumn,
          const SizedBox(height: 14),
          rightColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 57, child: leftColumn),
        const SizedBox(width: 16),
        Expanded(flex: 43, child: rightColumn),
      ],
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final String label;
  final String value;

  const _LedgerRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 2. STAFF DIRECTORY (image_8acead.png)
/// ---------------------------------------------------------------------------
class _StaffDirectorySection extends StatelessWidget {
  final AdminDashboardProvider provider;
  final bool isMobile;

  const _StaffDirectorySection({
    required this.provider,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final staff = provider.filteredStaff;
    final sub = provider.subscription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Underline Tabs: All Staff | Sales | Procurement
                Row(
                  children: [
                    for (int i = 0; i < StaffFilterTab.values.length; i++) ...[
                      if (i > 0) const SizedBox(width: 22),
                      _UnderlineTabItem(
                        label: StaffFilterTab.values[i].label,
                        isSelected: provider.staffTab == StaffFilterTab.values[i],
                        onTap: () => provider.setStaffTab(StaffFilterTab.values[i]),
                      ),
                    ],
                  ],
                ),
                Container(
                  width: isMobile ? 280 : 340,
                  height: 1,
                  color: const Color(0xFFCBD5E1),
                ),
                const SizedBox(height: 10),

                // Seats Used Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFECACA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Seats Used : ${sub.adminSeatsUsed} of Admin | ${sub.salesSeatsUsed} of ${sub.salesSeatsLimit} Sales | ${sub.procurementSeatsUsed} of ${sub.procurementSeatsLimit} Procurement',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDF3B47),
                    ),
                  ),
                ),
              ],
            ),

            // + Add New Staff Button
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: provider.openAddStaffForm,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add New Staff',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: staff.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: isMobile ? 2.5 : 2.25,
          ),
          itemBuilder: (context, idx) {
            final member = staff[idx];
            return _PanelCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '(${member.roleLabel})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBF7D0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          member.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text('Message sent to ${member.name}'),
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => provider.openEditStaffForm(member),
                            child: const Icon(
                              Icons.visibility_outlined,
                              size: 17,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => provider.deleteStaffMember(member.id),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 17,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => provider.cycleStaffRole(member.id),
                            child: const Icon(
                              Icons.reply_rounded,
                              size: 17,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UnderlineTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnderlineTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF2B88C6) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 3. STAFF PROFILE FORM (image_8acf28.png)
/// ---------------------------------------------------------------------------
class _StaffProfileFormSection extends StatefulWidget {
  final AdminDashboardProvider provider;
  final bool isMobile;

  const _StaffProfileFormSection({
    required this.provider,
    required this.isMobile,
  });

  @override
  State<_StaffProfileFormSection> createState() =>
      _StaffProfileFormSectionState();
}

class _StaffProfileFormSectionState extends State<_StaffProfileFormSection> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passwordCtrl;
  AdminStaffRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    final editing = widget.provider.editingStaff;
    _nameCtrl = TextEditingController(text: editing?.name ?? '');
    _phoneCtrl = TextEditingController(text: editing?.phone ?? '');
    _passwordCtrl = TextEditingController();
    if (editing != null) {
      _selectedRole = AdminStaffRole.values.firstWhere(
        (r) => r.label == editing.roleLabel,
        orElse: () => AdminStaffRole.salesTeam,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftAvatarBlock = Column(
      children: [
        const SizedBox(height: 12),
        const _AvatarPlaceholderCircle(),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PhotoOutlineButton(
              label: 'Choose Photo',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo selected from gallery.')),
              ),
            ),
            const SizedBox(width: 12),
            _PhotoOutlineButton(
              label: 'Click Photo',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera capture ready.')),
              ),
            ),
          ],
        ),
      ],
    );

    final rightFormBlock = SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoundedFormField(
            controller: _nameCtrl,
            hintText: 'Enter Full Name :',
          ),
          const SizedBox(height: 12),
          _RoundedFormField(
            controller: _phoneCtrl,
            hintText: 'Enter Phone Number :',
          ),
          const SizedBox(height: 12),
          _RoundedFormField(
            controller: _passwordCtrl,
            hintText: 'Set Password :',
            obscureText: true,
          ),
          const SizedBox(height: 12),
          const Text(
            'Select Role :',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AdminStaffRole>(
                value: _selectedRole,
                isExpanded: true,
                hint: const Text(
                  'Choose :',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
                items: AdminStaffRole.values
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(
                          r.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedRole = val),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Role Choice Box (Admin / Sales Team / Order Processing Team)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < AdminStaffRole.values.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  InkWell(
                    onTap: () =>
                        setState(() => _selectedRole = AdminStaffRole.values[i]),
                    child: Text(
                      AdminStaffRole.values[i].label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: _selectedRole == AdminStaffRole.values[i]
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: _selectedRole == AdminStaffRole.values[i]
                            ? const Color(0xFF2B88C6)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 240,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                widget.provider.saveStaffMember(
                  fullName: _nameCtrl.text,
                  phone: _phoneCtrl.text,
                  role: _selectedRole ?? AdminStaffRole.salesTeam,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Staff access saved.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B88C6),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save & Grant Access',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.isMobile) {
      return Column(
        children: [
          leftAvatarBlock,
          const SizedBox(height: 20),
          rightFormBlock,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 45, child: leftAvatarBlock),
        Expanded(flex: 55, child: rightFormBlock),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 4. BRANDING & PROFILE FORM (image_8acf4a.png)
/// ---------------------------------------------------------------------------
class _BrandingProfileFormSection extends StatefulWidget {
  final AdminDashboardProvider provider;
  final bool isMobile;

  const _BrandingProfileFormSection({
    required this.provider,
    required this.isMobile,
  });

  @override
  State<_BrandingProfileFormSection> createState() =>
      _BrandingProfileFormSectionState();
}

class _BrandingProfileFormSectionState
    extends State<_BrandingProfileFormSection> {
  late final TextEditingController _storeCtrl;
  late final TextEditingController _gstinCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final b = widget.provider.branding;
    _storeCtrl = TextEditingController(text: b.storeName);
    _gstinCtrl = TextEditingController(text: b.gstin);
    _contactCtrl = TextEditingController(text: b.contactNumber);
    _addressCtrl = TextEditingController(text: b.physicalAddress);
  }

  @override
  void dispose() {
    _storeCtrl.dispose();
    _gstinCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftBlock = Column(
      children: [
        const SizedBox(height: 16),
        const _AvatarPlaceholderCircle(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PhotoOutlineButton(
              label: 'Choose Photo',
              onTap: () => widget.provider.updatePhotoLabel('Gallery Photo'),
            ),
            const SizedBox(width: 12),
            _PhotoOutlineButton(
              label: 'Click Photo',
              onTap: () => widget.provider.updatePhotoLabel('Camera Photo'),
            ),
          ],
        ),
      ],
    );

    final rightBlock = SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Name & Details :',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _RoundedFormField(
            controller: _storeCtrl,
            hintText: '(e.g. Shree Ram Steel)',
          ),
          const SizedBox(height: 12),
          _RoundedFormField(
            controller: _gstinCtrl,
            hintText: 'GSTIN Number :',
          ),
          const SizedBox(height: 12),
          _RoundedFormField(
            controller: _contactCtrl,
            hintText: 'Contact Number :',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: TextField(
              controller: _addressCtrl,
              maxLines: 4,
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                hintText: 'Physical Address :',
                hintStyle: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2B88C6)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 240,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                widget.provider.updateBranding(
                  storeName: _storeCtrl.text,
                  gstin: _gstinCtrl.text,
                  contactNumber: _contactCtrl.text,
                  physicalAddress: _addressCtrl.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Store branding saved.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B88C6),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save & Grant Access',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.isMobile) {
      return Column(
        children: [
          leftBlock,
          const SizedBox(height: 20),
          rightBlock,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 45, child: leftBlock),
        Expanded(flex: 55, child: rightBlock),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 5A. MANAGE SUBSCRIPTION (image_8acf69.png)
/// ---------------------------------------------------------------------------
class _ManageSubscriptionSection extends StatelessWidget {
  final AdminDashboardProvider provider;
  final bool isMobile;

  const _ManageSubscriptionSection({
    required this.provider,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final sub = provider.subscription;

    return Column(
      children: [
        // Top Plan Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCE6F7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: isMobile ? 96 : 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.planName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${sub.monthlyPriceInr}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFDBFE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        sub.badge,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Staff Panel : ${sub.staffPanelSummary}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Features : ${sub.featuresSummary}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 72,
                height: 30,
                child: OutlinedButton(
                  onPressed: provider.upgradePlanSample,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF93C5FD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D63ED),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Middle Row: Payment History + Upgrade Contact Card
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 40,
              child: _PanelCard(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment History',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final inv in const ['Invoice #02', 'Invoice #01']) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            inv,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          InkWell(
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(content: Text('Downloading $inv...')),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Download ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF2B88C6),
                                  ),
                                ),
                                Icon(
                                  Icons.cloud_download_outlined,
                                  size: 14,
                                  color: Color(0xFF2B88C6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14, color: Color(0xFFE2E8F0)),
                    ],
                    Center(
                      child: InkWell(
                        onTap: () => provider.toggleDataUtilitiesSubView(true),
                        child: const Text(
                          'View More',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2B88C6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 60,
              child: _PanelCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Are you facing any issues or want to\nupgrade your current plan ?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Drop your query at hello@steelsuvidha.in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Bottom CTA Button
        SizedBox(
          width: 240,
          height: 38,
          child: ElevatedButton(
            onPressed: () => provider.toggleDataUtilitiesSubView(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B88C6),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Explore more business plans',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 5B. EXPORT UTILITIES & DANGER ZONE + CONFIRM MODAL (image_8acf89.png & image_8ad24f.png)
/// ---------------------------------------------------------------------------
class _ExportAndDangerZoneSection extends StatelessWidget {
  final AdminDashboardProvider provider;
  final bool isMobile;

  const _ExportAndDangerZoneSection({
    required this.provider,
    required this.isMobile,
  });

  void _showDangerConfirmDialog(BuildContext context, String actionTitle) {
    final passwordCtrl = TextEditingController();
    String? errorMsg;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
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
                  const SizedBox(height: 12),
                  const Text(
                    'Are you Sure want to do this ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This will permanently wipe chosen data !\nEnter admin password to confirm',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter Password :',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: errorMsg != null
                                ? AppColors.brandRed
                                : const Color(0xFF93C5FD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D63ED),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      errorMsg!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.brandRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () {
                              if (passwordCtrl.text.trim().isEmpty) {
                                setDialogState(
                                  () => errorMsg = 'Enter admin password.',
                                );
                                return;
                              }
                              provider.executeDangerAction(actionTitle);
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDF3B47),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B88C6),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                fontSize: 12.5,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exportCard = _PanelCard(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Export Utilities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => provider.toggleDataUtilitiesSubView(false),
                child: const Text(
                  '← Plan',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B88C6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final item in const [
            'Export Customer DB',
            'Export Master inventory',
            'Export Sales history',
          ]) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exporting $item...')),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Download  ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2B88C6),
                        ),
                      ),
                      Icon(
                        Icons.cloud_download_outlined,
                        size: 16,
                        color: Color(0xFF2B88C6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: Color(0xFFE2E8F0)),
          ],
        ],
      ),
    );

    final dangerCard = Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDF3B47), width: 1.2),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_rounded,
                color: Color(0xFFF59E0B),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'DANGER ZONE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final btnLabel in const [
            'Delete Customer Database',
            'Clear Sales History',
            'Reset Everything',
          ]) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => _showDangerConfirmDialog(context, btnLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDF3B47),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    btnLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
          exportCard,
          const SizedBox(height: 16),
          dangerCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 52, child: exportCard),
        const SizedBox(width: 24),
        Expanded(flex: 38, child: dangerCard),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// SHARED ADMIN WIDGETS
/// ---------------------------------------------------------------------------
class _PanelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _PanelCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AvatarPlaceholderCircle extends StatelessWidget {
  const _AvatarPlaceholderCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: const BoxDecoration(
        color: Color(0xFF1E88E5),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 112,
        color: Color(0xFFFCD34D),
      ),
    );
  }
}

class _PhotoOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PhotoOutlineButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 106,
      height: 32,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RoundedFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const _RoundedFormField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 12.5),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2B88C6)),
          ),
        ),
      ),
    );
  }
}
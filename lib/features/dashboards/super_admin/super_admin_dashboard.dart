import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'models/super_admin_models.dart';
import 'providers/super_admin_provider.dart';

class SuperAdminDashboard extends StatelessWidget {
  final String title;

  const SuperAdminDashboard({super.key, this.title = 'Super Admin'});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperAdminProvider>();
    final bool isMobile = Responsive.isMobile(context);

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1D63ED)),
        ),
      );
    }

    final bool isStoresView = provider.selectedTab == SuperAdminNavTab.stores;
    final bool isDetailView =
        isStoresView && provider.selectedStoreForDetails != null;
    final bool isPlansView = provider.selectedTab == SuperAdminNavTab.plans;
    final bool isLogsView = provider.selectedTab == SuperAdminNavTab.logs;

    String headingText = 'Welcome back, Rupesh!';
    bool useRichGreeting = true;
    if (isDetailView) {
      headingText = 'User detailes';
      useRichGreeting = false;
    } else if (isStoresView) {
      headingText = 'Our users';
      useRichGreeting = false;
    } else if (isPlansView) {
      headingText = 'Manage plans';
      useRichGreeting = false;
    } else if (isLogsView) {
      headingText = 'Logs';
      useRichGreeting = false;
    }

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
                    child: _BlackSidebar(
                      selectedTab: provider.selectedTab,
                      unreadCount: provider.unreadNotificationCount,
                      onSelectTab: (tab) => provider.selectTab(tab),
                      onClose: () => provider.setSidebarOpen(false),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      provider.isSidebarOpen && !isMobile
                          ? 24
                          : (isMobile ? 20 : 72),
                      22,
                      isMobile ? 20 : 36,
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopHeaderBar(
                          headingText: headingText,
                          useRichGreeting: useRichGreeting,
                          showBrandLogo: !provider.isSidebarOpen,
                        ),
                        const SizedBox(height: 22),
                        _buildActiveTabView(context, provider, isMobile),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (!provider.isSidebarOpen)
              Positioned(
                top: 22,
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
                      width: 52,
                      height: 52,
                      child: Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

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
                      child: _BlackSidebar(
                        selectedTab: provider.selectedTab,
                        unreadCount: provider.unreadNotificationCount,
                        onSelectTab: (tab) {
                          provider.selectTab(tab);
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

  Widget _buildActiveTabView(
    BuildContext context,
    SuperAdminProvider provider,
    bool isMobile,
  ) {
    switch (provider.selectedTab) {
      case SuperAdminNavTab.dashboard:
        return _DashboardBentoGrid(provider: provider, isMobile: isMobile);
      case SuperAdminNavTab.stores:
        final detailStore = provider.selectedStoreForDetails;
        if (detailStore != null) {
          return _StoreDetailesSection(
            provider: provider,
            store: detailStore,
            isMobile: isMobile,
          );
        }
        return _OurUsersViewMoreSection(provider: provider, isMobile: isMobile);
      case SuperAdminNavTab.plans:
        return _PlansConfiguratorSection(provider: provider, isMobile: isMobile);
      case SuperAdminNavTab.logs:
        return _LogsTableSection(provider: provider, isMobile: isMobile);
      case SuperAdminNavTab.notification:
        return _AuditLogsSection(provider: provider, isNotifications: true);
      case SuperAdminNavTab.settings:
        return _PlatformSettingsSection(provider: provider);
    }
  }
}

class _TopHeaderBar extends StatelessWidget {
  final String headingText;
  final bool useRichGreeting;
  final bool showBrandLogo;

  const _TopHeaderBar({
    required this.headingText,
    required this.useRichGreeting,
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
              'Superadmin Dashboard',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6BA3D6),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            if (!useRichGreeting)
              Text(
                headingText,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              )
            else
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 28,
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
            height: 52,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'Steel suvidha',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class _BlackSidebar extends StatelessWidget {
  final SuperAdminNavTab selectedTab;
  final int unreadCount;
  final ValueChanged<SuperAdminNavTab> onSelectTab;
  final VoidCallback onClose;

  const _BlackSidebar({
    required this.selectedTab,
    required this.unreadCount,
    required this.onSelectTab,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 225,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'Steel suvidha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
          const SizedBox(height: 36),
          _SidebarNavTile(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            isSelected: selectedTab == SuperAdminNavTab.dashboard,
            onTap: () => onSelectTab(SuperAdminNavTab.dashboard),
          ),
          _SidebarNavTile(
            icon: Icons.storefront_outlined,
            label: 'Stores',
            isSelected: selectedTab == SuperAdminNavTab.stores,
            onTap: () => onSelectTab(SuperAdminNavTab.stores),
          ),
          _SidebarNavTile(
            icon: Icons.description_outlined,
            label: 'Plans',
            isSelected: selectedTab == SuperAdminNavTab.plans,
            onTap: () => onSelectTab(SuperAdminNavTab.plans),
          ),
          _SidebarNavTile(
            icon: Icons.history_rounded,
            label: 'Logs',
            isSelected: selectedTab == SuperAdminNavTab.logs,
            onTap: () => onSelectTab(SuperAdminNavTab.logs),
          ),
          _SidebarNavTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notification',
            badgeCount: unreadCount,
            isSelected: selectedTab == SuperAdminNavTab.notification,
            onTap: () => onSelectTab(SuperAdminNavTab.notification),
          ),
          _SidebarNavTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isSelected: selectedTab == SuperAdminNavTab.settings,
            onTap: () => onSelectTab(SuperAdminNavTab.settings),
          ),
          const Spacer(),
          InkWell(
            onTap: () => context.go('/workspace'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _SidebarNavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF60A5FA) : Colors.white,
              size: 19,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF60A5FA) : Colors.white,
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D63ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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
/// USER DETAILES VIEW (image_8047df.png)
/// ---------------------------------------------------------------------------
class _StoreDetailesSection extends StatelessWidget {
  final SuperAdminProvider provider;
  final StoreRecord store;
  final bool isMobile;

  const _StoreDetailesSection({
    required this.provider,
    required this.store,
    required this.isMobile,
  });

  void _showEditDetailsDialog(BuildContext context) {
    final storeCtrl = TextEditingController(text: store.storeName);
    final ownerCtrl = TextEditingController(text: store.ownerName);
    final emailCtrl = TextEditingController(text: store.email);
    final phoneCtrl = TextEditingController(text: store.phone);
    final validityCtrl = TextEditingController(text: store.validity);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Store & Owner Details',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: storeCtrl,
                  decoration: const InputDecoration(labelText: 'Store Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ownerCtrl,
                  decoration: const InputDecoration(labelText: 'Owner Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: validityCtrl,
                  decoration: const InputDecoration(labelText: 'Validity'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.updateStoreDetails(
                storeId: store.id,
                storeName: storeCtrl.text,
                ownerName: ownerCtrl.text,
                email: emailCtrl.text,
                phone: phoneCtrl.text,
                validity: validityCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showSuspendConfirmDialog(BuildContext context) {
    final passwordCtrl = TextEditingController();
    String? errorText;

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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
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
                  const SizedBox(height: 14),
                  const Text(
                    'Are you Sure want to do this ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            color: errorText != null
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
                  if (errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      errorText!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.brandRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              if (passwordCtrl.text.trim().isEmpty) {
                                setDialogState(() {
                                  errorText = 'Please enter password to confirm.';
                                });
                                return;
                              }
                              provider.toggleStoreStatus(store.id);
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 38,
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
                                fontSize: 13,
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

  Widget _buildTopSummaryBanner(BuildContext context) {
    return _BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                flex: 26,
                child: Text(
                  'Store Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 14,
                child: Center(
                  child: Text(
                    'Plan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 16,
                child: Center(
                  child: Text(
                    'Validity',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 14,
                child: Center(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(flex: 30, child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 26,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFFDBEAFE),
                      child: Icon(
                        Icons.person_rounded,
                        color: Color(0xFF1E3A8A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        store.storeName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 14,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFDBFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      store.planBadge,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 16,
                child: Center(
                  child: Text(
                    store.validity,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 14,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: store.isActive
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFFCA5A5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      store.isActive ? 'Active' : 'Suspended',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: store.isActive
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 108,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _showEditDetailsDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 118,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: store.isActive
                            ? () => _showSuspendConfirmDialog(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDF3B47),
                          disabledBackgroundColor: const Color(0xFF9CA3AF),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: store.isActive ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Suspend Account',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreAndOwnerCard() {
    return _BentoCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store and owner details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _DetailKVRow(label: 'Store :', value: store.storeName),
          _DetailKVRow(label: 'Owner :', value: store.ownerName),
          _DetailKVRow(label: 'Plan :', value: store.planTierLabel),
          _DetailKVRow(
            label: 'Status :',
            value: store.isActive ? 'Active' : 'Suspended',
          ),
          _DetailKVRow(label: 'Plan :', value: 'Enterprise'),
          _DetailKVRow(
            label: 'Staff :',
            value:
                '${store.salesUsed}/${store.salesQuota} sales   ${store.procureUsed}/${store.procureQuota} Procure',
          ),
          _DetailKVRow(label: 'Valid Until :', value: store.validity),
        ],
      ),
    );
  }

  Widget _buildBarStatCard({required String title}) {
    const bars = [0.27, 0.48, 0.64, 0.42, 0.27, 0.48, 0.64, 0.42];
    return _BentoCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'From 24Oct to Today',
                style: TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            width: double.infinity,
            child: CustomPaint(
              painter: _AxisBarChartPainter(bars: bars),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({required String title, required String value}) {
    return _BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSummaryBanner(context),
        const SizedBox(height: 18),
        if (isMobile) ...[
          _buildStoreAndOwnerCard(),
          const SizedBox(height: 16),
          _buildBarStatCard(title: 'Customers'),
          const SizedBox(height: 16),
          _buildBarStatCard(title: 'Orders'),
          const SizedBox(height: 16),
          _buildContactCard(title: 'Email :', value: store.email),
          const SizedBox(height: 12),
          _buildContactCard(title: 'Phone :', value: store.phone),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 38,
                child: _buildStoreAndOwnerCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 62,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildBarStatCard(title: 'Customers')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildBarStatCard(title: 'Orders')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactCard(
                            title: 'Email :',
                            value: store.email,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildContactCard(
                            title: 'Phone :',
                            value: store.phone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _DetailKVRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailKVRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisBarChartPainter extends CustomPainter {
  final List<double> bars;

  const _AxisBarChartPainter({required this.bars});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftAxisW = 24;
    const double bottomAxisH = 12;
    final double plotLeft = leftAxisW + 4;
    final double plotWidth = math.max(20, size.width - plotLeft);
    final double plotTop = 4;
    final double plotBottom = size.height - bottomAxisH;
    final double plotHeight = math.max(20, plotBottom - plotTop);

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.8;
    final axisPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0;

    final tp = TextPainter(textDirection: TextDirection.ltr);
    const ticks = [100, 80, 60, 40, 20, 0];

    for (int i = 0; i < ticks.length; i++) {
      final double y = plotTop + (plotHeight * i / (ticks.length - 1));
      canvas.drawLine(Offset(plotLeft, y), Offset(size.width, y), gridPaint);
      tp.text = TextSpan(
        text: '${ticks[i]}',
        style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8)),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    canvas.drawLine(
      Offset(plotLeft, plotBottom),
      Offset(size.width, plotBottom),
      axisPaint,
    );

    final barPaint = Paint()..color = const Color(0xFF2B7BB9);
    const double gap = 8;
    final double totalGap = gap * (bars.length - 1);
    final double barW = math.max(6, (plotWidth - totalGap - 16) / bars.length);

    for (int i = 0; i < bars.length; i++) {
      final double h = (plotHeight * bars[i].clamp(0.0, 1.0))
          .clamp(4.0, plotHeight);
      final double x = plotLeft + 10 + i * (barW + gap);
      final double y = plotBottom - h;
      canvas.drawRect(Rect.fromLTWH(x, y, barW, h), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AxisBarChartPainter oldDelegate) =>
      oldDelegate.bars != bars;
}

/// ---------------------------------------------------------------------------
/// LOGS VIEW WITH LAST ACTIVE COLUMN (image_80483b.png)
/// ---------------------------------------------------------------------------
class _LogsTableSection extends StatefulWidget {
  final SuperAdminProvider provider;
  final bool isMobile;

  const _LogsTableSection({
    required this.provider,
    required this.isMobile,
  });

  @override
  State<_LogsTableSection> createState() => _LogsTableSectionState();
}

class _LogsTableSectionState extends State<_LogsTableSection> {
  int _currentPage = 1;
  static const double _rowHeight = 52.0;

  void _showSuspendConfirmDialog(BuildContext context, StoreRecord store) {
    final passwordCtrl = TextEditingController();
    String? errorText;

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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
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
                  const SizedBox(height: 14),
                  const Text(
                    'Are you Sure want to do this ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            color: errorText != null
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
                  if (errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      errorText!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.brandRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              if (passwordCtrl.text.trim().isEmpty) {
                                setDialogState(() {
                                  errorText = 'Please enter password to confirm.';
                                });
                                return;
                              }
                              widget.provider.toggleStoreStatus(store.id);
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 38,
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
                                fontSize: 13,
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
    final allFiltered = widget.provider.filteredStores;
    final double screenH = MediaQuery.sizeOf(context).height;
    final double availableRowsHeight = math.max(_rowHeight, screenH - 256.0);
    final int rowsPerPage =
        math.max(1, (availableRowsHeight / _rowHeight).floor());

    final int totalPages = math.max(1, (allFiltered.length / rowsPerPage).ceil());
    final int safePage = _currentPage.clamp(1, totalPages);
    final int startIdx = (safePage - 1) * rowsPerPage;
    final pageStores = allFiltered.skip(startIdx).take(rowsPerPage).toList();
    final double fullCardMinHeight = math.max(360.0, screenH - 185.0);

    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: fullCardMinHeight),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 25,
                    child: Text(
                      'Store Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 12,
                    child: Center(
                      child: Text(
                        'Plan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 15,
                    child: Center(
                      child: Text(
                        'Last active',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 14,
                    child: Center(
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 34,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: widget.isMobile ? 160 : 250,
                        height: 36,
                        child: TextField(
                          onChanged: (q) {
                            widget.provider.setStoreSearchQuery(q);
                            setState(() => _currentPage = 1);
                          },
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Search Stores/Owners',
                            hintStyle: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final store in pageStores)
                SizedBox(
                  height: _rowHeight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 25,
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 17,
                              backgroundColor: Color(0xFFDBEAFE),
                              child: Icon(
                                Icons.person_rounded,
                                color: Color(0xFF1E3A8A),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                store.storeName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 12,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBFDBFE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              store.planBadge,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 15,
                        child: Center(
                          child: Text(
                            store.lastActive,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 14,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: store.isActive
                                  ? const Color(0xFFBBF7D0)
                                  : const Color(0xFFFCA5A5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              store.isActive ? 'Active' : 'Suspended',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: store.isActive
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 34,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 108,
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () =>
                                    widget.provider.openStoreDetails(store.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 118,
                              height: 32,
                              child: ElevatedButton(
                                onPressed: store.isActive
                                    ? () => _showSuspendConfirmDialog(
                                          context,
                                          store,
                                        )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDF3B47),
                                  disabledBackgroundColor:
                                      const Color(0xFF9CA3AF),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: store.isActive ? 2 : 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Suspend Account',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int p = 1; p <= totalPages; p++) ...[
              if (p > 1) const SizedBox(width: 10),
              _PagePillButton(
                label: '$p',
                isSelected: safePage == p,
                onTap: () => setState(() => _currentPage = p),
              ),
            ],
            if (totalPages > 1) ...[
              const SizedBox(width: 10),
              InkWell(
                onTap: () => setState(() {
                  _currentPage = safePage < totalPages ? safePage + 1 : 1;
                }),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 52,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// MANAGE PLANS VIEW (image_804b25.png)
/// ---------------------------------------------------------------------------
class _PlansConfiguratorSection extends StatefulWidget {
  final SuperAdminProvider provider;
  final bool isMobile;

  const _PlansConfiguratorSection({
    required this.provider,
    required this.isMobile,
  });

  @override
  State<_PlansConfiguratorSection> createState() =>
      _PlansConfiguratorSectionState();
}

class _PlansConfiguratorSectionState extends State<_PlansConfiguratorSection> {
  String? _selectedPlanId;

  String _formatInrNoSpace(int price) {
    final s = price.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    return '₹$rest,$last3';
  }

  void _showPlanEditorDialog(
    BuildContext context, {
    SubscriptionPlanConfig? existing,
  }) {
    final nameCtrl = TextEditingController(text: existing?.name ?? 'Basic');
    final badgeCtrl = TextEditingController(text: existing?.badge ?? 'BASE');
    final priceCtrl = TextEditingController(
      text: (existing?.monthlyPriceInr ?? 5000).toString(),
    );
    final adminCtrl =
        TextEditingController(text: (existing?.maxAdmins ?? 2).toString());
    final salesCtrl = TextEditingController(
      text: (existing?.maxSalesPanels ?? 4).toString(),
    );
    final procureCtrl = TextEditingController(
      text: (existing?.maxProcessingPanels ?? 8).toString(),
    );
    final featuresCtrl = TextEditingController(
      text: existing?.featuresSummary ??
          'Admin | Sales | Procurement + Basic day book (with download)',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          existing == null ? 'Create New Plan' : 'Edit ${existing.name} Plan',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Plan Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: badgeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Badge (e.g. BASE, GROWTH)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Monthly Price (₹)'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: adminCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Admins'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: salesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Sales'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: procureCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Procurement'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: featuresCtrl,
                  decoration: const InputDecoration(labelText: 'Features Line'),
                ),
              ],
            ),
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
              final price = int.tryParse(priceCtrl.text.trim()) ?? 5000;
              final admins = int.tryParse(adminCtrl.text.trim()) ?? 2;
              final sales = int.tryParse(salesCtrl.text.trim()) ?? 4;
              final procure = int.tryParse(procureCtrl.text.trim()) ?? 8;

              if (existing == null) {
                widget.provider.createPlan(
                  name: nameCtrl.text,
                  badge: badgeCtrl.text,
                  monthlyPriceInr: price,
                  maxAdmins: admins,
                  maxSalesPanels: sales,
                  maxProcessingPanels: procure,
                  featuresSummary: featuresCtrl.text,
                );
              } else {
                widget.provider.updatePlanConfig(
                  planId: existing.id,
                  name: nameCtrl.text,
                  badge: badgeCtrl.text,
                  monthlyPriceInr: price,
                  maxAdmins: admins,
                  maxSalesPanels: sales,
                  maxProcessingPanels: procure,
                  featuresSummary: featuresCtrl.text,
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'Create Plan' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _handleRemovePlan(BuildContext context) {
    final plans = widget.provider.plans;
    if (plans.isEmpty) return;

    final targetId = _selectedPlanId ?? plans.last.id;
    widget.provider.removePlan(targetId);
    setState(() => _selectedPlanId = null);
  }

  @override
  Widget build(BuildContext context) {
    final plans = widget.provider.plans;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Top Action Buttons: + Create New Plan & Remove Plan
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => _showPlanEditorDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Create New Plan',
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
            const SizedBox(width: 14),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: plans.isEmpty ? null : () => _handleRemovePlan(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDF3B47),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Remove Plan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        if (plans.isEmpty)
          _BentoCard(
            padding: const EdgeInsets.all(36),
            child: const Center(
              child: Text(
                'No plans configured. Tap "+ Create New Plan" to add one.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          for (final plan in plans) ...[
            GestureDetector(
              onTap: () => setState(() => _selectedPlanId = plan.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _selectedPlanId == plan.id
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: _selectedPlanId == plan.id ? 1.5 : 1.0,
                  ),
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
                    // Left: Plan Title & Price
                    SizedBox(
                      width: widget.isMobile ? 105 : 170,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatInrNoSpace(plan.monthlyPriceInr),
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

                    // Vertical Divider
                    Container(
                      width: 1,
                      height: 76,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: const Color(0xFFCBD5E1),
                    ),

                    // Center: Badge + Staff Panel + Features
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBFDBFE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              plan.badge,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Staff Panel : ${plan.maxAdmins} Admin | ${plan.maxSalesPanels} Sales | ${plan.maxProcessingPanels} Procurement',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Features : ${plan.featuresSummary}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right: Edit Button
                    SizedBox(
                      width: 78,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () =>
                            _showPlanEditorDialog(context, existing: plan),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D63ED),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// OUR USERS (VIEW MORE) SCREEN WITH DYNAMIC PAGINATION
/// ---------------------------------------------------------------------------
class _OurUsersViewMoreSection extends StatefulWidget {
  final SuperAdminProvider provider;
  final bool isMobile;

  const _OurUsersViewMoreSection({
    required this.provider,
    required this.isMobile,
  });

  @override
  State<_OurUsersViewMoreSection> createState() =>
      _OurUsersViewMoreSectionState();
}

class _OurUsersViewMoreSectionState extends State<_OurUsersViewMoreSection> {
  int _currentPage = 1;
  static const double _rowHeight = 54.0;

  void _showSuspendConfirmDialog(BuildContext context, StoreRecord store) {
    final passwordCtrl = TextEditingController();
    String? errorText;

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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
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
                  const SizedBox(height: 14),
                  const Text(
                    'Are you Sure want to do this ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            color: errorText != null
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
                  if (errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      errorText!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.brandRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              if (passwordCtrl.text.trim().isEmpty) {
                                setDialogState(() {
                                  errorText = 'Please enter password to confirm.';
                                });
                                return;
                              }
                              widget.provider.toggleStoreStatus(store.id);
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 38,
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
                                fontSize: 13,
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
    final allFiltered = widget.provider.filteredStores;
    final double screenH = MediaQuery.sizeOf(context).height;
    final double availableRowsHeight = math.max(_rowHeight, screenH - 256.0);
    final int rowsPerPage =
        math.max(1, (availableRowsHeight / _rowHeight).floor());

    final int totalPages = math.max(1, (allFiltered.length / rowsPerPage).ceil());
    final int safePage = _currentPage.clamp(1, totalPages);
    final int startIdx = (safePage - 1) * rowsPerPage;
    final pageStores = allFiltered.skip(startIdx).take(rowsPerPage).toList();
    final double fullCardMinHeight = math.max(360.0, screenH - 185.0);

    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: fullCardMinHeight),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 25,
                    child: Text(
                      'Store Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 12,
                    child: Center(
                      child: Text(
                        'Plan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 15,
                    child: Center(
                      child: Text(
                        'Validity',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 14,
                    child: Center(
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 34,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: widget.isMobile ? 160 : 250,
                        height: 36,
                        child: TextField(
                          onChanged: (q) {
                            widget.provider.setStoreSearchQuery(q);
                            setState(() => _currentPage = 1);
                          },
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Search Stores/Owners',
                            hintStyle: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final store in pageStores)
                SizedBox(
                  height: _rowHeight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 25,
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 17,
                              backgroundColor: Color(0xFFDBEAFE),
                              child: Icon(
                                Icons.person_rounded,
                                color: Color(0xFF1E3A8A),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                store.storeName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 12,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBFDBFE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              store.planBadge,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 15,
                        child: Center(
                          child: Text(
                            store.validity,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 14,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: store.isActive
                                  ? const Color(0xFFBBF7D0)
                                  : const Color(0xFFFCA5A5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              store.isActive ? 'Active' : 'Suspended',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: store.isActive
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 34,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 108,
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () =>
                                    widget.provider.openStoreDetails(store.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 118,
                              height: 32,
                              child: ElevatedButton(
                                onPressed: store.isActive
                                    ? () => _showSuspendConfirmDialog(
                                          context,
                                          store,
                                        )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDF3B47),
                                  disabledBackgroundColor:
                                      const Color(0xFF9CA3AF),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: store.isActive ? 2 : 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Suspend Account',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int p = 1; p <= totalPages; p++) ...[
              if (p > 1) const SizedBox(width: 10),
              _PagePillButton(
                label: '$p',
                isSelected: safePage == p,
                onTap: () => setState(() => _currentPage = p),
              ),
            ],
            if (totalPages > 1) ...[
              const SizedBox(width: 10),
              InkWell(
                onTap: () => setState(() {
                  _currentPage = safePage < totalPages ? safePage + 1 : 1;
                }),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 52,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PagePillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PagePillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? const Color(0xFF2563EB)
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// DASHBOARD BENTO GRID
/// ---------------------------------------------------------------------------
class _DashboardBentoGrid extends StatelessWidget {
  final SuperAdminProvider provider;
  final bool isMobile;

  const _DashboardBentoGrid({
    required this.provider,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final stores = provider.allStores;

    if (isMobile) {
      return Column(
        children: [
          _ActiveStoresCard(
            count: provider.activeStoresCount,
            bars: provider.activeStoreChartBars,
            onTap: () => provider.selectTab(SuperAdminNavTab.stores),
          ),
          const SizedBox(height: 16),
          _MetricTrendCard(
            title: 'Monthly\nReccuring\nRevenue (MRR)',
            value: provider.formattedMrr,
            points: provider.mrrTrendPoints,
          ),
          const SizedBox(height: 16),
          _OurUsersCard(
            stores: stores,
            onViewMore: () => provider.selectTab(SuperAdminNavTab.stores),
          ),
          const SizedBox(height: 16),
          _MetricTrendCard(
            title: 'Total Users',
            value: '${provider.totalUsersCount}',
            points: provider.totalUsersTrendPoints,
          ),
          const SizedBox(height: 16),
          _GroupedBarCard(
            title: 'User Growth',
            series: provider.userGrowthSeries,
          ),
          const SizedBox(height: 16),
          _GroupedBarCard(
            title: 'Recent Revenue',
            series: provider.recentRevenueSeries,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 48,
          child: Column(
            children: [
              _ActiveStoresCard(
                count: provider.activeStoresCount,
                bars: provider.activeStoreChartBars,
                onTap: () => provider.selectTab(SuperAdminNavTab.stores),
              ),
              const SizedBox(height: 18),
              _OurUsersCard(
                stores: stores,
                onViewMore: () => provider.selectTab(SuperAdminNavTab.stores),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 52,
          child: Column(
            children: [
              _MetricTrendCard(
                title: 'Monthly\nReccuring\nRevenue (MRR)',
                value: provider.formattedMrr,
                points: provider.mrrTrendPoints,
              ),
              const SizedBox(height: 18),
              _MetricTrendCard(
                title: 'Total Users',
                value: '${provider.totalUsersCount}',
                points: provider.totalUsersTrendPoints,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _GroupedBarCard(
                      title: 'User Growth',
                      series: provider.userGrowthSeries,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GroupedBarCard(
                      title: 'Recent Revenue',
                      series: provider.recentRevenueSeries,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuditLogsSection extends StatelessWidget {
  final SuperAdminProvider provider;
  final bool isNotifications;

  const _AuditLogsSection({
    required this.provider,
    required this.isNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNotifications ? 'Platform Notifications' : 'System Audit Logs',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          for (final log in provider.logs)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF1D63ED),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.action,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          log.detail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlatformSettingsSection extends StatelessWidget {
  final SuperAdminProvider provider;

  const _PlatformSettingsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Controls & Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Auto-Approve New Store Registrations',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Automatically activate newly registered stores upon sign-up.',
              style: TextStyle(fontSize: 12),
            ),
            value: provider.autoApproveStores,
            activeColor: const Color(0xFF1D63ED),
            onChanged: provider.setAutoApproveStores,
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Platform Maintenance Mode',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Temporarily pause non-superadmin logins during scheduled upgrades.',
              style: TextStyle(fontSize: 12),
            ),
            value: provider.maintenanceMode,
            activeColor: AppColors.brandRed,
            onChanged: provider.setMaintenanceMode,
          ),
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _BentoCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActiveStoresCard extends StatelessWidget {
  final int count;
  final List<double> bars;
  final VoidCallback onTap;

  const _ActiveStoresCard({
    required this.count,
    required this.bars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: _BentoCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Stores',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 92,
                child: CustomPaint(
                  painter: _BlueBarChartPainter(bars: bars),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTrendCard extends StatelessWidget {
  final String title;
  final String value;
  final List<double> points;

  const _MetricTrendCard({
    required this.title,
    required this.value,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 55,
            child: SizedBox(
              height: 88,
              child: CustomPaint(
                painter: _TrendLineChartPainter(points: points),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OurUsersCard extends StatelessWidget {
  final List<StoreRecord> stores;
  final VoidCallback onViewMore;

  const _OurUsersCard({
    required this.stores,
    required this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    final visibleStores = stores.take(6).toList();

    return _BentoCard(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Our Users',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: onViewMore,
                child: const Text(
                  'View More',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D63ED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'Store Name',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Plan',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Validity',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final store in visibleStores) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFDBEAFE),
                          child: Icon(
                            Icons.person_rounded,
                            color: Color(0xFF1E3A8A),
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            store.storeName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBFDBFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          store.planBadge,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        store.validity,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupedBarCard extends StatelessWidget {
  final String title;
  final List<GroupedChartSeries> series;

  const _GroupedBarCard({
    required this.title,
    required this.series,
  });

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 118,
            width: double.infinity,
            child: CustomPaint(
              painter: _GroupedBarChartPainter(series: series),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Color(0xFF56B7A6), label: 'Base'),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFF2563EB), label: 'Growth'),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFF1E293B), label: 'Enterprise'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _BlueBarChartPainter extends CustomPainter {
  final List<double> bars;

  const _BlueBarChartPainter({required this.bars});

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final paint = Paint()..color = const Color(0xFF2B7BB9);
    const double gap = 6;
    final double totalGap = gap * (bars.length - 1);
    final double barWidth = math.max(6, (size.width - totalGap) / bars.length);

    for (int i = 0; i < bars.length; i++) {
      final double barHeight = (size.height * bars[i]).clamp(12.0, size.height);
      final double x = i * (barWidth + gap);
      final double y = size.height - barHeight;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlueBarChartPainter oldDelegate) =>
      oldDelegate.bars != bars;
}

class _TrendLineChartPainter extends CustomPainter {
  final List<double> points;

  const _TrendLineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final double bottomY = size.height - 6;
    final double topY = 8;
    final double usableHeight = bottomY - topY;
    final double leftX = 6;
    final double usableWidth = size.width - 12;

    canvas.drawLine(
      Offset(0, bottomY),
      Offset(size.width, bottomY),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 1.2,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF0F175E)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF0F175E)
      ..style = PaintingStyle.fill;

    final path = Path();
    final List<Offset> offsets = [];

    for (int i = 0; i < points.length; i++) {
      final double x = leftX + (usableWidth * i / (points.length - 1));
      final double y = bottomY - (usableHeight * points[i].clamp(0.0, 1.0));
      offsets.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
    for (final pt in offsets) {
      canvas.drawCircle(pt, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLineChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

class _GroupedBarChartPainter extends CustomPainter {
  final List<GroupedChartSeries> series;

  const _GroupedBarChartPainter({required this.series});

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final double chartBottom = size.height - 16;
    final double chartTop = 10;
    final double chartHeight = chartBottom - chartTop;
    const double maxMetric = 5.0;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.8;
    for (int g = 0; g <= 3; g++) {
      final double y = chartTop + (chartHeight * g / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double groupWidth = size.width / series.length;
    const double barGap = 1.5;

    final paintA = Paint()..color = const Color(0xFF56B7A6);
    final paintB = Paint()..color = const Color(0xFF2563EB);
    final paintC = Paint()..color = const Color(0xFF1E293B);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < series.length; i++) {
      final item = series[i];
      final double groupLeft = i * groupWidth + 3;
      final double usableGroupW = math.max(9.0, groupWidth - 6);
      final double singleBarW = math.max(2.5, (usableGroupW - barGap * 2) / 3);

      final vals = [item.valueA, item.valueB, item.valueC];
      final paints = [paintA, paintB, paintC];

      for (int b = 0; b < 3; b++) {
        final double h =
            (chartHeight * (vals[b] / maxMetric)).clamp(4.0, chartHeight);
        final double x = groupLeft + b * (singleBarW + barGap);
        final double y = chartBottom - h;
        canvas.drawRect(Rect.fromLTWH(x, y, singleBarW, h), paints[b]);
      }

      textPainter.text = TextSpan(
        text: item.label,
        style: const TextStyle(
          fontSize: 7,
          color: AppColors.textSecondary,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          i * groupWidth + (groupWidth - textPainter.width) / 2,
          chartBottom + 3,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GroupedBarChartPainter oldDelegate) =>
      oldDelegate.series != series;
}
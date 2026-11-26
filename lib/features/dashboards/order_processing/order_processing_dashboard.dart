import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'models/processing_models.dart';
import 'providers/processing_dashboard_provider.dart';

class OrderProcessingTeamDashboard extends ProcessingDashboard {
  const OrderProcessingTeamDashboard({
    super.key,
    super.title = 'Order Processing Team',
  });
}

class OrderProcessingDashboard extends ProcessingDashboard {
  const OrderProcessingDashboard({
    super.key,
    super.title = 'Order Processing',
  });
}

class ProcessingDashboard extends StatelessWidget {
  final String title;

  const ProcessingDashboard({super.key, this.title = 'Order Processing'});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProcessingDashboardProvider(),
      child: const _ProcessingDashboardScaffold(),
    );
  }
}

class _ProcessingDashboardScaffold extends StatelessWidget {
  const _ProcessingDashboardScaffold();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProcessingDashboardProvider>();
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPad = provider.isSidebarOpen && !isMobile
                ? 22.0
                : (isMobile ? 14.0 : 62.0);

            return Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (provider.isSidebarOpen && !isMobile)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                        child: _ProcessingBlackSidebar(
                          onSelectOrders: () {
                            provider.backToOrdersList();
                            provider.setSidebarOpen(false);
                          },
                          onClose: () => provider.setSidebarOpen(false),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPad,
                          16,
                          isMobile ? 14 : 28,
                          20,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 36,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ProcessingHeaderBar(
                                    showLogo: !provider.isSidebarOpen,
                                    onTitleTap: provider.backToOrdersList,
                                  ),
                                  const SizedBox(height: 16),
                                  if (provider.isDetailView &&
                                      provider.activeOrder != null)
                                    _OrderWeightDetailsView(
                                      key: ValueKey(provider.activeOrder!.id),
                                      order: provider.activeOrder!,
                                      provider: provider,
                                      isMobile: isMobile,
                                      viewportHeight: constraints.maxHeight,
                                    )
                                  else
                                    _OrdersQueueGridView(
                                      provider: provider,
                                      isMobile: isMobile,
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
                          child: _ProcessingBlackSidebar(
                            onSelectOrders: () {
                              provider.backToOrdersList();
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
}

class _ProcessingHeaderBar extends StatelessWidget {
  final bool showLogo;
  final VoidCallback onTitleTap;

  const _ProcessingHeaderBar({
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Processing Team',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6BA3D6),
                  height: 1.15,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Orders',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
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

class _ProcessingBlackSidebar extends StatelessWidget {
  final VoidCallback onSelectOrders;
  final VoidCallback onClose;

  const _ProcessingBlackSidebar({
    required this.onSelectOrders,
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
          const SizedBox(height: 28),
          InkWell(
            onTap: onSelectOrders,
            child: const Row(
              children: [
                Icon(Icons.inventory_rounded, color: Color(0xFF60A5FA), size: 18),
                SizedBox(width: 12),
                Text(
                  'Orders Queue',
                  style: TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
}

/// ---------------------------------------------------------------------------
/// 1. ORDERS QUEUE VIEW
/// ---------------------------------------------------------------------------
class _OrdersQueueGridView extends StatelessWidget {
  final ProcessingDashboardProvider provider;
  final bool isMobile;

  const _OrdersQueueGridView({
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
                    for (int i = 0; i < ProcessingOrderStatus.values.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      _ProcessingFilterChip(
                        label: ProcessingOrderStatus.values[i].label,
                        isSelected:
                            provider.selectedFilter == ProcessingOrderStatus.values[i],
                        onTap: () =>
                            provider.setFilter(ProcessingOrderStatus.values[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: isMobile ? 160 : 275,
              height: 36,
              child: TextField(
                onChanged: provider.setSearchQuery,
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
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (orders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: _processingCardDecoration(),
            child: const Center(
              child: Text(
                'No matching orders in queue.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.15 : 1.72,
            ),
            itemBuilder: (context, idx) => _ProcessingOrderCard(
              order: orders[idx],
              onViewDetails: () => provider.openOrderDetails(orders[idx].id),
            ),
          ),
        const SizedBox(height: 18),
        _ProcessingPaginationBar(
          currentPage: provider.currentPage,
          totalPages: provider.totalPages,
          onSelectPage: provider.setPage,
          onNext: provider.nextPage,
        ),
      ],
    );
  }
}

class _ProcessingOrderCard extends StatelessWidget {
  final ProcessingOrderItem order;
  final VoidCallback onViewDetails;

  const _ProcessingOrderCard({
    required this.order,
    required this.onViewDetails,
  });

  (Color bg, Color fg) _badgeColors(String status) {
    if (status.toLowerCase() == 'pending') {
      return (const Color(0xFFFCA5A5), const Color(0xFF991B1B));
    }
    return (const Color(0xFFBEF264), const Color(0xFF365314));
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badgeColors(order.status);

    return Container(
      decoration: _processingCardDecoration(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderCode,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badge.$1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badge.$2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.timeAgo,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              Text(
                order.companyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              Text(
                order.itemsSummary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 2. ORDER DETAILS & MEASURED WEIGHTS VIEW
/// ---------------------------------------------------------------------------
class _OrderWeightDetailsView extends StatefulWidget {
  final ProcessingOrderItem order;
  final ProcessingDashboardProvider provider;
  final bool isMobile;
  final double viewportHeight;

  const _OrderWeightDetailsView({
    super.key,
    required this.order,
    required this.provider,
    required this.isMobile,
    required this.viewportHeight,
  });

  @override
  State<_OrderWeightDetailsView> createState() =>
      _OrderWeightDetailsViewState();
}

class _OrderWeightDetailsViewState extends State<_OrderWeightDetailsView> {
  late final List<TextEditingController> _weightControllers;
  late final List<TextEditingController> _notesControllers;

  @override
  void initState() {
    super.initState();
    _weightControllers = widget.order.weightLines
        .map((line) => TextEditingController(text: line.exactWeightKg))
        .toList();
    _notesControllers = widget.order.weightLines
        .map((line) => TextEditingController(text: line.notes))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _weightControllers) {
      c.dispose();
    }
    for (final c in _notesControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSubmitWeights() {
    widget.provider.submitMeasuredWeights(
      orderId: widget.order.id,
      weights: _weightControllers.map((c) => c.text).toList(),
      notes: _notesControllers.map((c) => c.text).toList(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Measured weights saved for ${widget.order.orderCode}.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableMinHeight = (widget.viewportHeight - 235).clamp(280.0, 440.0);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: widget.isMobile ? double.infinity : 470,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: _processingCardDecoration(),
            child: Row(
              children: [
                Expanded(
                  flex: 45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        widget.order.orderCode.replaceFirst('Order ', ''),
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
                Container(
                  width: 1,
                  height: 52,
                  color: const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.customerName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.order.companyName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.order.itemsSummary,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: tableMinHeight),
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
          decoration: _processingCardDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 34,
                      child: Text(
                        'Product name and category',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 18,
                      child: Text(
                        'Estimated',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 22,
                      child: Text(
                        'Exact Weight',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 26,
                      child: Text(
                        'Notes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (int i = 0; i < widget.order.weightLines.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 34,
                        child: Text(
                          widget.order.weightLines[i].productNameAndCategory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Text(
                          widget.order.weightLines[i].estimatedLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 22,
                        child: Center(
                          child: SizedBox(
                            width: 145,
                            height: 28,
                            child: TextField(
                              controller: _weightControllers[i],
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 11.5),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                suffixText: 'Kg',
                                suffixStyle: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.textPrimary,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF3B82F6),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 26,
                        child: Center(
                          child: SizedBox(
                            width: 165,
                            height: 28,
                            child: TextField(
                              controller: _notesControllers[i],
                              style: const TextStyle(fontSize: 11.5),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.textPrimary,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF3B82F6),
                                    width: 1.5,
                                  ),
                                ),
                              ),
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
        const SizedBox(height: 16),
        SizedBox(
          width: 245,
          height: 38,
          child: ElevatedButton(
            onPressed: _onSubmitWeights,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit Measured Weights',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// SHARED PROCESSING WIDGETS
/// ---------------------------------------------------------------------------
BoxDecoration _processingCardDecoration() {
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

class _ProcessingFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProcessingFilterChip({
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

class _ProcessingPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onSelectPage;
  final VoidCallback onNext;

  const _ProcessingPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onSelectPage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final pagesCount = totalPages.clamp(1, 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int p = 1; p <= pagesCount; p++) ...[
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
                      ? const Color(0xFF3B82F6)
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
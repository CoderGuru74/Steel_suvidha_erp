import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';

class ProductIntroScreen extends StatefulWidget {
  const ProductIntroScreen({super.key});

  @override
  State<ProductIntroScreen> createState() => _ProductIntroScreenState();
}

class _ProductIntroScreenState extends State<ProductIntroScreen> {
  bool _isMenuOpen = false;

  Widget _buildLogo({double? height}) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Text(
        'Steel Suvidha',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double brandLogoWidth =
        (MediaQuery.sizeOf(context).width * 0.28).clamp(190.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                // Left Brand & Value Proposition Column (Tablet / Desktop)
                if (!isMobile) ...[
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 44.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: brandLogoWidth,
                            ),
                            child: _buildLogo(),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF93C5FD),
                              ),
                            ),
                            child: const Text(
                              'Complete ERP for Steel Dealers & Distributors',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D63ED),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Manage TMT bars, coils, structural stock, sales orders, dispatch slips, and daily cashbooks from one unified workspace.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 48),
                    color: AppColors.border,
                  ),
                ],

                // Right Feature Highlights & Action Column
                Expanded(
                  flex: 5,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24.0 : 48.0,
                        vertical: 28.0,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isMobile) ...[
                              Center(child: _buildLogo(height: 44)),
                              const SizedBox(height: 20),
                            ],
                            const Text(
                              'Run Your Steel Business',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.15,
                              ),
                            ),
                            const Text(
                              'Smarter & Faster',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Built specifically for steel yards, wholesalers, and multi-counter retail stores.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 22),

                            const _FeatureTile(
                              icon: Icons.inventory_2_outlined,
                              title: 'Real-Time Yard & Godown Inventory',
                              subtitle:
                                  'Track stock by brand, thickness, bundle count, and metric tonnage with instant low-stock alerts.',
                            ),
                            const SizedBox(height: 12),
                            const _FeatureTile(
                              icon: Icons.point_of_sale_outlined,
                              title: 'Role-Based Sales & Order Processing',
                              subtitle:
                                  'Dedicated panels for Sales, Loading/Dispatch teams, and Admin with role-passcode security.',
                            ),
                            const SizedBox(height: 12),
                            const _FeatureTile(
                              icon: Icons.receipt_long_outlined,
                              title: 'Automated GST Billing & Daybook',
                              subtitle:
                                  'Generate GST-ready invoices, track party credit ledgers, and export daily cash/bank daybooks.',
                            ),
                            const SizedBox(height: 26),

                            // Primary CTA: View Plans & Get Software
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1D63ED),
                                      Color(0xFF3B82F6),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB)
                                          .withOpacity(0.28),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => context.push('/plans'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Get Steel Suvidha  •  View Plans',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Secondary CTA: Already have an account -> Sign in
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton(
                                onPressed: () => context.go('/login'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF93C5FD),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Already Registered? Sign in to Workspace',
                                  style: TextStyle(
                                    fontSize: 13,
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
                  ),
                ),
              ],
            ),

            // Top-left Black Hamburger Button
            Positioned(
              top: 20,
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
                  onTap: () => setState(() => _isMenuOpen = !_isMenuOpen),
                  child: const SizedBox(
                    width: 54,
                    height: 54,
                    child: Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            if (_isMenuOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isMenuOpen = false),
                  child: Container(
                    color: Colors.black38,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 240,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildLogo(height: 28),
                            ),
                            const SizedBox(height: 36),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.workspace_premium_outlined,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Plans & Pricing',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () {
                                setState(() => _isMenuOpen = false);
                                context.push('/plans');
                              },
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.login_rounded,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () => context.go('/login'),
                            ),
                          ],
                        ),
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
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1D63ED), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String transactionId;

  const PaymentSuccessScreen({
    super.key,
    this.transactionId = '1273432846902',
  });

  String _formattedNow() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(now.day)}/${two(now.month)}/${now.year}  '
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double brandLogoWidth =
        (MediaQuery.sizeOf(context).width * 0.28).clamp(180.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) ...[
              Expanded(
                flex: 5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: brandLogoWidth),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text(
                          'Steel Suvidha',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 48),
                color: AppColors.border,
              ),
            ],
            Expanded(
              flex: 5,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 48.0,
                    vertical: 28.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your payment was',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.15,
                          ),
                        ),
                        const Text(
                          'Received Successfully 🎉',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Receipt Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF22C55E),
                                    width: 5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 64,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Payment Successful',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'ID - $transactionId\n${_formattedNow()}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 22),
                              const Text(
                                'Wohooo! You have paid successfully\nPlease click on Done to proceed',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Done -> Proceed to Store Setup / Registration
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1D63ED),
                                        Color(0xFF3B82F6),
                                      ],
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => context.go('/store-setup'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Done',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Back to home -> Product Intro
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: OutlinedButton.icon(
                                  onPressed: () => context.go('/intro'),
                                  icon: const Icon(
                                    Icons.arrow_circle_left_outlined,
                                    size: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                  label: const Text(
                                    'Back to home',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: AppColors.textPrimary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
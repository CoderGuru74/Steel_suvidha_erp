import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/store_setup_screen.dart';
import '../../features/auth/screens/verification_code_screen.dart';
import '../../features/auth/screens/workspace_select_screen.dart';
import '../../features/dashboards/admin/admin_dashboard.dart';
import '../../features/dashboards/daybook/daybook_dashboard.dart';
import '../../features/dashboards/inventory/inventory_dashboard.dart';
import '../../features/dashboards/order_processing/order_processing_dashboard.dart';
import '../../features/dashboards/sales/sales_dashboard.dart';
import '../../features/dashboards/super_admin/super_admin_dashboard.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/subscription/models/plan_model.dart';
import '../../features/subscription/screens/checkout_screen.dart';
import '../../features/subscription/screens/payment_success_screen.dart';
import '../../features/subscription/screens/plans_pricing_screen.dart';
import '../../features/subscription/screens/product_intro_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/intro', builder: (_, __) => const ProductIntroScreen()),
    GoRoute(path: '/plans', builder: (_, __) => const PlansPricingScreen()),
    GoRoute(
      path: '/checkout',
      builder: (_, state) {
        final plan = (state.extra as PlanModel?) ?? PlanModel.defaultPlans.first;
        return CheckoutScreen(plan: plan);
      },
    ),
    GoRoute(
      path: '/payment-success',
      builder: (_, state) {
        final txnId = (state.extra as String?) ?? '1273432846902';
        return PaymentSuccessScreen(transactionId: txnId);
      },
    ),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/store-setup', builder: (_, __) => const StoreSetupScreen()),
    GoRoute(
      path: '/workspace',
      builder: (_, __) => const WorkspaceSelectScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (_, __) => const VerificationCodeScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/super-admin',
      builder: (_, __) => const SuperAdminDashboard(title: 'Super Admin'),
    ),
    GoRoute(
      path: '/admin',
      builder: (_, __) => const AdminDashboard(title: 'Admin'),
    ),
    GoRoute(
      path: '/inventory',
      builder: (_, __) =>
          const InventoryManagementDashboard(title: 'Inventory Management'),
    ),
    GoRoute(
      path: '/sales',
      builder: (_, __) => const SalesPanelDashboard(title: 'Sales Panel'),
    ),
    GoRoute(
      path: '/orders',
      builder: (_, __) =>
          const OrderProcessingTeamDashboard(title: 'Order Processing Team'),
    ),
    GoRoute(
      path: '/daybook',
      builder: (_, __) =>
          const DaybookManagementDashboard(title: 'Daybook Management'),
    ),
  ],
);
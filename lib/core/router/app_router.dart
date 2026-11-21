import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboards/admin/admin_dashboard.dart';
import '../../features/dashboards/daybook/daybook_dashboard.dart';
import '../../features/dashboards/inventory/inventory_dashboard.dart';
import '../../features/dashboards/order_processing/order_processing_dashboard.dart';
import '../../features/dashboards/sales/sales_dashboard.dart';
import '../../features/dashboards/super_admin/super_admin_dashboard.dart';
import '../../features/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
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
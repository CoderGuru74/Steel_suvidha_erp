import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboards/super_admin/providers/super_admin_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminProvider()),
      ],
      child: const SteelSuvidhaApp(),
    ),
  );
}

class SteelSuvidhaApp extends StatelessWidget {
  const SteelSuvidhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Steel Suvidha ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D63ED)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
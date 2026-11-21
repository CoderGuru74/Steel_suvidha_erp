import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/utils/responsive.dart';
import '../providers/auth_provider.dart';

class WorkspaceSelectScreen extends StatefulWidget {
  const WorkspaceSelectScreen({super.key});

  @override
  State<WorkspaceSelectScreen> createState() => _WorkspaceSelectScreenState();
}

class _WorkspaceSelectScreenState extends State<WorkspaceSelectScreen> {
  final _passcodeController = TextEditingController();
  UserRole? _selectedRole;
  bool _isMenuOpen = false;

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _handleWorkspaceSignIn() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role first.')),
      );
      return;
    }

    if (_passcodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your role passcode.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      identifier: auth.currentUser?.identifier ?? 'admin@steelsuvidha.in',
      password: _passcodeController.text.trim(),
      role: _selectedRole!,
    );

    if (success && mounted) {
      context.go(_selectedRole!.routePath);
    }
  }

  Widget _buildLogo({double? height}) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Text(
        'Steel Suvidha',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final authProvider = context.watch<AuthProvider>();
    final bool isLoading = authProvider.isLoading;
    final String createdStoreName = authProvider.storeName;
    final double brandLogoWidth =
        (MediaQuery.sizeOf(context).width * 0.28).clamp(180.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                if (!isMobile) ...[
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: brandLogoWidth),
                          child: _buildLogo(),
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
                        vertical: 32.0,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isMobile) ...[
                              Center(child: _buildLogo(height: 44)),
                              const SizedBox(height: 24),
                            ],
                            const Text(
                              'Select your',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.15,
                              ),
                            ),
                            const Text(
                              'Workspace',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Choose the profile you want to login',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Dynamic Store Name from Registration
                            _buildLabel('Store Name'),
                            Container(
                              height: 42,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFF93C5FD)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      createdStoreName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFF1D63ED),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Select your Role Dropdown
                            _buildLabel('Select your Role'),
                            Container(
                              height: 42,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFF93C5FD)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<UserRole>(
                                  value: _selectedRole,
                                  isExpanded: true,
                                  hint: const Text(
                                    'Choose your Role',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppColors.textPrimary,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: UserRole.values.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(role.label),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedRole = val),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Role Passcode
                            _buildLabel('Role Passcode'),
                            SizedBox(
                              height: 42,
                              child: TextField(
                                controller: _passcodeController,
                                obscureText: true,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter Your role Passcode',
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
                                    borderSide: const BorderSide(
                                      color: Color(0xFF93C5FD),
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
                            const SizedBox(height: 8),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => context.push('/verify-otp'),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandRed,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            SizedBox(
                              width: double.infinity,
                              height: 44,
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
                                  onPressed: isLoading
                                      ? null
                                      : _handleWorkspaceSignIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign in',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
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
                                Icons.swap_horiz,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Switch Account / Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
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

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );
}
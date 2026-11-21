import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/utils/responsive.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isMenuOpen = false;
  bool _obscurePassword = true;
  bool _isOtpMode = false;
  bool _isRegisterMode = false;
  UserRole _selectedRole = UserRole.superAdmin;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final auth = context.read<AuthProvider>();
    final credential = _isOtpMode
        ? _otpController.text.trim()
        : _passwordController.text.trim();

    final success = await auth.login(
      identifier: _emailController.text.trim().isEmpty
          ? 'admin@steelsuvidha.in'
          : _emailController.text.trim(),
      password: credential.isEmpty ? '123456' : credential,
      role: _selectedRole,
    );

    if (success && mounted) {
      context.go(_selectedRole.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Layout
            Row(
              children: [
                // Expanded Black Sidebar on Tablet/Desktop when open
                if (_isMenuOpen && !isMobile)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildExpandedSidebar(),
                  ),

                // Left Brand Area (Shown when sidebar is closed on Tablet/Desktop)
                if (!_isMenuOpen && !isMobile) ...[
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Vertical Divider from Figma
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 48),
                    color: AppColors.border,
                  ),
                ],

                // Right Form Panel
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
                        child: _buildAuthForm(isMobile),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Top-Left Hamburger Button when sidebar is closed
            if (!_isMenuOpen)
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
                    onTap: () => setState(() => _isMenuOpen = true),
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

            // Mobile Overlay Drawer when menu is opened on small screens
            if (_isMenuOpen && isMobile)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isMenuOpen = false),
                  child: Container(
                    color: Colors.black54,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap-through
                      child: _buildExpandedSidebar(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Black Rounded Sidebar matching Screen 2
  Widget _buildExpandedSidebar() {
    return Container(
      width: 245,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: White-adjusted Logo + Close Button
          Row(
            children: [
              Expanded(
                child: ColorFiltered(
                  // Keeps icon colors while making dark "Steel suvidha" text crisp on black
                  colorFilter: const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.dst,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => _isMenuOpen = false),
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 44),

          // Workspace
          _SidebarItem(
            title: 'Workspace',
            isBold: true,
            onTap: () => setState(() => _isMenuOpen = false),
          ),
          const SizedBox(height: 22),

          // Sign up
          _SidebarItem(
            title: 'Sign up',
            isBold: true,
            isSelected: _isRegisterMode,
            onTap: () {
              setState(() {
                _isRegisterMode = true;
                _isMenuOpen = false;
              });
            },
          ),
          const SizedBox(height: 22),

          // Login / Sign in
          _SidebarItem(
            title: 'Login/Sign in',
            isBold: true,
            isSelected: !_isRegisterMode,
            onTap: () {
              setState(() {
                _isRegisterMode = false;
                _isMenuOpen = false;
              });
            },
          ),
          const SizedBox(height: 12),

          // Sub-options: With Password & With OTP
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SidebarItem(
                  title: 'With Password',
                  fontSize: 12,
                  isSelected: !_isRegisterMode && !_isOtpMode,
                  onTap: () {
                    setState(() {
                      _isRegisterMode = false;
                      _isOtpMode = false;
                      _isMenuOpen = false;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _SidebarItem(
                  title: 'With OTP',
                  fontSize: 12,
                  isSelected: !_isRegisterMode && _isOtpMode,
                  onTap: () {
                    setState(() {
                      _isRegisterMode = false;
                      _isOtpMode = true;
                      _isMenuOpen = false;
                    });
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom: My account
          InkWell(
            onTap: () => setState(() => _isMenuOpen = false),
            child: const Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'My account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Right Side Authentication Form matching Screens 1 & 2
  Widget _buildAuthForm(bool isMobile) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMobile) ...[
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 44,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Header Title
          const Text(
            'Welcome to',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const Text(
            'Steel Suvidha',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Please enter your details',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),

          // Name Field
          _buildLabel('Name'),
          _buildTextField(
            controller: _nameController,
            hint: 'Enter Your name',
          ),
          const SizedBox(height: 14),

          // Email Field
          _buildLabel('Email'),
          _buildTextField(
            controller: _emailController,
            hint: 'Enter Your Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          // Password OR OTP Field
          _buildLabel(_isOtpMode ? 'One-Time Password (OTP)' : 'Password'),
          if (_isOtpMode)
            _buildTextField(
              controller: _otpController,
              hint: 'Enter 6-digit OTP',
              keyboardType: TextInputType.number,
            )
          else
            _buildTextField(
              controller: _passwordController,
              hint: 'Enter Your Password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),

          const SizedBox(height: 8),

          // Helper Links Row: Login with OTP instead | Forgot Password?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isOtpMode = !_isOtpMode),
                child: Text(
                  _isOtpMode ? 'Login with Password instead' : 'Login with OTP instead',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email.'),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandRed,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Role Selector (For testing all 6 ERP panels during development)
          _buildLabel('Select Workspace Role (Dev Preview)'),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserRole>(
                value: _selectedRole,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Primary Gradient "Sign in" Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D63ED), Color(0xFF3B82F6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSignIn,
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
                    : Text(
                        _isRegisterMode ? 'Sign up' : 'Sign in',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // "or Sign in with"
          const Center(
            child: Text(
              'or Sign in with',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // "Sign in with Google" Outlined Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: _handleSignIn,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF93C5FD)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF1F5F9),
                    ),
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Color(0xFFEA4335),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bottom Footer: Don't have an account ? Register your Store
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isRegisterMode = !_isRegisterMode),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: _isRegisterMode
                          ? 'Already have an account ? '
                          : "Don't have an account ? ",
                    ),
                    TextSpan(
                      text: _isRegisterMode
                          ? 'Login your Store'
                          : 'Register your Store',
                      style: const TextStyle(
                        color: Color(0xFF1D63ED),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 42,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF93C5FD)),
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
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isBold;
  final bool isSelected;
  final double fontSize;

  const _SidebarItem({
    required this.title,
    required this.onTap,
    this.isBold = false,
    this.isSelected = false,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF60A5FA) : Colors.white,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
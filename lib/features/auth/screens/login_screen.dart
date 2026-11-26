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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _toggleRegisterMode(bool register) {
    setState(() {
      _isRegisterMode = register;
      _isOtpMode = register;
    });
  }

  UserRole _resolveRoleFromEmail(String email) {
    final e = email.toLowerCase();
    if (e.startsWith('admin@')) return UserRole.admin;
    if (e.startsWith('inventory@')) return UserRole.inventoryManagement;
    if (e.startsWith('sales@')) return UserRole.salesPanel;
    if (e.startsWith('orders@') || e.startsWith('order@')) {
      return UserRole.orderProcessing;
    }
    if (e.startsWith('daybook@')) return UserRole.daybookManagement;
    return UserRole.superAdmin;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    return trimmed.isNotEmpty &&
        trimmed.contains('@') &&
        trimmed.contains('.');
  }

  Future<bool> _sendRealOtpToEmail(String email) async {
    final cleanEmail = email.trim();
    if (!_isValidEmail(cleanEmail)) {
      _showMessage('Please enter your valid email address first');
      return false;
    }

    final auth = context.read<AuthProvider>();
    final sent = await auth.sendOtp(cleanEmail);
    if (!mounted) return false;

    _showMessage(
      sent
          ? 'Actual OTP sent to $cleanEmail'
          : (auth.errorMessage ?? 'Could not send OTP to $cleanEmail'),
    );
    return sent;
  }

  Future<void> _handleForgotPasswordTap() async {
    final enteredEmail = _emailController.text.trim();
    if (!_isValidEmail(enteredEmail)) {
      _showMessage(
        'Enter your registered email address in the Email box first, then tap Forgot Password?',
      );
      return;
    }

    final sent = await _sendRealOtpToEmail(enteredEmail);
    if (!sent || !mounted) return;

    await _openResetPasswordDialog(enteredEmail);
  }

  Future<void> _openResetPasswordDialog(String targetEmail) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResetPasswordDialog(
        initialEmail: targetEmail.trim(),
        onSendOtp: (email) => _sendRealOtpToEmail(email),
        onShowMessage: (msg) => _showMessage(msg),
        onPasswordUpdated: (email, newPass) {
          if (!mounted) return;
          _emailController.text = email;
          _passwordController.text = newPass;
          setState(() {
            _isRegisterMode = false;
            _isOtpMode = false;
          });
        },
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final auth = context.read<AuthProvider>();
    final rawEmail = _emailController.text.trim();

    if (!_isValidEmail(rawEmail)) {
      _showMessage('Please enter your valid email address');
      return;
    }

    final role = _resolveRoleFromEmail(rawEmail);

    if (_isRegisterMode) {
      final name = _nameController.text.trim();
      final password = _passwordController.text.trim();
      final otp = _otpController.text.trim();

      if (name.isEmpty) {
        _showMessage('Please enter your name');
        return;
      }
      if (password.isEmpty) {
        _showMessage('Please create a password');
        return;
      }
      if (otp.isEmpty) {
        _showMessage('Please tap Send / Resend OTP and enter your code');
        return;
      }

      final verified = await auth.verifyOtp(email: rawEmail, otp: otp);
      if (!verified) {
        if (!mounted) return;
        _showMessage(auth.errorMessage ?? 'Invalid or expired OTP');
        return;
      }

      final registered = await auth.registerStore(
        storeName: auth.storeName,
        fullName: name,
        email: rawEmail,
        password: password,
        otp: otp,
        role: role,
      );

      if (!mounted) return;
      if (!registered) {
        _showMessage(auth.errorMessage ?? 'Sign up failed');
        return;
      }

      context.go('/store-setup');
      return;
    }

    if (_isOtpMode) {
      final otp = _otpController.text.trim();
      if (otp.isEmpty) {
        _showMessage(
          'Tap Send / Resend OTP and enter the OTP sent to $rawEmail',
        );
        return;
      }

      final success = await auth.loginWithOtp(
        email: rawEmail,
        otp: otp,
        role: role,
      );

      if (!mounted) return;
      if (!success) {
        _showMessage(auth.errorMessage ?? 'OTP login failed');
        return;
      }

      context.go('/workspace');
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      _showMessage('Please enter your password');
      return;
    }

    final success = await auth.login(
      identifier: rawEmail,
      password: password,
      role: role,
    );

    if (!mounted) return;
    if (!success) {
      _showMessage(auth.errorMessage ?? 'Invalid email or password');
      return;
    }

    context.go('/workspace');
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
    final Size screenSize = MediaQuery.sizeOf(context);
    final double brandLogoWidth = (screenSize.width * 0.28).clamp(180.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                if (_isMenuOpen && !isMobile)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildExpandedSidebar(),
                  ),
                if (!_isMenuOpen && !isMobile) ...[
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
                        child: _buildAuthForm(isMobile),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            if (_isMenuOpen && isMobile)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isMenuOpen = false),
                  child: Container(
                    color: Colors.black54,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () {},
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
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildLogo(height: 30),
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
          _SidebarItem(
            title: 'Workspace',
            isBold: true,
            isSelected: true,
            onTap: () => setState(() => _isMenuOpen = false),
          ),
          const SizedBox(height: 22),
          _SidebarItem(
            title: 'Sign up',
            isBold: true,
            isSelected: _isRegisterMode,
            onTap: () {
              _toggleRegisterMode(true);
              setState(() => _isMenuOpen = false);
            },
          ),
          const SizedBox(height: 22),
          _SidebarItem(
            title: 'Login/Sign in',
            isBold: true,
            isSelected: !_isRegisterMode,
            onTap: () {
              _toggleRegisterMode(false);
              setState(() => _isMenuOpen = false);
            },
          ),
          if (!_isRegisterMode) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SidebarItem(
                    title: 'With Password',
                    fontSize: 12,
                    isSelected: !_isOtpMode,
                    onTap: () {
                      setState(() {
                        _isOtpMode = false;
                        _isMenuOpen = false;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _SidebarItem(
                    title: 'With OTP',
                    fontSize: 12,
                    isSelected: _isOtpMode,
                    onTap: () {
                      setState(() {
                        _isOtpMode = true;
                        _isMenuOpen = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          _SidebarItem(
            title: 'Plans & Pricing',
            isBold: true,
            onTap: () {
              setState(() => _isMenuOpen = false);
              context.push('/intro');
            },
          ),
          const Spacer(),
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

  Widget _buildAuthForm(bool isMobile) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMobile) ...[
            Center(child: _buildLogo(height: 44)),
            const SizedBox(height: 24),
          ],
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
          Text(
            _isRegisterMode
                ? 'Enter your details and tap Sign up to add store details'
                : 'Please enter your details',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          if (_isRegisterMode) ...[
            _buildLabel('Name'),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter Your name',
            ),
            const SizedBox(height: 14),
          ],
          _buildLabel('Email'),
          _buildTextField(
            controller: _emailController,
            hint: 'Enter Your Email',
            keyboardType: TextInputType.emailAddress,
          ),
          if (_isRegisterMode || !_isOtpMode) ...[
            const SizedBox(height: 14),
            _buildLabel(_isRegisterMode ? 'Create Password' : 'Password'),
            _buildTextField(
              controller: _passwordController,
              hint: _isRegisterMode
                  ? 'Create a password for Sign in'
                  : 'Enter Your Password',
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
          ],
          if (_isRegisterMode || _isOtpMode) ...[
            const SizedBox(height: 14),
            _buildLabel('OTP'),
            _buildTextField(
              controller: _otpController,
              hint: 'Enter Your one time Password',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: isLoading
                    ? null
                    : () => _sendRealOtpToEmail(_emailController.text),
                child: const Text(
                  'Send / Resend OTP',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ),
          ],
          if (!_isRegisterMode) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isOtpMode = !_isOtpMode),
                  child: Text(
                    _isOtpMode
                        ? 'Login with Password'
                        : 'Login with OTP instead',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: isLoading ? null : _handleForgotPasswordTap,
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
          ],
          const SizedBox(height: 22),
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
                onPressed: isLoading ? null : _handleSubmit,
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
          Center(
            child: Text(
              _isRegisterMode ? 'or Sign up with' : 'or Sign in with',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: _handleSubmit,
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
                  Text(
                    _isRegisterMode
                        ? 'Sign up with Google'
                        : 'Sign in with Google',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () => _toggleRegisterMode(!_isRegisterMode),
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
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: () => context.push('/intro'),
              child: const Text(
                'New to Steel Suvidha? See features & plans',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
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

class _ResetPasswordDialog extends StatefulWidget {
  final String initialEmail;
  final Future<bool> Function(String email) onSendOtp;
  final void Function(String message) onShowMessage;
  final void Function(String email, String newPassword) onPasswordUpdated;

  const _ResetPasswordDialog({
    required this.initialEmail,
    required this.onSendOtp,
    required this.onShowMessage,
    required this.onPasswordUpdated,
  });

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  late final TextEditingController _emailCtrl;
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  bool _obscureNewPass = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Reset Password',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _submitting
                    ? null
                    : () => widget.onSendOtp(_emailCtrl.text),
                child: const Text('Resend OTP to this Email'),
              ),
            ),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter 6-Digit OTP from Email',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPassCtrl,
              obscureText: _obscureNewPass,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureNewPass = !_obscureNewPass),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting
              ? null
              : () async {
                  final email = _emailCtrl.text.trim();
                  final otp = _otpCtrl.text.trim();
                  final newPass = _newPassCtrl.text.trim();

                  if (email.isEmpty || !email.contains('@')) {
                    widget.onShowMessage('Enter a valid email address');
                    return;
                  }
                  if (otp.isEmpty) {
                    widget.onShowMessage('Enter the OTP sent to $email');
                    return;
                  }
                  if (newPass.isEmpty) {
                    widget.onShowMessage('Enter a new password');
                    return;
                  }

                  setState(() => _submitting = true);
                  final auth = context.read<AuthProvider>();
                  final ok = await auth.resetPassword(
                    email: email,
                    otp: otp,
                    newPassword: newPass,
                  );
                  if (!mounted) return;
                  setState(() => _submitting = false);

                  if (ok) {
                    widget.onPasswordUpdated(email, newPass);
                    if (context.mounted) Navigator.of(context).pop();
                    widget.onShowMessage(
                      'Password reset for $email! Tap Sign in now.',
                    );
                  } else {
                    widget.onShowMessage(
                      auth.errorMessage ?? 'Password reset failed',
                    );
                  }
                },
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save New Password'),
        ),
      ],
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
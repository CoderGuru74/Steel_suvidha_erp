import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/auth_provider.dart';

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameController = TextEditingController();
  final _rolePinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityStatePinController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedBusinessType = 'Retail & Wholesale Steel Dealer';
  File? _storeLogoFile;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _obscurePin = true;

  final List<String> _businessTypes = const [
    'Retail & Wholesale Steel Dealer',
    'TMT & Structural Steel Distributor',
    'Hardware & Building Materials Store',
    'Fabrication & Industrial Supplier',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.storeName.isNotEmpty && auth.storeName != 'Steel Suvidha') {
      _storeNameController.text = auth.storeName;
    }
    if (auth.rolePin.isNotEmpty) {
      _rolePinController.text = auth.rolePin;
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _rolePinController.dispose();
    _phoneController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _addressController.dispose();
    _cityStatePinController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickStoreLogo() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _storeLogoFile = File(picked.path);
        });
      }
    } catch (_) {
      _showSnack('Could not pick store logo from gallery');
    }
  }

  Future<void> _handleSubmit() async {
    final auth = context.read<AuthProvider>();
    final storeName = _storeNameController.text.trim();
    final rolePin = _rolePinController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (storeName.isEmpty) {
      _showSnack('Please enter your Store / Firm Name');
      return;
    }

    if (rolePin.isEmpty || rolePin.length < 4) {
      _showSnack('Please create a Role PIN (at least 4 digits)');
      return;
    }

    if (newPass.isNotEmpty || confirmPass.isNotEmpty) {
      if (newPass != confirmPass) {
        _showSnack('Password and Confirm Password do not match');
        return;
      }
    }

    if (auth.isAuthenticated) {
      final saved = await auth.saveStoreSetup(
        storeName: storeName,
        rolePin: rolePin,
      );
      if (!mounted) return;
      if (!saved) {
        _showSnack(auth.errorMessage ?? 'Failed to save store details');
        return;
      }
      _showSnack('Store "$storeName" and Role PIN saved');
      context.go('/workspace');
      return;
    }

    if (newPass.isEmpty) {
      _showSnack('Please create a password to register your store');
      return;
    }

    final created = await auth.registerStore(
      ownerName: auth.currentUser?.fullName ?? 'Store Owner',
      email: auth.currentUser?.email ?? 'owner@steelsuvidha.in',
      phone: _phoneController.text.trim(),
      storeName: storeName,
      rolePin: rolePin,
      password: newPass,
    );

    if (!mounted) return;

    if (created) {
      _showSnack('Store "$storeName" registered. Sign in to continue');
      context.go('/login');
    } else {
      _showSnack(auth.errorMessage ?? 'Failed to register store');
    }
  }

  Widget _buildBrandLogo({double? height}) {
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
    final bool isLoading = context.watch<AuthProvider>().isLoading;
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
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 20,
                      child: TextButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        label: const Text(
                          'Back to Login',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: brandLogoWidth),
                          child: _buildBrandLogo(),
                        ),
                      ),
                    ),
                  ],
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 24.0 : 40.0,
                            20.0,
                            isMobile ? 24.0 : 40.0,
                            12.0,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isMobile) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildBrandLogo(height: 36),
                                      TextButton(
                                        onPressed: () => context.go('/login'),
                                        child: const Text('Back'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                const Text(
                                  'Register Your Store',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Enter your store name, create a role PIN, and save details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                _fieldLabel('Store Logo'),
                                InkWell(
                                  onTap: _pickStoreLogo,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF93C5FD),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: _storeLogoFile != null
                                              ? Image.file(
                                                  _storeLogoFile!,
                                                  fit: BoxFit.cover,
                                                )
                                              : const Icon(
                                                  Icons.storefront_outlined,
                                                  color: Color(0xFF1D63ED),
                                                  size: 20,
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _storeLogoFile != null
                                                    ? 'Store logo selected'
                                                    : 'Upload Store Logo',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const Text(
                                                'PNG or JPG (Used on invoices & bills)',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _storeLogoFile != null
                                                ? 'Change'
                                                : 'Browse',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1D63ED),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                if (!isMobile)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel('Store / Firm Name *'),
                                            _inputBox(
                                              controller: _storeNameController,
                                              hint: 'Enter store name',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel('Create Role PIN *'),
                                            _inputBox(
                                              controller: _rolePinController,
                                              hint: '4-6 digit PIN',
                                              keyboardType: TextInputType.number,
                                              obscure: _obscurePin,
                                              suffix: IconButton(
                                                icon: Icon(
                                                  _obscurePin
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  size: 17,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                onPressed: () => setState(
                                                  () =>
                                                      _obscurePin = !_obscurePin,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _fieldLabel('Store / Firm Name *'),
                                  _inputBox(
                                    controller: _storeNameController,
                                    hint: 'Enter your store or company name',
                                  ),
                                  const SizedBox(height: 10),
                                  _fieldLabel('Create Role PIN *'),
                                  _inputBox(
                                    controller: _rolePinController,
                                    hint: 'Create 4-6 digit Role PIN',
                                    keyboardType: TextInputType.number,
                                    obscure: _obscurePin,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePin
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 17,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePin = !_obscurePin,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),

                                _fieldLabel('Business Category'),
                                Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF93C5FD),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedBusinessType,
                                      isExpanded: true,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textPrimary,
                                      ),
                                      items: _businessTypes
                                          .map(
                                            (type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(
                                                type,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(
                                            () => _selectedBusinessType = val,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                if (!isMobile)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel('GSTIN Number'),
                                            _inputBox(
                                              controller: _gstController,
                                              hint: '15-digit GSTIN',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel('PAN Number'),
                                            _inputBox(
                                              controller: _panController,
                                              hint: '10-digit PAN',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _fieldLabel('GSTIN Number'),
                                  _inputBox(
                                    controller: _gstController,
                                    hint: 'Enter 15-digit GSTIN',
                                  ),
                                  const SizedBox(height: 10),
                                  _fieldLabel('PAN Number'),
                                  _inputBox(
                                    controller: _panController,
                                    hint: 'Enter 10-digit PAN',
                                  ),
                                ],
                                const SizedBox(height: 10),

                                if (!isMobile)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel('Store Contact Number'),
                                            _inputBox(
                                              controller: _phoneController,
                                              hint: '+91 98XXXXXXXX',
                                              keyboardType: TextInputType.phone,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel(
                                              'City, State & Pincode',
                                            ),
                                            _inputBox(
                                              controller:
                                                  _cityStatePinController,
                                              hint: 'e.g. Patna, Bihar - 800001',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _fieldLabel('Store Contact Number'),
                                  _inputBox(
                                    controller: _phoneController,
                                    hint: '+91 98XXXXXXXX',
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 10),
                                  _fieldLabel('City, State & Pincode'),
                                  _inputBox(
                                    controller: _cityStatePinController,
                                    hint: 'e.g. Patna, Bihar - 800001',
                                  ),
                                ],
                                const SizedBox(height: 10),

                                _fieldLabel('Complete Store / Yard Address'),
                                _inputBox(
                                  controller: _addressController,
                                  hint: 'Shop/Plot No., Street, Landmark',
                                ),
                                const SizedBox(height: 10),

                                if (!isMobile)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel('Create Password'),
                                            _inputBox(
                                              controller:
                                                  _newPasswordController,
                                              hint: 'Create password',
                                              obscure: _obscurePass,
                                              suffix: IconButton(
                                                icon: Icon(
                                                  _obscurePass
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  size: 17,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscurePass =
                                                      !_obscurePass,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel('Confirm Password'),
                                            _inputBox(
                                              controller:
                                                  _confirmPasswordController,
                                              hint: 'Re-enter password',
                                              obscure: _obscureConfirm,
                                              suffix: IconButton(
                                                icon: Icon(
                                                  _obscureConfirm
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  size: 17,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscureConfirm =
                                                      !_obscureConfirm,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _fieldLabel('Create Password'),
                                  _inputBox(
                                    controller: _newPasswordController,
                                    hint: 'Create strong password',
                                    obscure: _obscurePass,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePass
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 17,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _fieldLabel('Confirm Password'),
                                  _inputBox(
                                    controller: _confirmPasswordController,
                                    hint: 'Re-enter your password',
                                    obscure: _obscureConfirm,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 17,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.fromLTRB(
                          isMobile ? 24.0 : 40.0,
                          10.0,
                          isMobile ? 24.0 : 40.0,
                          16.0,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          border: Border(
                            top: BorderSide(color: AppColors.border, width: 0.6),
                          ),
                        ),
                        child: SizedBox(
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
                                  color: const Color(0xFF2563EB)
                                      .withValues(alpha: 0.28),
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
                                  : const Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
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
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) =>
      SizedBox(
        height: 40,
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: suffix,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF93C5FD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF1D63ED), width: 1.5),
            ),
          ),
        ),
      );
}
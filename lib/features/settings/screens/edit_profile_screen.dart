import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/user_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/services/user_service.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _organisationController;
  late TextEditingController _designationController;

  String? _selectedGender;
  bool _isLoading = false;
  String? _error;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _organisationController = TextEditingController(text: widget.user.affiliatedOrganisation ?? '');
    _designationController = TextEditingController(text: widget.user.currentDesignation ?? '');
    // Capitalize gender to match dropdown options
    _selectedGender = widget.user.gender != null
        ? widget.user.gender!.substring(0, 1).toUpperCase() +
            widget.user.gender!.substring(1).toLowerCase()
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _organisationController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final updateData = <String, dynamic>{};

      // Only include fields that have changed
      if (_nameController.text.trim() != widget.user.name) {
        updateData['name'] = _nameController.text.trim();
      }
      if (_emailController.text.trim() != (widget.user.email ?? '')) {
        updateData['email'] = _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim();
      }
      // Compare normalized gender values (lowercase)
      final originalGender = widget.user.gender?.toLowerCase();
      final newGender = _selectedGender?.toLowerCase();
      if (newGender != originalGender) {
        updateData['gender'] = newGender;
      }
      if (_addressController.text.trim() != (widget.user.address ?? '')) {
        updateData['address'] = _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim();
      }
      if (_organisationController.text.trim() != (widget.user.affiliatedOrganisation ?? '')) {
        updateData['affiliated_organisation'] = _organisationController.text.trim().isEmpty
            ? null
            : _organisationController.text.trim();
      }
      if (_designationController.text.trim() != (widget.user.currentDesignation ?? '')) {
        updateData['current_designation'] = _designationController.text.trim().isEmpty
            ? null
            : _designationController.text.trim();
      }

      if (updateData.isEmpty) {
        // No changes made
        if (mounted) {
          context.pop();
        }
        return;
      }

      await _userService.updateProfile(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Return true to indicate profile was updated
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final cardColor = isDark ? AppColors.darkCardBackground : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF888888);
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: isTablet ? 50 : 40,
                      height: isTablet ? 50 : 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cardColor,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: isTablet ? 25 : 20,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 24 : 20,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null) ...[
                        Container(
                          padding: EdgeInsets.all(isTablet ? 16 : 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: isTablet ? 24 : 20),
                              SizedBox(width: isTablet ? 12 : 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: isTablet ? 15 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 20),
                      ],

                      // Name Field
                      Text(
                        'Full Name',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 16 : 14,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(fontSize: isTablet ? 17 : 16, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(color: secondaryTextColor),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 18 : 16,
                            vertical: isTablet ? 18 : 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          if (value.trim().length > 100) {
                            return 'Name must not exceed 100 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isTablet ? 24 : 20),

                      // Email Field
                      Text(
                        'Email',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 16 : 14,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: isTablet ? 17 : 16, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: secondaryTextColor),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 18 : 16,
                            vertical: isTablet ? 18 : 16,
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Invalid email format';
                            }
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isTablet ? 24 : 20),

                      // Gender Field
                      Text(
                        'Gender',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 16 : 14,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        style: TextStyle(fontSize: isTablet ? 17 : 16, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Select gender',
                          hintStyle: TextStyle(color: secondaryTextColor),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 18 : 16,
                            vertical: isTablet ? 18 : 16,
                          ),
                        ),
                        dropdownColor: isDark ? AppColors.darkCardBackground : Colors.white,
                        items: _genderOptions.map((gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),

                      SizedBox(height: isTablet ? 24 : 20),

                      // Address Field (tap to open map picker)
                      Text(
                        'Address',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 16 : 14,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      GestureDetector(
                        onTap: () async {
                          final result = await context.push<String>('/map-address-picker');
                          if (result != null && result.isNotEmpty && mounted) {
                            setState(() {
                              _addressController.text = result;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 18 : 16,
                            vertical: isTablet ? 18 : 16,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _addressController.text.isEmpty
                                      ? 'Tap to pick your address'
                                      : _addressController.text,
                                  style: TextStyle(
                                    fontSize: isTablet ? 17 : 16,
                                    color: _addressController.text.isEmpty
                                        ? secondaryTextColor
                                        : textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.location_on_outlined,
                                size: isTablet ? 24 : 20,
                                color: AppColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 24 : 20),

                      // Affiliated Organisation Field
                      Text(
                        'Affiliated Organisation',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 16 : 14,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      TextFormField(
                        controller: _organisationController,
                        style: TextStyle(fontSize: isTablet ? 17 : 16, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter your organisation',
                          hintStyle: TextStyle(color: secondaryTextColor),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 18 : 16,
                            vertical: isTablet ? 18 : 16,
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 24 : 20),

                      // Current Designation Field
                      Text(
                        'Current Designation',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 16 : 14,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      TextFormField(
                        controller: _designationController,
                        style: TextStyle(fontSize: isTablet ? 17 : 16, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter your designation',
                          hintStyle: TextStyle(color: secondaryTextColor),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 18 : 16,
                            vertical: isTablet ? 18 : 16,
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 40 : 32),
                    ],
                  ),
                ),
              ),
            ),

            // Save Button
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: isTablet ? 22 : 20,
                          width: isTablet ? 22 : 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 18 : 16,
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

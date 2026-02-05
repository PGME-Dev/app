import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/services/user_service.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/widgets/zoho_payment_widget.dart';
import 'package:pgme/features/books/providers/book_provider.dart';

class BookCheckoutScreen extends StatefulWidget {
  const BookCheckoutScreen({super.key});

  @override
  State<BookCheckoutScreen> createState() => _BookCheckoutScreenState();
}

class _BookCheckoutScreenState extends State<BookCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userService = UserService();
      final user = await userService.getProfile();

      if (mounted) {
        setState(() {
          _recipientNameController.text = user.name ?? '';
          _phoneController.text = user.phoneNumber?.replaceAll('+91', '') ?? '';
          _addressController.text = user.address ?? '';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<BookProvider>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      // Step 1: Create Zoho payment session
      final paymentSession = await provider.createPaymentSession(
        recipientName: _recipientNameController.text.trim(),
        shippingPhone: _phoneController.text.trim(),
        shippingAddress: _addressController.text.trim(),
      );

      if (!mounted) return;

      // Step 2: Show Zoho payment widget
      final result = await Navigator.push<ZohoPaymentResponse>(
        context,
        MaterialPageRoute(
          builder: (context) => ZohoPaymentWidget(
            paymentSession: paymentSession,
            onPaymentComplete: (response) {
              Navigator.pop(context, response);
            },
          ),
          fullscreenDialog: true,
        ),
      );

      // Step 3: Handle payment response
      if (result != null && mounted) {
        if (result.isSuccess) {
          // Verify payment with backend
          final verification = await provider.verifyZohoPayment(
            paymentSessionId: result.paymentSessionId!,
            paymentId: result.paymentId!,
            signature: result.signature,
          );

          if (verification.success && mounted) {
            context.go('/book-order-confirmation/${verification.purchaseId}');
          } else if (mounted) {
            _showError('Payment verification failed. Please contact support.');
          }
        } else if (result.isFailed) {
          _showError('Payment failed: ${result.errorMessage ?? "Unknown error"}');
        } else if (result.isCancelled) {
          _showInfo('Payment cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error processing order: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceAll('Exception: ', '')),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final buttonColor = isDark ? const Color(0xFF1A1A4D) : const Color(0xFF000080);
    final inputFillColor = isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back, size: 24, color: textColor),
                ),
                const Spacer(),
                Text(
                  'Checkout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 24),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Form
          Expanded(
            child: _isLoadingUser
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shipping Address Section
                          Text(
                            'Shipping Address',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Recipient Name
                          TextFormField(
                            controller: _recipientNameController,
                            decoration: InputDecoration(
                              labelText: 'Recipient Name',
                              hintText: 'Enter full name',
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter recipient name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '10 digit phone number',
                              prefixText: '+91 ',
                              filled: true,
                              fillColor: inputFillColor,
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                                return 'Please enter valid 10 digit phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Address
                          TextFormField(
                            controller: _addressController,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: InputDecoration(
                              labelText: 'Delivery Address',
                              hintText: 'Enter complete address with pincode',
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter delivery address';
                              }
                              if (value.trim().length < 20) {
                                return 'Please enter a complete address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Order Summary Section
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Consumer<BookProvider>(
                            builder: (context, provider, _) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  children: [
                                    // Items
                                    ...provider.cartItems.map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item.title} x${item.quantity}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '\u{20B9}${item.totalPrice}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    Divider(color: borderColor),
                                    const SizedBox(height: 8),
                                    // Subtotal
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Subtotal',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          '\u{20B9}${provider.cartSubtotal}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Shipping
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Shipping',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          '\u{20B9}${provider.shippingCost}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(color: borderColor),
                                    const SizedBox(height: 8),
                                    // Total
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          '\u{20B9}${provider.cartTotal}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 100), // Space for button
                        ],
                      ),
                    ),
                  ),
          ),

          // Place Order Button
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 80),
            decoration: BoxDecoration(
              color: cardBgColor,
              border: Border(
                top: BorderSide(color: borderColor),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

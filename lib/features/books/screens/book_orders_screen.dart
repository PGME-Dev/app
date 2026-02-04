import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/book_order_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/books/providers/book_provider.dart';

class BookOrdersScreen extends StatefulWidget {
  const BookOrdersScreen({super.key});

  @override
  State<BookOrdersScreen> createState() => _BookOrdersScreenState();
}

class _BookOrdersScreenState extends State<BookOrdersScreen> {
  final Set<String> _expandedOrders = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).loadOrders(refresh: true);
    });
  }

  void _toggleExpanded(String orderId) {
    setState(() {
      if (_expandedOrders.contains(orderId)) {
        _expandedOrders.remove(orderId);
      } else {
        _expandedOrders.add(orderId);
      }
    });
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
                  'My Orders',
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

          // Orders List
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingOrders && provider.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.ordersError != null && provider.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
                        const SizedBox(height: 16),
                        Text(
                          provider.ordersError!,
                          style: TextStyle(color: secondaryTextColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadOrders(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: secondaryTextColor),
                        const SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your book orders will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadOrders(refresh: true),
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding + 100),
                    itemCount: provider.orders.length,
                    itemBuilder: (context, index) {
                      final order = provider.orders[index];
                      final isExpanded = _expandedOrders.contains(order.orderId);
                      return _buildOrderCard(
                        context: context,
                        order: order,
                        isExpanded: isExpanded,
                        onTap: () => _toggleExpanded(order.orderId),
                        isDark: isDark,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required BookOrderModel order,
    required bool isExpanded,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardBgColor,
    required Color borderColor,
  }) {
    // Format date
    String formattedDate = '-';
    try {
      final date = DateTime.parse(order.createdAt);
      formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (_) {}

    // Status color
    Color statusColor;
    switch (order.orderStatus) {
      case 'confirmed':
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'processing':
      case 'shipped':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? statusColor.withValues(alpha: 0.5) : borderColor,
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number, status, and expand icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusDisplayText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date and items
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${order.itemsCount} items',
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total and tracking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\u{20B9}${order.totalAmount}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                if (order.trackingNumber != null)
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.trackingNumber!,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Expanded details
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedDetails(
                order: order,
                isDark: isDark,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                borderColor: borderColor,
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails({
    required BookOrderModel order,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Divider(color: borderColor, height: 1),
        const SizedBox(height: 16),

        // Shipping Details Section
        Text(
          'Shipping Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),

        // Recipient
        if (order.recipientName != null) ...[
          _buildDetailRow(
            icon: Icons.person_outline,
            label: 'Recipient',
            value: order.recipientName!,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          const SizedBox(height: 8),
        ],

        // Phone
        if (order.shippingPhone != null) ...[
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+91 ${order.shippingPhone}',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          const SizedBox(height: 8),
        ],

        // Address
        if (order.shippingAddress != null) ...[
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: order.shippingAddress!,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            isMultiline: true,
          ),
        ],

        const SizedBox(height: 16),
        Divider(color: borderColor, height: 1),
        const SizedBox(height: 16),

        // Order Summary Section
        Text(
          'Order Summary',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),

        // Items list
        if (order.items != null && order.items!.isNotEmpty)
          ...order.items!.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.menu_book,
                          size: 20,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qty: ${item.quantity} × \u{20B9}${item.price}',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\u{20B9}${(item.quantity * item.price).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              )),

        const SizedBox(height: 8),
        Divider(color: borderColor, height: 1),
        const SizedBox(height: 8),

        // Subtotal, Shipping, Total
        _buildPriceRow('Subtotal', '\u{20B9}${order.subtotal ?? (order.totalAmount - 50)}', secondaryTextColor),
        const SizedBox(height: 4),
        _buildPriceRow('Shipping', '\u{20B9}${order.shippingCost ?? 50}', secondaryTextColor),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor,
              ),
            ),
            Text(
              '\u{20B9}${order.totalAmount}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color secondaryTextColor,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: secondaryTextColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: secondaryTextColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }
}

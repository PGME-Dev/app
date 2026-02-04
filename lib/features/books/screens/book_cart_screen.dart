import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/book_order_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/books/providers/book_provider.dart';

class BookCartScreen extends StatelessWidget {
  const BookCartScreen({super.key});

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
                  'Shopping Cart',
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

          // Cart Items
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, provider, _) {
                if (provider.isCartEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some books to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Browse Books'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  itemCount: provider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.cartItems[index];
                    return _buildCartItem(
                      context: context,
                      item: item,
                      provider: provider,
                      isDark: isDark,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      cardBgColor: cardBgColor,
                      borderColor: borderColor,
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Summary and Checkout
          Consumer<BookProvider>(
            builder: (context, provider, _) {
              if (provider.isCartEmpty) return const SizedBox.shrink();

              return Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 120),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  border: Border(
                    top: BorderSide(color: borderColor),
                  ),
                ),
                child: Column(
                  children: [
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
                    const SizedBox(height: 16),
                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => context.push('/book-checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Proceed to Checkout (${provider.cartItemCount} items)',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem({
    required BuildContext context,
    required CartItem item,
    required BookProvider provider,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardBgColor,
    required Color borderColor,
  }) {
    final placeholderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Image
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.menu_book,
                        size: 32,
                        color: textColor.withValues(alpha: 0.3),
                      ),
                    ),
                  )
                : Icon(
                    Icons.menu_book,
                    size: 32,
                    color: textColor.withValues(alpha: 0.3),
                  ),
          ),
          const SizedBox(width: 12),
          // Book Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                if (item.author != null)
                  Text(
                    item.author!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '\u{20B9}${item.price}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity Controls
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onTap: () => provider.decrementQuantity(item.bookId),
                      isDark: isDark,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onTap: () => provider.incrementQuantity(item.bookId),
                      isDark: isDark,
                    ),
                    const Spacer(),
                    // Remove button
                    IconButton(
                      onPressed: () => provider.removeFromCart(item.bookId),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

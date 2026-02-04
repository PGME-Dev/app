import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/book_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/books/providers/book_provider.dart';

class OrderPhysicalBooksScreen extends StatefulWidget {
  const OrderPhysicalBooksScreen({super.key});

  @override
  State<OrderPhysicalBooksScreen> createState() => _OrderPhysicalBooksScreenState();
}

class _OrderPhysicalBooksScreenState extends State<OrderPhysicalBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BookProvider>(context, listen: false);
      if (provider.books.isEmpty) {
        provider.loadBooks();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<BookProvider>(context, listen: false);
      provider.loadMoreBooks();
    }
  }

  void _onSearch(String query) {
    final provider = Provider.of<BookProvider>(context, listen: false);
    provider.searchBooks(query);
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
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF1A1A4D) : const Color(0xFF000080);
    final cardFooterBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFE4F4FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16),
            child: Row(
              children: [
                // Back Arrow
                GestureDetector(
                  onTap: () => context.pop(),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: textColor,
                    ),
                  ),
                ),
                const Spacer(),
                // Title
                Text(
                  'Order Books',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.0,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                // Cart icon with badge
                Consumer<BookProvider>(
                  builder: (context, provider, _) {
                    return GestureDetector(
                      onTap: () => context.push('/book-cart'),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 24,
                            color: textColor,
                          ),
                          if (provider.cartItemCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${provider.cartItemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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
          ),

          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search,
                    size: 24,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search the book you want...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 20 / 12,
                          letterSpacing: -0.5,
                          color: textColor.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Books Grid
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingBooks && provider.books.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.booksError != null && provider.books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
                        const SizedBox(height: 16),
                        Text(
                          provider.booksError!,
                          style: TextStyle(color: secondaryTextColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadBooks(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 48, color: secondaryTextColor),
                        const SizedBox(height: 16),
                        Text(
                          'No books available',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadBooks(refresh: true),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding + 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 170 / 284,
                    ),
                    itemCount: provider.books.length + (provider.pagination?.hasNext == true ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.books.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final book = provider.books[index];
                      return _buildBookCard(
                        context: context,
                        book: book,
                        provider: provider,
                        isDark: isDark,
                        textColor: textColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        cardFooterBgColor: cardFooterBgColor,
                        buttonColor: buttonColor,
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

  Widget _buildBookCard({
    required BuildContext context,
    required BookModel book,
    required BookProvider provider,
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color borderColor,
    required Color cardFooterBgColor,
    required Color buttonColor,
  }) {
    final placeholderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final isInCart = provider.isInCart(book.bookId);

    return GestureDetector(
      onTap: () => context.push('/book/${book.bookId}'),
      child: Container(
        width: 170,
        height: 284,
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Upper part - with image
            Container(
              width: 170,
              height: 163,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: book.thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      child: Image.network(
                        book.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Container(
                            width: 71,
                            height: 68,
                            color: placeholderColor,
                            child: Icon(
                              Icons.menu_book,
                              size: 32,
                              color: textColor.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        width: 71,
                        height: 68,
                        color: placeholderColor,
                        child: Icon(
                          Icons.menu_book,
                          size: 32,
                          color: textColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
            ),
            // Lower part - with details
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardFooterBgColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Name
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.2,
                        color: textColor,
                      ),
                    ),
                    // Author Name
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1.2,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '\u{20B9}${book.actualPrice}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.2,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (book.hasDiscount) ...[
                          const SizedBox(width: 4),
                          Text(
                            '\u{20B9}${book.originalPrice}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              height: 1.2,
                              color: textColor.withValues(alpha: 0.5),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    // Add to Cart / In Cart Button
                    GestureDetector(
                      onTap: () {
                        if (!isInCart) {
                          provider.addToCart(book);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${book.title} added to cart'),
                              duration: const Duration(seconds: 1),
                              action: SnackBarAction(
                                label: 'View Cart',
                                onPressed: () => context.push('/book-cart'),
                              ),
                            ),
                          );
                        } else {
                          context.push('/book-cart');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isInCart ? Colors.green : buttonColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isInCart ? 'In Cart' : 'Add',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

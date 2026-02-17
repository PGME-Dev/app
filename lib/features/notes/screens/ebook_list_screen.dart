import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/models/book_model.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';
import 'package:pgme/core/services/book_service.dart';
import 'package:pgme/core/services/ebook_order_service.dart';
import 'package:pgme/core/widgets/zoho_payment_widget.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class EbookListScreen extends StatefulWidget {
  const EbookListScreen({super.key});

  @override
  State<EbookListScreen> createState() => _EbookListScreenState();
}

class _EbookListScreenState extends State<EbookListScreen> {
  final BookService _bookService = BookService();
  final EbookOrderService _ebookOrderService = EbookOrderService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<BookModel> _ebooks = [];
  Set<String> _purchasedBookIds = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isPurchasing = false;
  String? _error;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadEbooks();
    _loadPurchasedEbooks();
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
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadEbooks({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
      });
    }

    try {
      final response = await _bookService.getBooks(
        ebook: true,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _ebooks = response.books;
          } else {
            _ebooks.addAll(response.books);
          }
          _hasMore = response.pagination.hasNext;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _loadEbooks(reset: false);
  }

  Future<void> _loadPurchasedEbooks() async {
    try {
      final purchased = await _ebookOrderService.getUserPurchasedEbooks();
      if (mounted) {
        setState(() {
          _purchasedBookIds = purchased.map((e) => e.bookId).toSet();
        });
      }
    } catch (e) {
      debugPrint('Error loading purchased ebooks: $e');
    }
  }

  String _formatPrice(int price) {
    return '₹${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Future<void> _handleBuy(BookModel book) async {
    if (_isPurchasing) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    // Show confirmation dialog
    final shouldBuy = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => _buildBuyDialog(dialogContext, book, isDark),
    );

    if (shouldBuy != true || !mounted) return;

    setState(() => _isPurchasing = true);

    try {
      // Step 1: Create payment session
      final paymentSession = await _ebookOrderService.createPaymentSession(book.bookId);

      if (!mounted) return;

      // Step 2: Show Zoho payment widget
      final result = await Navigator.of(context, rootNavigator: true).push<ZohoPaymentResponse>(
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
          final verification = await _ebookOrderService.verifyPayment(
            paymentSessionId: result.paymentSessionId!,
            paymentId: result.paymentId!,
            signature: result.signature,
          );

          if (verification.success && mounted) {
            setState(() {
              _purchasedBookIds.add(book.bookId);
              _isPurchasing = false;
            });
            _showSuccess('eBook purchased successfully!');
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
        _showError('Error: ${e.toString().replaceAll("Exception: ", "")}');
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _handleRead(BookModel book) async {
    try {
      final data = await _ebookOrderService.getEbookViewUrl(book.bookId);
      if (mounted) {
        final url = data['url'] as String?;
        final title = data['title'] as String? ?? book.title;
        if (url != null) {
          context.pushNamed(
            'pdf-viewer',
            queryParameters: {
              'pdfUrl': url,
              'title': title,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to open eBook: ${e.toString().replaceAll("Exception: ", "")}');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
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

  Widget _buildBuyDialog(BuildContext dialogContext, BookModel book, bool isDark) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final dialogBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);

    final dialogRadius = isTablet ? 28.0 : 20.0;
    final titleSize = isTablet ? 22.0 : 18.0;
    final descSize = isTablet ? 15.0 : 13.0;
    final priceSize = isTablet ? 28.0 : 22.0;
    final btnHeight = isTablet ? 52.0 : 44.0;
    final btnFontSize = isTablet ? 18.0 : 15.0;
    final btnRadius = isTablet ? 14.0 : 10.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? 80 : 32),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBgColor,
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        padding: EdgeInsets.all(isTablet ? 28 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(false),
                child: Icon(Icons.close, size: isTablet ? 28 : 22, color: secondaryTextColor),
              ),
            ),

            // Book thumbnail
            if (book.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                child: CachedNetworkImage(
                  imageUrl: book.thumbnailUrl!,
                  width: isTablet ? 120 : 90,
                  height: isTablet ? 160 : 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: isTablet ? 120 : 90,
                    height: isTablet ? 160 : 120,
                    color: isDark ? AppColors.darkCardBackground : const Color(0xFFF0F0F0),
                    child: Icon(Icons.menu_book, size: isTablet ? 40 : 30, color: secondaryTextColor),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: isTablet ? 120 : 90,
                    height: isTablet ? 160 : 120,
                    color: isDark ? AppColors.darkCardBackground : const Color(0xFFF0F0F0),
                    child: Icon(Icons.menu_book, size: isTablet ? 40 : 30, color: secondaryTextColor),
                  ),
                ),
              )
            else
              Container(
                width: isTablet ? 120 : 90,
                height: isTablet ? 160 : 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBackground : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                ),
                child: Icon(Icons.menu_book, size: isTablet ? 40 : 30, color: secondaryTextColor),
              ),

            SizedBox(height: isTablet ? 18 : 14),

            // Title
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: titleSize,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: isTablet ? 6 : 4),

            // Author
            Text(
              book.author,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: descSize,
                color: secondaryTextColor,
              ),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            Divider(height: 1, color: borderColor),

            SizedBox(height: isTablet ? 16 : 12),

            // Price
            Text(
              _formatPrice(book.actualPrice),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: priceSize,
                color: textColor,
              ),
            ),

            if (book.hasDiscount) ...[
              SizedBox(height: isTablet ? 4 : 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatPrice(book.originalPrice ?? book.price),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: descSize,
                      color: secondaryTextColor,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${book.discount}% OFF',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: isTablet ? 20 : 16),

            // Buy button
            SizedBox(
              width: double.infinity,
              height: btnHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(btnRadius),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Buy Now',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: btnFontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 10 : 8),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: btnHeight,
              child: OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: buttonColor, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(btnRadius),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: btnFontSize,
                    color: buttonColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final searchBarColor = isDark ? AppColors.darkSurface : Colors.white;
    final searchBarBorderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

    final hPadding = isTablet ? ResponsiveHelper.horizontalPadding(context) : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxContentWidth(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.only(top: topPadding + (isTablet ? 21 : 16), left: hPadding, right: hPadding),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: isTablet ? 24 : 20,
                            color: textColor,
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Text(
                          'eBook Store',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 25 : 20,
                            height: 1.0,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            _loadEbooks();
                            _loadPurchasedEbooks();
                          },
                          child: Icon(
                            Icons.refresh,
                            size: isTablet ? 28 : 24,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 21 : 16),

                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Container(
                      width: double.infinity,
                      height: isTablet ? 56 : 48,
                      decoration: BoxDecoration(
                        color: searchBarColor,
                        borderRadius: BorderRadius.circular(isTablet ? 23 : 18),
                        border: Border.all(color: searchBarBorderColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: isTablet ? 20 : 16),
                          Icon(Icons.search, size: isTablet ? 30 : 24, color: secondaryTextColor),
                          SizedBox(width: isTablet ? 16 : 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                _searchQuery = value;
                              },
                              onSubmitted: (_) => _loadEbooks(),
                              decoration: InputDecoration(
                                hintText: 'Search eBooks...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: isTablet ? 15 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: textColor.withValues(alpha: 0.4),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isTablet ? 15 : 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.5,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _searchQuery = '';
                                _loadEbooks();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: isTablet ? 16 : 12),
                                child: Icon(Icons.clear, size: isTablet ? 24 : 20, color: secondaryTextColor),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 21 : 16),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: iconColor))
                        : _error != null
                            ? _buildErrorState(textColor, secondaryTextColor, iconColor, isTablet)
                            : _ebooks.isEmpty
                                ? _buildEmptyState(textColor, secondaryTextColor, isTablet)
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      await _loadEbooks();
                                      await _loadPurchasedEbooks();
                                    },
                                    child: GridView.builder(
                                      controller: _scrollController,
                                      padding: EdgeInsets.only(
                                        left: hPadding,
                                        right: hPadding,
                                        bottom: 100,
                                      ),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isTablet ? 3 : 2,
                                        crossAxisSpacing: isTablet ? 16 : 12,
                                        mainAxisSpacing: isTablet ? 16 : 12,
                                        childAspectRatio: isTablet ? 0.58 : 0.55,
                                      ),
                                      itemCount: _ebooks.length + (_isLoadingMore ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index == _ebooks.length) {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: CircularProgressIndicator(color: iconColor),
                                            ),
                                          );
                                        }
                                        return _buildEbookCard(
                                          _ebooks[index],
                                          isDark: isDark,
                                          isTablet: isTablet,
                                          textColor: textColor,
                                          secondaryTextColor: secondaryTextColor,
                                          iconColor: iconColor,
                                        );
                                      },
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay during purchase
          if (_isPurchasing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color textColor, Color secondaryTextColor, Color iconColor, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: isTablet ? 64 : 48, color: secondaryTextColor),
          SizedBox(height: isTablet ? 21 : 16),
          Text(
            'Failed to load eBooks',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTablet ? 20 : 16,
              color: textColor,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          Text(
            _error!.replaceAll('Exception: ', ''),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTablet ? 15 : 12,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 21 : 16),
          ElevatedButton(
            onPressed: _loadEbooks,
            style: ElevatedButton.styleFrom(backgroundColor: iconColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryTextColor, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: isTablet ? 80 : 64,
            color: secondaryTextColor,
          ),
          SizedBox(height: isTablet ? 21 : 16),
          Text(
            'No eBooks available',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          Text(
            'Check back later for new eBooks',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTablet ? 17 : 14,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEbookCard(
    BookModel book, {
    required bool isDark,
    required bool isTablet,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
  }) {
    final isPurchased = _purchasedBookIds.contains(book.bookId);
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE8EEF4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    const purchasedColor = Color(0xFF4CAF50);

    final titleSize = isTablet ? 15.0 : 13.0;
    final metaSize = isTablet ? 12.0 : 10.0;
    final priceSize = isTablet ? 16.0 : 14.0;
    final btnFontSize = isTablet ? 14.0 : 12.0;
    final cardRadius = isTablet ? 16.0 : 12.0;
    final imgHeight = isTablet ? 160.0 : 130.0;

    return GestureDetector(
      onTap: isPurchased ? () => _handleRead(book) : null,
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardRadius),
                topRight: Radius.circular(cardRadius),
              ),
              child: book.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: book.thumbnailUrl!,
                      width: double.infinity,
                      height: imgHeight,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(imgHeight, isDark, secondaryTextColor),
                      errorWidget: (context, url, error) => _buildPlaceholder(imgHeight, isDark, secondaryTextColor),
                    )
                  : _buildPlaceholder(imgHeight, isDark, secondaryTextColor),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: titleSize,
                        height: 1.2,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isTablet ? 4 : 2),

                    // Author
                    Text(
                      book.author,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: metaSize,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Format badge + pages
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (book.ebookFileFormat ?? 'PDF').toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: isTablet ? 10 : 9,
                              fontWeight: FontWeight.w600,
                              color: iconColor,
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        if (book.pages != null)
                          Text(
                            '${book.pages} pages',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: metaSize,
                              color: secondaryTextColor,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 8 : 6),

                    // Price + Buy/Read button
                    if (isPurchased)
                      SizedBox(
                        width: double.infinity,
                        height: isTablet ? 36 : 32,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleRead(book),
                          icon: Icon(Icons.menu_book, size: isTablet ? 18 : 14),
                          label: Text(
                            'Read',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: btnFontSize,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purchasedColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          // Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatPrice(book.actualPrice),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: priceSize,
                                    color: textColor,
                                  ),
                                ),
                                if (book.hasDiscount)
                                  Text(
                                    _formatPrice(book.originalPrice ?? book.price),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: metaSize,
                                      color: secondaryTextColor,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Buy button
                          SizedBox(
                            height: isTablet ? 36 : 32,
                            child: ElevatedButton(
                              onPressed: () => _handleBuy(book),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
                              ),
                              child: Text(
                                'Buy',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: btnFontSize,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildPlaceholder(double height, bool isDark, Color iconColor) {
    return Container(
      width: double.infinity,
      height: height,
      color: isDark ? AppColors.darkCardBackground : const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 40,
          color: iconColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

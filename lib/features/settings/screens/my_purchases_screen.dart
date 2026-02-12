import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/subscription_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen>
    with SingleTickerProviderStateMixin {
  final SubscriptionService _subscriptionService = SubscriptionService();
  late TabController _tabController;

  AllPurchasesData? _data;
  bool _isLoading = true;
  String? _error;

  final List<String> _tabs = [
    'Packages',
    'Books',
    'Sessions',
    'Invoices',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _subscriptionService.getAllPurchases();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);
    final headerColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor =
        isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final accentColor =
        isDark ? const Color(0xFF00BEFA) : const Color(0xFF0000C8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: headerColor,
            padding: EdgeInsets.only(top: topPadding + 16, bottom: 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back, size: 24, color: textColor),
                      ),
                      const Spacer(),
                      Text(
                        'My Purchases',
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
                // Tab bar
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: accentColor,
                  unselectedLabelColor: secondaryTextColor,
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  indicatorColor: accentColor,
                  indicatorWeight: 3,
                  dividerColor: borderColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState(textColor, secondaryTextColor)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPackagesTab(
                              isDark, textColor, secondaryTextColor,
                              cardColor, borderColor, accentColor),
                          _buildBooksTab(
                              isDark, textColor, secondaryTextColor,
                              cardColor, borderColor, accentColor),
                          _buildSessionsTab(
                              isDark, textColor, secondaryTextColor,
                              cardColor, borderColor, accentColor),
                          _buildInvoicesTab(
                              isDark, textColor, secondaryTextColor,
                              cardColor, borderColor, accentColor),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color textColor, Color secondaryTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      String message, IconData icon, Color textColor, Color secondaryTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: secondaryTextColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your purchases will appear here',
            style: TextStyle(fontSize: 14, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  // ── Packages Tab ──

  Widget _buildPackagesTab(bool isDark, Color textColor,
      Color secondaryTextColor, Color cardColor, Color borderColor, Color accentColor) {
    final packages = _data?.packages ?? [];
    if (packages.isEmpty) {
      return _buildEmptyState(
          'No package purchases', Icons.inventory_2_outlined, textColor, secondaryTextColor);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final pkg = packages[index];
          return _buildPackageCard(pkg, isDark, textColor, secondaryTextColor,
              cardColor, borderColor, accentColor);
        },
      ),
    );
  }

  Widget _buildPackageCard(
      PackagePurchaseItem pkg,
      bool isDark,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      Color borderColor,
      Color accentColor) {
    final isActive = pkg.isActive && pkg.daysRemaining > 0;
    final statusColor = isActive ? AppColors.success : Colors.orange;

    String formattedDate = '-';
    try {
      if (pkg.purchasedAt != null) {
        formattedDate =
            DateFormat('MMM dd, yyyy').format(DateTime.parse(pkg.purchasedAt!));
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.school_outlined, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pkg.packageType != null)
                      Text(
                        pkg.packageType!,
                        style: TextStyle(fontSize: 13, color: secondaryTextColor),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active' : 'Expired',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: secondaryTextColor),
              const SizedBox(width: 6),
              Text(formattedDate,
                  style: TextStyle(fontSize: 13, color: secondaryTextColor)),
              const Spacer(),
              Text(
                '\u{20B9}${pkg.amountPaid}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  '${pkg.daysRemaining} days remaining',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Books Tab ──

  Widget _buildBooksTab(bool isDark, Color textColor,
      Color secondaryTextColor, Color cardColor, Color borderColor, Color accentColor) {
    final books = _data?.books ?? [];
    if (books.isEmpty) {
      return _buildEmptyState(
          'No book orders', Icons.menu_book_outlined, textColor, secondaryTextColor);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildBookCard(book, isDark, textColor, secondaryTextColor,
              cardColor, borderColor);
        },
      ),
    );
  }

  Widget _buildBookCard(
      BookOrderItem book,
      bool isDark,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      Color borderColor) {
    Color statusColor;
    switch (book.orderStatus) {
      case 'confirmed':
      case 'delivered':
        statusColor = AppColors.success;
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

    String formattedDate = '-';
    try {
      if (book.purchasedAt != null) {
        formattedDate =
            DateFormat('MMM dd, yyyy').format(DateTime.parse(book.purchasedAt!));
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.orderNumber,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${book.itemsCount} item${book.itemsCount > 1 ? 's' : ''}',
                      style:
                          TextStyle(fontSize: 13, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  book.orderStatus[0].toUpperCase() +
                      book.orderStatus.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Items list
          ...book.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Icon(Icons.circle, size: 6, color: secondaryTextColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.title} (x${item.quantity})',
                        style: TextStyle(fontSize: 13, color: secondaryTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: secondaryTextColor),
              const SizedBox(width: 6),
              Text(formattedDate,
                  style: TextStyle(fontSize: 13, color: secondaryTextColor)),
              const Spacer(),
              Text(
                '\u{20B9}${book.totalAmount}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (book.trackingNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 14, color: secondaryTextColor),
                const SizedBox(width: 6),
                Text(
                  'Tracking: ${book.trackingNumber}',
                  style: TextStyle(fontSize: 13, color: secondaryTextColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Sessions Tab ──

  Widget _buildSessionsTab(bool isDark, Color textColor,
      Color secondaryTextColor, Color cardColor, Color borderColor, Color accentColor) {
    final sessions = _data?.liveSessions ?? [];
    if (sessions.isEmpty) {
      return _buildEmptyState('No session purchases',
          Icons.videocam_outlined, textColor, secondaryTextColor);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _buildSessionCard(session, isDark, textColor,
              secondaryTextColor, cardColor, borderColor, accentColor);
        },
      ),
    );
  }

  Widget _buildSessionCard(
      SessionPurchaseItem session,
      bool isDark,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      Color borderColor,
      Color accentColor) {
    Color statusColor;
    switch (session.sessionStatus) {
      case 'completed':
        statusColor = AppColors.success;
        break;
      case 'live':
        statusColor = Colors.red;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    String formattedDate = '-';
    try {
      if (session.scheduledStartTime != null) {
        formattedDate = DateFormat('MMM dd, yyyy • hh:mm a')
            .format(DateTime.parse(session.scheduledStartTime!));
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.videocam_outlined,
                    color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  session.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (session.sessionStatus ?? 'pending')[0].toUpperCase() +
                      (session.sessionStatus ?? 'pending').substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (session.facultyName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: secondaryTextColor),
                  const SizedBox(width: 6),
                  Text(
                    session.facultyName!,
                    style: TextStyle(fontSize: 13, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Icon(Icons.schedule_outlined,
                  size: 14, color: secondaryTextColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(formattedDate,
                    style: TextStyle(fontSize: 13, color: secondaryTextColor)),
              ),
              Text(
                '\u{20B9}${session.amountPaid}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Invoices Tab ──

  Widget _buildInvoicesTab(bool isDark, Color textColor,
      Color secondaryTextColor, Color cardColor, Color borderColor, Color accentColor) {
    final invoices = _data?.invoices ?? [];
    if (invoices.isEmpty) {
      return _buildEmptyState(
          'No invoices', Icons.receipt_long_outlined, textColor, secondaryTextColor);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return _buildInvoiceCard(invoice, isDark, textColor,
              secondaryTextColor, cardColor, borderColor, accentColor);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(
      InvoiceItem invoice,
      bool isDark,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      Color borderColor,
      Color accentColor) {
    final isPaid = invoice.paymentStatus == 'paid';

    String formattedDate = '-';
    try {
      if (invoice.createdAt != null) {
        formattedDate =
            DateFormat('MMM dd, yyyy').format(DateTime.parse(invoice.createdAt!));
      }
    } catch (_) {}

    String typeLabel;
    IconData typeIcon;
    Color typeColor;
    switch (invoice.purchaseType) {
      case 'session':
        typeLabel = 'Live Session';
        typeIcon = Icons.videocam_outlined;
        typeColor = Colors.purple;
        break;
      case 'book':
        typeLabel = 'Book Order';
        typeIcon = Icons.menu_book;
        typeColor = Colors.orange;
        break;
      default:
        typeLabel = 'Package';
        typeIcon = Icons.school_outlined;
        typeColor = accentColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    Text(
                      typeLabel,
                      style:
                          TextStyle(fontSize: 13, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPaid ? AppColors.success : Colors.orange)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPaid ? 'Paid' : 'Unpaid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPaid ? AppColors.success : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: secondaryTextColor),
              const SizedBox(width: 6),
              Text(formattedDate,
                  style: TextStyle(fontSize: 13, color: secondaryTextColor)),
              const Spacer(),
              Text(
                '\u{20B9}${(invoice.amount + invoice.gstAmount).toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (invoice.invoiceUrl != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(invoice.invoiceUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                children: [
                  Icon(Icons.download_outlined, size: 16, color: accentColor),
                  const SizedBox(width: 6),
                  Text(
                    'Download Invoice',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

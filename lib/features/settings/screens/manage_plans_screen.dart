import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/purchase_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/settings/providers/subscription_provider.dart';

class ManagePlansScreen extends StatefulWidget {
  const ManagePlansScreen({super.key});

  @override
  State<ManagePlansScreen> createState() => _ManagePlansScreenState();
}

class _ManagePlansScreenState extends State<ManagePlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadSubscriptionData();
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);
    final headerBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF000000).withValues(alpha: 0.5);
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final backButtonBgColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);
    final primaryColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: headerBgColor,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x0A000000),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: backButtonBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Manage Plans',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Consumer<SubscriptionProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: TextStyle(color: secondaryTextColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadSubscriptionData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final primaryPlan = provider.primarySubscription;
                final activePurchases = provider.activePurchases;
                final expiredPurchases = provider.expiredPurchases;

                return RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: bottomPadding + 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Plan Card
                        if (primaryPlan != null)
                          _buildCurrentPlanCard(primaryPlan, isDark, primaryColor)
                        else
                          _buildNoPlanCard(isDark, cardBgColor, textColor, secondaryTextColor, primaryColor),

                        const SizedBox(height: 24),

                        // Plan Details Section (only if has active plan)
                        if (primaryPlan != null) ...[
                          Text(
                            'Plan Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPlanDetailsCard(primaryPlan, isDark, cardBgColor, textColor, primaryColor),
                          const SizedBox(height: 24),
                        ],

                        // Subscription History Section
                        Text(
                          'Subscription History',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (activePurchases.isEmpty && expiredPurchases.isEmpty)
                          _buildEmptyHistory(secondaryTextColor)
                        else ...[
                          // Active subscriptions
                          ...activePurchases.map((purchase) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildHistoryItem(
                                  purchase: purchase,
                                  isActive: true,
                                  isDark: isDark,
                                  cardBgColor: cardBgColor,
                                  textColor: textColor,
                                  secondaryTextColor: secondaryTextColor,
                                  primaryColor: primaryColor,
                                  dividerColor: dividerColor,
                                ),
                              )),
                          // Expired subscriptions
                          ...expiredPurchases.map((purchase) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildHistoryItem(
                                  purchase: purchase,
                                  isActive: false,
                                  isDark: isDark,
                                  cardBgColor: cardBgColor,
                                  textColor: textColor,
                                  secondaryTextColor: secondaryTextColor,
                                  primaryColor: primaryColor,
                                  dividerColor: dividerColor,
                                ),
                              )),
                        ],

                        const SizedBox(height: 24),

                        // Actions Section
                        Text(
                          'Actions',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons
                        _buildActionItem(
                          icon: Icons.upgrade_outlined,
                          title: provider.hasActiveSubscription ? 'Upgrade Plan' : 'Get a Plan',
                          subtitle: provider.hasActiveSubscription
                              ? 'Get access to more features'
                              : 'Subscribe to unlock premium content',
                          onTap: () {
                            context.push('/all-packages');
                          },
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          primaryColor: primaryColor,
                        ),
                        if (provider.hasActiveSubscription) ...[
                          const SizedBox(height: 12),
                          _buildActionItem(
                            icon: Icons.autorenew,
                            title: 'Renew Subscription',
                            subtitle: 'Extend your current plan',
                            onTap: () {
                              context.push('/all-packages');
                            },
                            isDark: isDark,
                            cardBgColor: cardBgColor,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(height: 12),
                          _buildActionItem(
                            icon: Icons.receipt_long_outlined,
                            title: 'View Invoices',
                            subtitle: 'Download payment receipts',
                            onTap: () {
                              _showInvoicesBottomSheet(provider.purchases);
                            },
                            isDark: isDark,
                            cardBgColor: cardBgColor,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            primaryColor: primaryColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(PurchaseModel plan, bool isDark, Color primaryColor) {
    final packageName = plan.package.name;
    final price = _formatCurrency(plan.amountPaid);
    final durationText = '${plan.package.durationDays} days';
    final expiryDate = _formatDate(plan.expiresAt);
    final daysLeft = plan.daysRemaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0D2A5C), const Color(0xFF2D5A9E)]
              : [const Color(0xFF0000D1), const Color(0xFF4B4BFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'CURRENT PLAN',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Plan Name
          Text(
            packageName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ $durationText',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 20),

          // Expiry Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES ON',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiryDate,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'DAYS LEFT',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$daysLeft Days',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlanCard(bool isDark, Color cardBgColor, Color textColor, Color secondaryTextColor, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 48,
            color: secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Subscription',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscribe to a plan to unlock premium content',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.push('/all-packages'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Explore Plans',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsCard(PurchaseModel plan, bool isDark, Color cardBgColor, Color textColor, Color primaryColor) {
    final features = plan.package.features;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (features != null && features.isNotEmpty)
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildFeatureRow(Icons.check_circle_outline, feature, true, isDark, textColor, primaryColor),
                ))
          else ...[
            _buildFeatureRow(Icons.play_circle_outline, 'Video Lectures', true, isDark, textColor, primaryColor),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.menu_book_outlined, 'Comprehensive Notes', true, isDark, textColor, primaryColor),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.live_tv_outlined, 'Live Doubt Sessions', true, isDark, textColor, primaryColor),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.support_agent_outlined, 'Support', true, isDark, textColor, primaryColor),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool included, bool isDark, Color textColor, Color primaryColor) {
    final disabledColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF999999);
    final disabledBgColor = isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: included
                ? primaryColor.withValues(alpha: 0.1)
                : disabledBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: included ? primaryColor : disabledColor,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: included ? textColor : disabledColor,
            ),
          ),
        ),
        Icon(
          included ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: included ? const Color(0xFF4CAF50) : disabledBgColor,
        ),
      ],
    );
  }

  Widget _buildEmptyHistory(Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: secondaryTextColor,
            ),
            const SizedBox(height: 12),
            Text(
              'No subscription history',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required PurchaseModel purchase,
    required bool isActive,
    required bool isDark,
    required Color cardBgColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color primaryColor,
    required Color dividerColor,
  }) {
    final title = purchase.package.name;
    final date = _formatDate(isActive ? purchase.expiresAt : purchase.purchasedAt);
    final amount = _formatCurrency(purchase.amountPaid);
    final status = isActive ? 'Active' : 'Expired';

    final inactiveBgColor = isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5);
    final inactiveColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF999999);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? primaryColor.withValues(alpha: 0.3) : dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? primaryColor.withValues(alpha: 0.1)
                  : inactiveBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 22,
                color: isActive ? primaryColor : inactiveColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? 'Expires: $date' : 'Purchased: $date',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          // Amount and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : (isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF4CAF50) : inactiveColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    required bool isDark,
    required Color cardBgColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFFF5252).withValues(alpha: 0.1)
                    : primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: isDestructive ? const Color(0xFFFF5252) : primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? const Color(0xFFFF5252) : textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive
                  ? const Color(0xFFFF5252).withValues(alpha: 0.5)
                  : textColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoicesBottomSheet(List<PurchaseModel> purchases) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final sheetBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF000000).withValues(alpha: 0.5);
    final itemBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFF5F7FA);
    final primaryColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);

    // Filter completed purchases only for invoices
    final completedPurchases = purchases
        .where((p) => p.paymentStatus == 'completed')
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetBgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoices',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            if (completedPurchases.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No invoices available',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: completedPurchases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final purchase = completedPurchases[index];
                    return _buildInvoiceItem(
                      purchase.package.name,
                      _formatDate(purchase.purchasedAt),
                      _formatCurrency(purchase.amountPaid),
                      isDark,
                      textColor,
                      secondaryTextColor,
                      itemBgColor,
                      primaryColor,
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(String title, String date, String amount, bool isDark, Color textColor, Color secondaryTextColor, Color itemBgColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: itemBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.receipt_outlined,
                size: 18,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

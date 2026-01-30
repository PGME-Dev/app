import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class AllPackagesScreen extends StatefulWidget {
  const AllPackagesScreen({super.key});

  @override
  State<AllPackagesScreen> createState() => _AllPackagesScreenState();
}

class _AllPackagesScreenState extends State<AllPackagesScreen> {
  int _selectedIndex = 0;

  final List<PackageData> _packages = [
    PackageData(
      title: 'Theory Package',
      subtitle: 'Master the fundamentals',
      price: '₹4,999',
      originalPrice: '₹9,999',
      duration: '3 months',
      discount: '50% OFF',
      features: [
        '150+ Video Lectures',
        'Comprehensive Notes',
        'Live Doubt Sessions',
        'Practice MCQs',
      ],
      gradientColors: [const Color(0xFF1847A2), const Color(0xFF5B9BD5)],
      darkGradientColors: [const Color(0xFF0D2A5C), const Color(0xFF1A5A9E)],
      icon: Icons.menu_book_outlined,
      isPopular: true,
    ),
    PackageData(
      title: 'Practical Package',
      subtitle: 'Hands-on learning',
      price: '₹3,999',
      originalPrice: '₹7,999',
      duration: '3 months',
      discount: '50% OFF',
      features: [
        'Clinical Case Studies',
        'Practical Demonstrations',
        'Lab Techniques',
        'Skill Assessments',
      ],
      gradientColors: [const Color(0xFF6B4EAF), const Color(0xFF9D7FD9)],
      darkGradientColors: [const Color(0xFF3D2A6B), const Color(0xFF6B4EAF)],
      icon: Icons.science_outlined,
      isPopular: false,
    ),
    PackageData(
      title: 'Complete Bundle',
      subtitle: 'Theory + Practical',
      price: '₹7,499',
      originalPrice: '₹17,998',
      duration: '6 months',
      discount: '58% OFF',
      features: [
        'All Theory Content',
        'All Practical Content',
        'Priority Support',
        'Certificate of Completion',
        'Lifetime Access to Notes',
      ],
      gradientColors: [const Color(0xFFE85D04), const Color(0xFFFFAA5B)],
      darkGradientColors: [const Color(0xFF8B3800), const Color(0xFFE85D04)],
      icon: Icons.workspace_premium_outlined,
      isPopular: false,
      isBestValue: true,
    ),
    PackageData(
      title: 'Revision Series',
      subtitle: 'Quick exam prep',
      price: '₹1,999',
      originalPrice: '₹3,999',
      duration: '1 month',
      discount: '50% OFF',
      features: [
        'Rapid Revision Videos',
        'Important Topics Only',
        'Last-minute Tips',
        'Mock Tests',
      ],
      gradientColors: [const Color(0xFF059669), const Color(0xFF34D399)],
      darkGradientColors: [const Color(0xFF03543F), const Color(0xFF059669)],
      icon: Icons.speed_outlined,
      isPopular: false,
    ),
  ];

  void _selectPackage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _enrollPackage(PackageData package) {
    context.pop();
    // Navigate to payment with selected package
    context.push('/purchase');
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final borderColor = isDark ? AppColors.darkDivider : Colors.transparent;
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final priceColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
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
                      color: backgroundColor,
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
                    'Choose Your Package',
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

          // Package List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: bottomPadding + 100),
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final package = _packages[index];
                final isSelected = _selectedIndex == index;
                return _buildPackageCard(package, index, isSelected, isDark, textColor, secondaryTextColor, cardBgColor, borderColor);
              },
            ),
          ),
        ],
      ),

      // Bottom Enroll Button
      bottomSheet: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: bottomPadding + 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Selected package info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _packages[_selectedIndex].title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _packages[_selectedIndex].price,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: priceColor,
                    ),
                  ),
                ],
              ),
            ),
            // Enroll Button
            GestureDetector(
              onTap: () => _enrollPackage(_packages[_selectedIndex]),
              child: Container(
                width: 160,
                height: 54,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Enroll Now',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildPackageCard(PackageData package, int index, bool isSelected, bool isDark, Color textColor, Color secondaryTextColor, Color cardBgColor, Color borderColor) {
    final selectedBorderColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2);
    final featureTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF333333);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFFEEEEEE);

    return GestureDetector(
      onTap: () => _selectPackage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedBorderColor : borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? selectedBorderColor.withValues(alpha: 0.15)
                  : (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05)),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark ? package.darkGradientColors : package.gradientColors,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        package.icon,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          package.subtitle,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badges
                  if (package.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'POPULAR',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: package.gradientColors[0],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (package.isBestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'BEST VALUE',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: package.gradientColors[0],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Features
                  ...package.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: (isDark ? package.darkGradientColors[0] : package.gradientColors[0]).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: isDark ? package.darkGradientColors[1] : package.gradientColors[0],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          feature,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: featureTextColor,
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 10),
                  Divider(color: dividerColor, height: 1),
                  const SizedBox(height: 16),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.price,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: isDark ? package.darkGradientColors[1] : package.gradientColors[0],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          package.originalPrice,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: textColor.withValues(alpha: 0.4),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          package.discount,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '/ ${package.duration}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),

                  // Selection indicator
                  if (isSelected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2)).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selected Package',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageData {
  final String title;
  final String subtitle;
  final String price;
  final String originalPrice;
  final String duration;
  final String discount;
  final List<String> features;
  final List<Color> gradientColors;
  final List<Color> darkGradientColors;
  final IconData icon;
  final bool isPopular;
  final bool isBestValue;

  PackageData({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.originalPrice,
    required this.duration,
    required this.discount,
    required this.features,
    required this.gradientColors,
    required this.darkGradientColors,
    required this.icon,
    this.isPopular = false,
    this.isBestValue = false,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';
import 'package:pgme/core/widgets/terms_and_conditions_content.dart';

/// Forced-read Terms & Conditions gate.
///
/// "I Agree" stays disabled until the document has been scrolled to (near) the
/// bottom, so agreeing requires actually reaching the end rather than ticking
/// a box. Matches the web store's `TermsGateModal`, which the app's plain
/// checkbox did not — there, a user could accept without the terms ever being
/// on screen.
///
/// Returns `true` from [show] when the user agreed, `null`/`false` otherwise.
class TermsGateSheet extends StatefulWidget {
  const TermsGateSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final agreed = await showModalBottomSheet<bool>(
      context: context,
    // Present above the ShellRoute scaffold, otherwise the floating
    // bottom nav bar draws on top of the sheet and hides its actions.
    useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // The document is long and the gate is the point — don't let a stray
      // tap outside dismiss it mid-read.
      isDismissible: true,
      builder: (_) => const TermsGateSheet(),
    );
    return agreed ?? false;
  }

  @override
  State<TermsGateSheet> createState() => _TermsGateSheetState();
}

class _TermsGateSheetState extends State<TermsGateSheet> {
  final _scrollController = ScrollController();
  bool _reachedBottom = false;

  /// Distance from the true bottom at which we count the document as read.
  /// A few pixels of slack: momentum scrolling and fractional device pixel
  /// ratios routinely stop just short of maxScrollExtent.
  static const double _bottomSlack = 24;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // On a tall screen (or a short iOS document) the content can fit without
    // scrolling at all — otherwise "I Agree" would be permanently stuck.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfAlreadyAtEnd());
  }

  void _checkIfAlreadyAtEnd() {
    if (!mounted || _reachedBottom) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= _bottomSlack) {
      setState(() => _reachedBottom = true);
    }
  }

  void _onScroll() {
    if (_reachedBottom || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _bottomSlack) {
      setState(() => _reachedBottom = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    final sheetBg = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final accentColor = isDark ? AppColors.secondaryBlue : AppColors.primaryBlue;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final hPad = isTablet ? 28.0 : 20.0;

    return Container(
      // Caps at 92% so the sheet always reads as a sheet — the handle and the
      // page behind it stay visible, which is what tells the user this is
      // dismissible.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(isTablet ? 28 : 20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad - 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isTablet ? 22 : 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Icon(Icons.close_rounded, size: isTablet ? 26 : 22, color: secondaryTextColor),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),

          // Document
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(hPad, isTablet ? 22 : 18, hPad, isTablet ? 22 : 18),
              child: const TermsAndConditionsContent(),
            ),
          ),

          Divider(height: 1, color: dividerColor),

          // Action
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 14 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_reachedBottom)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Scroll to the bottom to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isTablet ? 13 : 11.5,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 48,
                  child: ElevatedButton(
                    onPressed: _reachedBottom
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      disabledBackgroundColor: accentColor.withValues(alpha: 0.35),
                      disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                    ),
                    child: Text(
                      'I Agree',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 18 : 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

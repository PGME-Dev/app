import 'package:flutter/material.dart';
import 'package:pgme/core/services/coupon_service.dart';
import 'package:pgme/core/theme/app_theme.dart';

/// Reusable coupon input for checkout screens. Previews the discount via the
/// backend; the coupon is applied authoritatively at create-order. Reports the
/// applied code (and discount) up via [onChanged] — null when cleared/invalid.
class CouponField extends StatefulWidget {
  final String purchaseType; // 'package' | 'session' | 'ebook' | 'book'
  final String? productId;
  final int? tierIndex;
  final List<Map<String, dynamic>>? items;
  final void Function(String? code, num discount) onChanged;

  /// Overridable for tests; production always uses the real [CouponService].
  final CouponApi? service;

  const CouponField({
    super.key,
    required this.purchaseType,
    this.productId,
    this.tierIndex,
    this.items,
    required this.onChanged,
    this.service,
  });

  @override
  State<CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<CouponField> {
  final _controller = TextEditingController();
  late final CouponApi _service = widget.service ?? CouponService();
  bool _loading = false;
  String? _error;
  CouponPreview? _applied;
  List<VisibleCoupon> _visible = const [];

  @override
  void initState() {
    super.initState();
    _loadVisibleCoupons();
  }

  /// Offers of the coupons the admin has made public for this product. Without
  /// these the field is only usable by someone who already knows a code, which
  /// is how the app differed from the web store.
  Future<void> _loadVisibleCoupons() async {
    final coupons = await _service.listVisibleCoupons(
      purchaseType: widget.purchaseType,
      productId: widget.productId,
      tierIndex: widget.tierIndex,
      items: widget.items,
    );
    if (!mounted) return;
    setState(() => _visible = coupons);
  }

  Future<void> _apply([String? explicitCode]) async {
    final code = (explicitCode ?? _controller.text).trim().toUpperCase();
    if (code.isEmpty) return;
    if (explicitCode != null) _controller.text = code;
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _service.validateCoupon(
      code: code,
      purchaseType: widget.purchaseType,
      productId: widget.productId,
      tierIndex: widget.tierIndex,
      items: widget.items,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.valid && res.beneficial) {
        _applied = res;
        _error = null;
        widget.onChanged(res.code ?? code, res.couponDiscount);
      } else {
        _applied = null;
        _error = res.reason ?? 'This coupon cannot be applied';
        widget.onChanged(null, 0);
      }
    });
  }

  void _remove() {
    setState(() {
      _applied = null;
      _error = null;
      _controller.clear();
    });
    widget.onChanged(null, 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A single offered coupon, styled as a dashed ticket to match the web
  /// store's suggestion chips.
  Widget _buildSuggestion(VisibleCoupon coupon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondaryBlue : AppColors.primaryBlue;
    final subtleText = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined, size: 18, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          coupon.code,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        coupon.shortLabel,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  if (coupon.description != null && coupon.description!.isNotEmpty)
                    Text(
                      coupon.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: subtleText,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _loading ? null : () => _apply(coupon.code),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
    final theme = Theme.of(context);
    if (_applied != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_applied!.code}   −₹${_applied!.couponDiscount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.success),
              ),
            ),
            TextButton(
              onPressed: _remove,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_visible.isNotEmpty) ...[
          ..._visible.map(_buildSuggestion),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _apply(),
                decoration: InputDecoration(
                  hintText: 'Coupon code',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _loading ? null : _apply,
              child: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Apply'),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_error!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}

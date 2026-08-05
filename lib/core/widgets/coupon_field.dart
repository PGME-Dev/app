import 'package:flutter/material.dart';
import 'package:pgme/core/services/coupon_service.dart';

/// Reusable coupon input for checkout screens. Previews the discount via the
/// backend; the coupon is applied authoritatively at create-order. Reports the
/// applied code (and discount) up via [onChanged] — null when cleared/invalid.
class CouponField extends StatefulWidget {
  final String purchaseType; // 'package' | 'session' | 'ebook' | 'book'
  final String? productId;
  final int? tierIndex;
  final List<Map<String, dynamic>>? items;
  final void Function(String? code, num discount) onChanged;

  const CouponField({
    super.key,
    required this.purchaseType,
    this.productId,
    this.tierIndex,
    this.items,
    required this.onChanged,
  });

  @override
  State<CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<CouponField> {
  final _controller = TextEditingController();
  final _service = CouponService();
  bool _loading = false;
  String? _error;
  CouponPreview? _applied;

  Future<void> _apply() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) return;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_applied != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_applied!.code}   −₹${_applied!.couponDiscount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
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

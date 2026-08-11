import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/services/api_service.dart';

/// Preview result for a coupon validation.
class CouponPreview {
  final bool valid;
  final bool beneficial;
  final String? reason;
  final String? code;
  final num couponDiscount;
  final num discountedBase;
  final num estimatedTotal;

  CouponPreview({
    required this.valid,
    required this.beneficial,
    this.reason,
    this.code,
    this.couponDiscount = 0,
    this.discountedBase = 0,
    this.estimatedTotal = 0,
  });

  factory CouponPreview.fromJson(Map<String, dynamic> json) {
    return CouponPreview(
      valid: json['valid'] == true,
      beneficial: json['beneficial'] == true,
      reason: json['reason'] as String?,
      code: json['code'] as String?,
      couponDiscount: (json['coupon_discount'] ?? 0) as num,
      discountedBase: (json['discounted_base'] ?? 0) as num,
      estimatedTotal: (json['estimated_total'] ?? 0) as num,
    );
  }
}

/// A coupon the admin has marked visible, offered as a suggestion at checkout
/// so customers don't have to already know a code.
class VisibleCoupon {
  final String code;
  final String? description;

  /// 'percentage' or 'fixed'.
  final String discountType;
  final num discountValue;
  final num? maxDiscountCap;
  final num? minOrderValue;

  VisibleCoupon({
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountCap,
    this.minOrderValue,
  });

  factory VisibleCoupon.fromJson(Map<String, dynamic> json) {
    return VisibleCoupon(
      code: (json['code'] ?? '') as String,
      description: json['description'] as String?,
      discountType: (json['discount_type'] ?? 'fixed') as String,
      discountValue: (json['discount_value'] ?? 0) as num,
      maxDiscountCap: json['max_discount_cap'] as num?,
      minOrderValue: json['min_order_value'] as num?,
    );
  }

  bool get isPercentage => discountType == 'percentage';

  /// Short "20% off" / "₹500 off" label for the suggestion chip.
  String get shortLabel => isPercentage
      ? '${discountValue.toStringAsFixed(0)}% off'
      : '₹${discountValue.toStringAsFixed(0)} off';
}

/// The coupon calls the checkout UI depends on.
///
/// Exists so widgets can be driven by a stub in tests — [CouponService] builds
/// an [ApiService] eagerly, so a test that constructed one would be making
/// real network setup a precondition of rendering a chip.
abstract class CouponApi {
  Future<CouponPreview> validateCoupon({
    required String code,
    required String purchaseType,
    String? productId,
    int? tierIndex,
    List<Map<String, dynamic>>? items,
  });

  Future<List<VisibleCoupon>> listVisibleCoupons({
    required String purchaseType,
    String? productId,
    int? tierIndex,
    List<Map<String, dynamic>>? items,
  });
}

/// Coupon preview client. The coupon is applied authoritatively at create-order;
/// this endpoint just previews the discount for the checkout UI.
class CouponService implements CouponApi {
  final ApiService _apiService = ApiService();

  /// [purchaseType]: 'package' | 'session' | 'ebook' | 'book' | 'form'
  @override
  Future<CouponPreview> validateCoupon({
    required String code,
    required String purchaseType,
    String? productId,
    int? tierIndex,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final payload = <String, dynamic>{
        'code': code,
        'purchase_type': purchaseType,
        if (productId != null) 'product_id': productId,
        if (tierIndex != null) 'tier_index': tierIndex,
        if (items != null) 'items': items,
      };
      final response = await _apiService.dio.post('/coupons/validate', data: payload);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return CouponPreview.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return CouponPreview(valid: false, beneficial: false, reason: response.data['message'] ?? 'Invalid coupon');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? data['message'] as String? : null;
      return CouponPreview(valid: false, beneficial: false, reason: msg ?? 'Failed to apply coupon');
    } catch (_) {
      return CouponPreview(valid: false, beneficial: false, reason: 'Failed to apply coupon');
    }
  }

  /// Admin-marked-visible, currently-usable coupons for a prospective purchase.
  ///
  /// Suggestions only — the code still goes through [validateCoupon] before it
  /// is shown as applied, and through create-order before it counts. Returns an
  /// empty list on any failure: a checkout must never be blocked because the
  /// suggestion endpoint had a bad day.
  @override
  Future<List<VisibleCoupon>> listVisibleCoupons({
    required String purchaseType,
    String? productId,
    int? tierIndex,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final payload = <String, dynamic>{
        'purchase_type': purchaseType,
        if (productId != null) 'product_id': productId,
        if (tierIndex != null) 'tier_index': tierIndex,
        if (items != null) 'items': items,
      };
      final response = await _apiService.dio.post('/coupons/visible', data: payload);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data']?['coupons'] as List<dynamic>?;
        final coupons = (list ?? [])
            .whereType<Map<String, dynamic>>()
            .map(VisibleCoupon.fromJson)
            .where((c) => c.code.isNotEmpty)
            .toList();
        if (kDebugMode) {
          debugPrint('[Coupons] visible for $payload -> '
              '${coupons.isEmpty ? 'none' : coupons.map((c) => c.code).join(', ')}');
        }
        return coupons;
      }
      if (kDebugMode) {
        debugPrint('[Coupons] visible request for $payload returned '
            '${response.statusCode}: ${response.data}');
      }
      return [];
    } catch (e) {
      // Swallowed on purpose — suggestions must never block a checkout — but
      // silence here is what made an empty chip list impossible to diagnose.
      if (kDebugMode) debugPrint('[Coupons] visible request failed: $e');
      return [];
    }
  }
}

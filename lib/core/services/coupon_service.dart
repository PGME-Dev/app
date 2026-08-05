import 'package:dio/dio.dart';
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

/// Coupon preview client. The coupon is applied authoritatively at create-order;
/// this endpoint just previews the discount for the checkout UI.
class CouponService {
  final ApiService _apiService = ApiService();

  /// [purchaseType]: 'package' | 'session' | 'ebook' | 'book' | 'form'
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
}

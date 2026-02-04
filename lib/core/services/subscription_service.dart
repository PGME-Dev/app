import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/purchase_model.dart';
import 'package:pgme/core/services/api_service.dart';

class SubscriptionService {
  final ApiService _apiService = ApiService();

  /// Get user's purchase history
  Future<List<PurchaseModel>> getUserPurchases({
    bool? isActive,
    String? paymentStatus,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }
      if (paymentStatus != null) {
        queryParams['payment_status'] = paymentStatus;
      }

      final response = await _apiService.dio.get(
        ApiConstants.purchases,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final purchasesData = response.data['data']['purchases'] as List;
        return purchasesData
            .map((json) => PurchaseModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load purchases');
    } catch (e) {
      throw Exception('Failed to load purchases: $e');
    }
  }

  /// Get subscription status (theory/practical)
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.subscriptionStatus,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SubscriptionStatus.fromJson(response.data['data']);
      }
      throw Exception('Failed to load subscription status');
    } catch (e) {
      throw Exception('Failed to load subscription status: $e');
    }
  }
}

/// Subscription status model
class SubscriptionStatus {
  final bool hasTheory;
  final bool hasPractical;
  final bool hasBoth;
  final List<ActivePackageInfo> theoryPackages;
  final List<ActivePackageInfo> practicalPackages;
  final int totalActiveSubscriptions;

  SubscriptionStatus({
    required this.hasTheory,
    required this.hasPractical,
    required this.hasBoth,
    required this.theoryPackages,
    required this.practicalPackages,
    required this.totalActiveSubscriptions,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      hasTheory: json['has_theory'] ?? false,
      hasPractical: json['has_practical'] ?? false,
      hasBoth: json['has_both'] ?? false,
      theoryPackages: (json['theory_packages'] as List? ?? [])
          .map((e) => ActivePackageInfo.fromJson(e))
          .toList(),
      practicalPackages: (json['practical_packages'] as List? ?? [])
          .map((e) => ActivePackageInfo.fromJson(e))
          .toList(),
      totalActiveSubscriptions: json['total_active_subscriptions'] ?? 0,
    );
  }

  /// Get all active packages combined
  List<ActivePackageInfo> get allActivePackages =>
      [...theoryPackages, ...practicalPackages];
}

/// Active package info from subscription status
class ActivePackageInfo {
  final String purchaseId;
  final String packageId;
  final String packageName;
  final String expiresAt;
  final int daysRemaining;

  ActivePackageInfo({
    required this.purchaseId,
    required this.packageId,
    required this.packageName,
    required this.expiresAt,
    required this.daysRemaining,
  });

  factory ActivePackageInfo.fromJson(Map<String, dynamic> json) {
    return ActivePackageInfo(
      purchaseId: json['purchase_id'] ?? '',
      packageId: json['package_id'] ?? '',
      packageName: json['package_name'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }
}

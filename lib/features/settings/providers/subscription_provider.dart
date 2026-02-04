import 'package:flutter/foundation.dart';
import 'package:pgme/core/models/purchase_model.dart';
import 'package:pgme/core/services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();

  // State
  List<PurchaseModel> _purchases = [];
  SubscriptionStatus? _subscriptionStatus;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PurchaseModel> get purchases => _purchases;
  SubscriptionStatus? get subscriptionStatus => _subscriptionStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get active purchases only
  List<PurchaseModel> get activePurchases =>
      _purchases.where((p) => p.isActive && p.daysRemaining > 0).toList();

  /// Get expired purchases
  List<PurchaseModel> get expiredPurchases =>
      _purchases.where((p) => !p.isActive || p.daysRemaining <= 0).toList();

  /// Get the primary active subscription (most recent or longest remaining)
  PurchaseModel? get primarySubscription {
    final active = activePurchases;
    if (active.isEmpty) return null;
    // Return the one with most days remaining
    active.sort((a, b) => b.daysRemaining.compareTo(a.daysRemaining));
    return active.first;
  }

  /// Check if user has any active subscription
  bool get hasActiveSubscription => activePurchases.isNotEmpty;

  /// Load all subscription data
  Future<void> loadSubscriptionData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Loading subscription data...');

      // Load both in parallel
      final results = await Future.wait([
        _subscriptionService.getUserPurchases(limit: 50),
        _subscriptionService.getSubscriptionStatus(),
      ]);

      _purchases = results[0] as List<PurchaseModel>;
      _subscriptionStatus = results[1] as SubscriptionStatus;

      debugPrint('✓ Loaded ${_purchases.length} purchases');
      debugPrint('✓ Active: ${activePurchases.length}, Expired: ${expiredPurchases.length}');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('✗ Error loading subscriptions: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh subscription data
  Future<void> refresh() async {
    await loadSubscriptionData();
  }

  /// Clear data (on logout)
  void clear() {
    _purchases = [];
    _subscriptionStatus = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

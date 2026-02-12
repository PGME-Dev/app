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

  /// Get all user purchases (packages, books, sessions, invoices)
  Future<AllPurchasesData> getAllPurchases() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.allPurchases,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AllPurchasesData.fromJson(response.data['data']);
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

/// All purchases data from unified endpoint
class AllPurchasesData {
  final List<PackagePurchaseItem> packages;
  final List<SessionPurchaseItem> liveSessions;
  final List<BookOrderItem> books;
  final List<InvoiceItem> invoices;
  final PurchaseSummary summary;

  AllPurchasesData({
    required this.packages,
    required this.liveSessions,
    required this.books,
    required this.invoices,
    required this.summary,
  });

  factory AllPurchasesData.fromJson(Map<String, dynamic> json) {
    return AllPurchasesData(
      packages: (json['packages'] as List? ?? [])
          .map((e) => PackagePurchaseItem.fromJson(e))
          .toList(),
      liveSessions: (json['live_sessions'] as List? ?? [])
          .map((e) => SessionPurchaseItem.fromJson(e))
          .toList(),
      books: (json['books'] as List? ?? [])
          .map((e) => BookOrderItem.fromJson(e))
          .toList(),
      invoices: (json['invoices'] as List? ?? [])
          .map((e) => InvoiceItem.fromJson(e))
          .toList(),
      summary: PurchaseSummary.fromJson(json['summary'] ?? {}),
    );
  }

  bool get isEmpty =>
      packages.isEmpty &&
      liveSessions.isEmpty &&
      books.isEmpty &&
      invoices.isEmpty;
}

class PackagePurchaseItem {
  final String purchaseId;
  final String name;
  final String? packageType;
  final String? thumbnailUrl;
  final num amountPaid;
  final String currency;
  final String? purchasedAt;
  final String? expiresAt;
  final bool isActive;
  final int daysRemaining;

  PackagePurchaseItem({
    required this.purchaseId,
    required this.name,
    this.packageType,
    this.thumbnailUrl,
    required this.amountPaid,
    required this.currency,
    this.purchasedAt,
    this.expiresAt,
    required this.isActive,
    required this.daysRemaining,
  });

  factory PackagePurchaseItem.fromJson(Map<String, dynamic> json) {
    return PackagePurchaseItem(
      purchaseId: json['purchase_id'] ?? '',
      name: json['name'] ?? '',
      packageType: json['package_type'],
      thumbnailUrl: json['thumbnail_url'],
      amountPaid: json['amount_paid'] ?? 0,
      currency: json['currency'] ?? 'INR',
      purchasedAt: json['purchased_at'],
      expiresAt: json['expires_at'],
      isActive: json['is_active'] ?? false,
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }
}

class SessionPurchaseItem {
  final String purchaseId;
  final String name;
  final String? sessionStatus;
  final String? scheduledStartTime;
  final String? facultyName;
  final num amountPaid;
  final String currency;
  final String? purchasedAt;
  final bool isActive;

  SessionPurchaseItem({
    required this.purchaseId,
    required this.name,
    this.sessionStatus,
    this.scheduledStartTime,
    this.facultyName,
    required this.amountPaid,
    required this.currency,
    this.purchasedAt,
    required this.isActive,
  });

  factory SessionPurchaseItem.fromJson(Map<String, dynamic> json) {
    return SessionPurchaseItem(
      purchaseId: json['purchase_id'] ?? '',
      name: json['name'] ?? '',
      sessionStatus: json['session_status'],
      scheduledStartTime: json['scheduled_start_time'],
      facultyName: json['faculty_name'],
      amountPaid: json['amount_paid'] ?? 0,
      currency: json['currency'] ?? 'INR',
      purchasedAt: json['purchased_at'],
      isActive: json['is_active'] ?? false,
    );
  }
}

class BookOrderItem {
  final String orderId;
  final String orderNumber;
  final List<BookOrderItemDetail> items;
  final int itemsCount;
  final num totalAmount;
  final String orderStatus;
  final String? trackingNumber;
  final String? courierName;
  final String? purchasedAt;

  BookOrderItem({
    required this.orderId,
    required this.orderNumber,
    required this.items,
    required this.itemsCount,
    required this.totalAmount,
    required this.orderStatus,
    this.trackingNumber,
    this.courierName,
    this.purchasedAt,
  });

  factory BookOrderItem.fromJson(Map<String, dynamic> json) {
    return BookOrderItem(
      orderId: json['order_id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => BookOrderItemDetail.fromJson(e))
          .toList(),
      itemsCount: json['items_count'] ?? 0,
      totalAmount: json['total_amount'] ?? 0,
      orderStatus: json['order_status'] ?? 'pending',
      trackingNumber: json['tracking_number'],
      courierName: json['courier_name'],
      purchasedAt: json['purchased_at'],
    );
  }
}

class BookOrderItemDetail {
  final String title;
  final int quantity;
  final num price;

  BookOrderItemDetail({
    required this.title,
    required this.quantity,
    required this.price,
  });

  factory BookOrderItemDetail.fromJson(Map<String, dynamic> json) {
    return BookOrderItemDetail(
      title: json['title'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: json['price'] ?? 0,
    );
  }
}

class InvoiceItem {
  final String invoiceId;
  final String invoiceNumber;
  final String purchaseType;
  final String? invoiceUrl;
  final num amount;
  final num gstAmount;
  final String paymentStatus;
  final String? createdAt;

  InvoiceItem({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.purchaseType,
    this.invoiceUrl,
    required this.amount,
    required this.gstAmount,
    required this.paymentStatus,
    this.createdAt,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      invoiceId: json['invoice_id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      purchaseType: json['purchase_type'] ?? 'package',
      invoiceUrl: json['invoice_url'],
      amount: json['amount'] ?? 0,
      gstAmount: json['gst_amount'] ?? 0,
      paymentStatus: json['payment_status'] ?? 'unpaid',
      createdAt: json['created_at'],
    );
  }
}

class PurchaseSummary {
  final int totalPackages;
  final int totalSessions;
  final int totalBookOrders;
  final int totalInvoices;

  PurchaseSummary({
    required this.totalPackages,
    required this.totalSessions,
    required this.totalBookOrders,
    required this.totalInvoices,
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseSummary(
      totalPackages: json['total_packages'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      totalBookOrders: json['total_book_orders'] ?? 0,
      totalInvoices: json['total_invoices'] ?? 0,
    );
  }
}

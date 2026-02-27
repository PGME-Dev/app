import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/access_record_model.dart';
import 'package:pgme/core/services/api_service.dart';

class AccessRecordService {
  final ApiService _apiService = ApiService();

  /// Get user's access record history
  Future<List<AccessRecordModel>> getUserRecords({
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
        ApiConstants.activeUserRecords,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final recordsData = response.data['data']['purchases'] as List;
        return recordsData
            .map((json) => AccessRecordModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load access records');
    } catch (e) {
      throw Exception('Failed to load access records: $e');
    }
  }

  /// Get all user records (packages, books, sessions, records)
  Future<AllRecordsData> getAllRecords() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.activeAllRecords,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AllRecordsData.fromJson(response.data['data']);
      }
      throw Exception('Failed to load records');
    } catch (e) {
      throw Exception('Failed to load records: $e');
    }
  }

  /// Get record details by record ID
  Future<InvoiceItem> getRecordByPurchaseId(String purchaseId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.activeRecordExport(purchaseId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final inv = response.data['data']['invoice'];
        return InvoiceItem(
          invoiceId: inv['invoice_id'] ?? '',
          invoiceNumber: inv['invoice_number'] ?? '',
          purchaseType: 'package',
          invoiceUrl: inv['invoice_url'],
          amount: inv['amount'] ?? 0,
          gstAmount: inv['gst_amount'] ?? 0,
          paymentStatus: 'paid',
          createdAt: inv['created_at'],
        );
      }
      throw Exception('Record not found');
    } catch (e) {
      throw Exception('Failed to load record: $e');
    }
  }

  /// Download record PDF as bytes
  Future<Uint8List> downloadRecordPdf(String invoiceId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.activeRecordPdf(invoiceId),
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      throw Exception('Failed to download record PDF');
    } catch (e) {
      throw Exception('Failed to download record PDF: $e');
    }
  }

  /// Get access level (theory/practical)
  Future<AccessLevel> getAccessLevel() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.activeAccessLevel,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AccessLevel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load access level');
    } catch (e) {
      throw Exception('Failed to load access level: $e');
    }
  }
}

/// Access level model
class AccessLevel {
  final bool hasTheory;
  final bool hasPractical;
  final bool hasBoth;
  final List<ActivePackageInfo> theoryPackages;
  final List<ActivePackageInfo> practicalPackages;
  final int totalActiveRecords;

  AccessLevel({
    required this.hasTheory,
    required this.hasPractical,
    required this.hasBoth,
    required this.theoryPackages,
    required this.practicalPackages,
    required this.totalActiveRecords,
  });

  factory AccessLevel.fromJson(Map<String, dynamic> json) {
    return AccessLevel(
      hasTheory: json['has_theory'] ?? false,
      hasPractical: json['has_practical'] ?? false,
      hasBoth: json['has_both'] ?? false,
      theoryPackages: (json['theory_packages'] as List? ?? [])
          .map((e) => ActivePackageInfo.fromJson(e))
          .toList(),
      practicalPackages: (json['practical_packages'] as List? ?? [])
          .map((e) => ActivePackageInfo.fromJson(e))
          .toList(),
      totalActiveRecords: json['total_active_subscriptions'] ?? 0,
    );
  }

  /// Get all active packages combined
  List<ActivePackageInfo> get allActivePackages =>
      [...theoryPackages, ...practicalPackages];
}

/// Active package info from access level
class ActivePackageInfo {
  final String purchaseId;
  final String packageId;
  final String packageName;
  final String expiresAt;
  final int daysRemaining;
  final int? tierIndex;
  final String? tierName;

  ActivePackageInfo({
    required this.purchaseId,
    required this.packageId,
    required this.packageName,
    required this.expiresAt,
    required this.daysRemaining,
    this.tierIndex,
    this.tierName,
  });

  factory ActivePackageInfo.fromJson(Map<String, dynamic> json) {
    return ActivePackageInfo(
      purchaseId: json['purchase_id'] ?? '',
      packageId: json['package_id'] ?? '',
      packageName: json['package_name'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      daysRemaining: json['days_remaining'] ?? 0,
      tierIndex: json['tier_index'],
      tierName: json['tier_name'],
    );
  }
}

/// All records data from unified endpoint
class AllRecordsData {
  final List<PackageRecordItem> packages;
  final List<SessionRecordItem> liveSessions;
  final List<BookRequestItem> books;
  final List<InvoiceItem> invoices;
  final RecordSummary summary;

  AllRecordsData({
    required this.packages,
    required this.liveSessions,
    required this.books,
    required this.invoices,
    required this.summary,
  });

  factory AllRecordsData.fromJson(Map<String, dynamic> json) {
    return AllRecordsData(
      packages: (json['packages'] as List? ?? [])
          .map((e) => PackageRecordItem.fromJson(e))
          .toList(),
      liveSessions: (json['live_sessions'] as List? ?? [])
          .map((e) => SessionRecordItem.fromJson(e))
          .toList(),
      books: (json['books'] as List? ?? [])
          .map((e) => BookRequestItem.fromJson(e))
          .toList(),
      invoices: (json['invoices'] as List? ?? [])
          .map((e) => InvoiceItem.fromJson(e))
          .toList(),
      summary: RecordSummary.fromJson(json['summary'] ?? {}),
    );
  }

  bool get isEmpty =>
      packages.isEmpty &&
      liveSessions.isEmpty &&
      books.isEmpty &&
      invoices.isEmpty;
}

class PackageRecordItem {
  final String purchaseId;
  final String packageId;
  final String name;
  final String? packageType;
  final String? thumbnailUrl;
  final num amountPaid;
  final String currency;
  final String? purchasedAt;
  final String? expiresAt;
  final bool isActive;
  final int daysRemaining;
  final int? tierIndex;
  final String? tierName;
  final bool isUpgrade;

  PackageRecordItem({
    required this.purchaseId,
    required this.packageId,
    required this.name,
    this.packageType,
    this.thumbnailUrl,
    required this.amountPaid,
    required this.currency,
    this.purchasedAt,
    this.expiresAt,
    required this.isActive,
    required this.daysRemaining,
    this.tierIndex,
    this.tierName,
    this.isUpgrade = false,
  });

  factory PackageRecordItem.fromJson(Map<String, dynamic> json) {
    return PackageRecordItem(
      purchaseId: json['purchase_id'] ?? '',
      packageId: json['package_id'] ?? '',
      name: json['name'] ?? '',
      packageType: json['package_type'],
      thumbnailUrl: json['thumbnail_url'],
      amountPaid: json['amount_paid'] ?? 0,
      currency: json['currency'] ?? 'INR',
      purchasedAt: json['purchased_at'],
      expiresAt: json['expires_at'],
      isActive: json['is_active'] ?? false,
      daysRemaining: json['days_remaining'] ?? 0,
      tierIndex: json['tier_index'],
      tierName: json['tier_name'],
      isUpgrade: json['is_upgrade'] ?? false,
    );
  }
}

class SessionRecordItem {
  final String purchaseId;
  final String name;
  final String? sessionStatus;
  final String? scheduledStartTime;
  final String? facultyName;
  final num amountPaid;
  final String currency;
  final String? purchasedAt;
  final bool isActive;

  SessionRecordItem({
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

  factory SessionRecordItem.fromJson(Map<String, dynamic> json) {
    return SessionRecordItem(
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

class BookRequestItem {
  final String orderId;
  final String orderNumber;
  final List<BookRequestItemDetail> items;
  final int itemsCount;
  final num totalAmount;
  final String orderStatus;
  final String? trackingNumber;
  final String? courierName;
  final String? purchasedAt;

  BookRequestItem({
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

  factory BookRequestItem.fromJson(Map<String, dynamic> json) {
    return BookRequestItem(
      orderId: json['order_id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => BookRequestItemDetail.fromJson(e))
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

class BookRequestItemDetail {
  final String title;
  final int quantity;
  final num price;

  BookRequestItemDetail({
    required this.title,
    required this.quantity,
    required this.price,
  });

  factory BookRequestItemDetail.fromJson(Map<String, dynamic> json) {
    return BookRequestItemDetail(
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
  final String? purchaseId;
  final String? invoiceUrl;
  final num amount;
  final num gstAmount;
  final String paymentStatus;
  final String? createdAt;

  InvoiceItem({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.purchaseType,
    this.purchaseId,
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
      purchaseId: json['purchase_id'],
      invoiceUrl: json['invoice_url'],
      amount: json['amount'] ?? 0,
      gstAmount: json['gst_amount'] ?? 0,
      paymentStatus: json['payment_status'] ?? 'unpaid',
      createdAt: json['created_at'],
    );
  }
}

class RecordSummary {
  final int totalPackages;
  final int totalSessions;
  final int totalBookRequests;
  final int totalInvoices;

  RecordSummary({
    required this.totalPackages,
    required this.totalSessions,
    required this.totalBookRequests,
    required this.totalInvoices,
  });

  factory RecordSummary.fromJson(Map<String, dynamic> json) {
    return RecordSummary(
      totalPackages: json['total_packages'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      totalBookRequests: json['total_book_orders'] ?? 0,
      totalInvoices: json['total_invoices'] ?? 0,
    );
  }
}

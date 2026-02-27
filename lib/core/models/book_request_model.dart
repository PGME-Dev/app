import 'package:json_annotation/json_annotation.dart';

part 'book_request_model.g.dart';

@JsonSerializable()
class BookRequestModel {
  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'order_number')
  final String orderNumber;

  @JsonKey(name: 'items_count')
  final int itemsCount;

  @JsonKey(name: 'total_amount')
  final num totalAmount;

  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  @JsonKey(name: 'order_status')
  final String orderStatus;

  @JsonKey(name: 'tracking_number')
  final String? trackingNumber;

  @JsonKey(name: 'courier_name')
  final String? courierName;

  @JsonKey(name: 'created_at')
  final String createdAt;

  // Detail fields (only present when fetching single order)
  final List<RequestItemModel>? items;

  @JsonKey(name: 'recipient_name')
  final String? recipientName;

  @JsonKey(name: 'shipping_phone')
  final String? shippingPhone;

  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;

  final num? subtotal;

  @JsonKey(name: 'shipping_cost')
  final num? shippingCost;

  @JsonKey(name: 'shipped_at')
  final String? shippedAt;

  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;

  final String? notes;

  BookRequestModel({
    required this.orderId,
    required this.orderNumber,
    required this.itemsCount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    this.trackingNumber,
    this.courierName,
    required this.createdAt,
    this.items,
    this.recipientName,
    this.shippingPhone,
    this.shippingAddress,
    this.subtotal,
    this.shippingCost,
    this.shippedAt,
    this.deliveredAt,
    this.notes,
  });

  factory BookRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BookRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookRequestModelToJson(this);

  /// Check if order can be cancelled
  bool get canCancel {
    return !['shipped', 'delivered', 'cancelled'].contains(orderStatus);
  }

  /// Get status display text
  String get statusDisplayText {
    switch (orderStatus) {
      case 'pending':
        return 'Payment Pending';
      case 'confirmed':
        return 'Order Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return orderStatus;
    }
  }

  /// Get payment status display text
  String get paymentStatusDisplayText {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus;
    }
  }
}

@JsonSerializable()
class RequestItemModel {
  @JsonKey(name: 'book_id')
  final String bookId;

  final String title;
  final String? author;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  final int quantity;
  final num price;

  RequestItemModel({
    required this.bookId,
    required this.title,
    this.author,
    this.thumbnailUrl,
    required this.quantity,
    required this.price,
  });

  factory RequestItemModel.fromJson(Map<String, dynamic> json) =>
      _$RequestItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$RequestItemModelToJson(this);

  /// Get total price for this item
  num get totalPrice => price * quantity;
}

@JsonSerializable()
class BookRequestResponse {
  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'razorpay_order_id')
  final String razorpayOrderId;

  final num amount;
  final String currency;

  @JsonKey(name: 'order_summary')
  final RequestSummary orderSummary;

  BookRequestResponse({
    required this.orderId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.orderSummary,
  });

  factory BookRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$BookRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BookRequestResponseToJson(this);
}

@JsonSerializable()
class RequestSummary {
  final List<RequestSummaryItem> items;
  final num subtotal;

  @JsonKey(name: 'shipping_cost')
  final num shippingCost;

  final num total;

  RequestSummary({
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
  });

  factory RequestSummary.fromJson(Map<String, dynamic> json) =>
      _$RequestSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RequestSummaryToJson(this);
}

@JsonSerializable()
class RequestSummaryItem {
  @JsonKey(name: 'book_id')
  final String bookId;

  final String title;
  final int quantity;
  final num price;

  RequestSummaryItem({
    required this.bookId,
    required this.title,
    required this.quantity,
    required this.price,
  });

  factory RequestSummaryItem.fromJson(Map<String, dynamic> json) =>
      _$RequestSummaryItemFromJson(json);

  Map<String, dynamic> toJson() => _$RequestSummaryItemToJson(this);
}

@JsonSerializable()
class RequestVerifyResponse {
  final bool success;

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'order_number')
  final String orderNumber;

  @JsonKey(name: 'order_status')
  final String orderStatus;

  final String message;

  RequestVerifyResponse({
    required this.success,
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.message,
  });

  factory RequestVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestVerifyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RequestVerifyResponseToJson(this);
}

/// Cart item for local state management
class CartItem {
  final String bookId;
  final String title;
  final String? author;
  final String? thumbnailUrl;
  final num price;
  int quantity;

  CartItem({
    required this.bookId,
    required this.title,
    this.author,
    this.thumbnailUrl,
    required this.price,
    this.quantity = 1,
  });

  num get totalPrice => price * quantity;

  Map<String, dynamic> toOrderItem() {
    return {
      'book_id': bookId,
      'quantity': quantity,
    };
  }
}

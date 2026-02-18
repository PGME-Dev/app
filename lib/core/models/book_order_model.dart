import 'package:json_annotation/json_annotation.dart';

part 'book_order_model.g.dart';

@JsonSerializable()
class BookOrderModel {
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
  final List<OrderItemModel>? items;

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

  BookOrderModel({
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

  factory BookOrderModel.fromJson(Map<String, dynamic> json) =>
      _$BookOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookOrderModelToJson(this);

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
class OrderItemModel {
  @JsonKey(name: 'book_id')
  final String bookId;

  final String title;
  final String? author;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  final int quantity;
  final num price;

  OrderItemModel({
    required this.bookId,
    required this.title,
    this.author,
    this.thumbnailUrl,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  /// Get total price for this item
  num get totalPrice => price * quantity;
}

@JsonSerializable()
class BookOrderResponse {
  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'razorpay_order_id')
  final String razorpayOrderId;

  final num amount;
  final String currency;

  @JsonKey(name: 'order_summary')
  final OrderSummary orderSummary;

  BookOrderResponse({
    required this.orderId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.orderSummary,
  });

  factory BookOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$BookOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BookOrderResponseToJson(this);
}

@JsonSerializable()
class OrderSummary {
  final List<OrderSummaryItem> items;
  final num subtotal;

  @JsonKey(name: 'shipping_cost')
  final num shippingCost;

  final num total;

  OrderSummary({
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderSummaryToJson(this);
}

@JsonSerializable()
class OrderSummaryItem {
  @JsonKey(name: 'book_id')
  final String bookId;

  final String title;
  final int quantity;
  final num price;

  OrderSummaryItem({
    required this.bookId,
    required this.title,
    required this.quantity,
    required this.price,
  });

  factory OrderSummaryItem.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderSummaryItemToJson(this);
}

@JsonSerializable()
class PaymentVerifyResponse {
  final bool success;

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'order_number')
  final String orderNumber;

  @JsonKey(name: 'order_status')
  final String orderStatus;

  final String message;

  PaymentVerifyResponse({
    required this.success,
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.message,
  });

  factory PaymentVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentVerifyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentVerifyResponseToJson(this);
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

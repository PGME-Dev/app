// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookOrderModel _$BookOrderModelFromJson(Map<String, dynamic> json) =>
    BookOrderModel(
      orderId: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      itemsCount: (json['items_count'] as num).toInt(),
      totalAmount: (json['total_amount'] as num).toInt(),
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      trackingNumber: json['tracking_number'] as String?,
      courierName: json['courier_name'] as String?,
      createdAt: json['created_at'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recipientName: json['recipient_name'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      subtotal: (json['subtotal'] as num?)?.toInt(),
      shippingCost: (json['shipping_cost'] as num?)?.toInt(),
      shippedAt: json['shipped_at'] as String?,
      deliveredAt: json['delivered_at'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BookOrderModelToJson(BookOrderModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'order_number': instance.orderNumber,
      'items_count': instance.itemsCount,
      'total_amount': instance.totalAmount,
      'payment_status': instance.paymentStatus,
      'order_status': instance.orderStatus,
      'tracking_number': instance.trackingNumber,
      'courier_name': instance.courierName,
      'created_at': instance.createdAt,
      'items': instance.items,
      'recipient_name': instance.recipientName,
      'shipping_phone': instance.shippingPhone,
      'shipping_address': instance.shippingAddress,
      'subtotal': instance.subtotal,
      'shipping_cost': instance.shippingCost,
      'shipped_at': instance.shippedAt,
      'delivered_at': instance.deliveredAt,
      'notes': instance.notes,
    };

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'book_id': instance.bookId,
      'title': instance.title,
      'author': instance.author,
      'thumbnail_url': instance.thumbnailUrl,
      'quantity': instance.quantity,
      'price': instance.price,
    };

BookOrderResponse _$BookOrderResponseFromJson(Map<String, dynamic> json) =>
    BookOrderResponse(
      orderId: json['order_id'] as String,
      razorpayOrderId: json['razorpay_order_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      orderSummary:
          OrderSummary.fromJson(json['order_summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookOrderResponseToJson(BookOrderResponse instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'razorpay_order_id': instance.razorpayOrderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'order_summary': instance.orderSummary,
    };

OrderSummary _$OrderSummaryFromJson(Map<String, dynamic> json) => OrderSummary(
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderSummaryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toInt(),
      shippingCost: (json['shipping_cost'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$OrderSummaryToJson(OrderSummary instance) =>
    <String, dynamic>{
      'items': instance.items,
      'subtotal': instance.subtotal,
      'shipping_cost': instance.shippingCost,
      'total': instance.total,
    };

OrderSummaryItem _$OrderSummaryItemFromJson(Map<String, dynamic> json) =>
    OrderSummaryItem(
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$OrderSummaryItemToJson(OrderSummaryItem instance) =>
    <String, dynamic>{
      'book_id': instance.bookId,
      'title': instance.title,
      'quantity': instance.quantity,
      'price': instance.price,
    };

PaymentVerifyResponse _$PaymentVerifyResponseFromJson(
        Map<String, dynamic> json) =>
    PaymentVerifyResponse(
      success: json['success'] as bool,
      orderId: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      orderStatus: json['order_status'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$PaymentVerifyResponseToJson(
        PaymentVerifyResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'order_id': instance.orderId,
      'order_number': instance.orderNumber,
      'order_status': instance.orderStatus,
      'message': instance.message,
    };

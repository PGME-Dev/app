// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookRequestModel _$BookRequestModelFromJson(Map<String, dynamic> json) =>
    BookRequestModel(
      orderId: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      itemsCount: (json['items_count'] as num).toInt(),
      totalAmount: json['total_amount'] as num,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      trackingNumber: json['tracking_number'] as String?,
      courierName: json['courier_name'] as String?,
      createdAt: json['created_at'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => RequestItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recipientName: json['recipient_name'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      subtotal: json['subtotal'] as num?,
      shippingCost: json['shipping_cost'] as num?,
      shippedAt: json['shipped_at'] as String?,
      deliveredAt: json['delivered_at'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BookRequestModelToJson(BookRequestModel instance) =>
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

RequestItemModel _$RequestItemModelFromJson(Map<String, dynamic> json) =>
    RequestItemModel(
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      price: json['price'] as num,
    );

Map<String, dynamic> _$RequestItemModelToJson(RequestItemModel instance) =>
    <String, dynamic>{
      'book_id': instance.bookId,
      'title': instance.title,
      'author': instance.author,
      'thumbnail_url': instance.thumbnailUrl,
      'quantity': instance.quantity,
      'price': instance.price,
    };

BookRequestResponse _$BookRequestResponseFromJson(Map<String, dynamic> json) =>
    BookRequestResponse(
      orderId: json['order_id'] as String,
      razorpayOrderId: json['razorpay_order_id'] as String,
      amount: json['amount'] as num,
      currency: json['currency'] as String,
      orderSummary: RequestSummary.fromJson(
          json['order_summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookRequestResponseToJson(
        BookRequestResponse instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'razorpay_order_id': instance.razorpayOrderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'order_summary': instance.orderSummary,
    };

RequestSummary _$RequestSummaryFromJson(Map<String, dynamic> json) =>
    RequestSummary(
      items: (json['items'] as List<dynamic>)
          .map((e) => RequestSummaryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: json['subtotal'] as num,
      shippingCost: json['shipping_cost'] as num,
      total: json['total'] as num,
    );

Map<String, dynamic> _$RequestSummaryToJson(RequestSummary instance) =>
    <String, dynamic>{
      'items': instance.items,
      'subtotal': instance.subtotal,
      'shipping_cost': instance.shippingCost,
      'total': instance.total,
    };

RequestSummaryItem _$RequestSummaryItemFromJson(Map<String, dynamic> json) =>
    RequestSummaryItem(
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: json['price'] as num,
    );

Map<String, dynamic> _$RequestSummaryItemToJson(RequestSummaryItem instance) =>
    <String, dynamic>{
      'book_id': instance.bookId,
      'title': instance.title,
      'quantity': instance.quantity,
      'price': instance.price,
    };

RequestVerifyResponse _$RequestVerifyResponseFromJson(
        Map<String, dynamic> json) =>
    RequestVerifyResponse(
      success: json['success'] as bool,
      orderId: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      orderStatus: json['order_status'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RequestVerifyResponseToJson(
        RequestVerifyResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'order_id': instance.orderId,
      'order_number': instance.orderNumber,
      'order_status': instance.orderStatus,
      'message': instance.message,
    };

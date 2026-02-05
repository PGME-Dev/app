/// Zoho Payments Models for PGME
/// These models handle Zoho payment session creation, responses, and verification

class ZohoPaymentSession {
  final String paymentSessionId;
  final int amount;
  final String currency;
  final String referenceNumber;
  final Map<String, dynamic>? metadata; // package/session/order details

  ZohoPaymentSession({
    required this.paymentSessionId,
    required this.amount,
    required this.currency,
    required this.referenceNumber,
    this.metadata,
  });

  factory ZohoPaymentSession.fromJson(Map<String, dynamic> json) {
    return ZohoPaymentSession(
      paymentSessionId: json['payment_session_id'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      referenceNumber: json['reference_number'] as String,
      metadata: json['package'] ?? json['session'] ?? json['order_summary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_session_id': paymentSessionId,
      'amount': amount,
      'currency': currency,
      'reference_number': referenceNumber,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class ZohoPaymentResponse {
  final String status; // 'success', 'failed', 'cancelled'
  final String? paymentId;
  final String? paymentSessionId;
  final String? signature;
  final String? errorMessage;

  ZohoPaymentResponse({
    required this.status,
    this.paymentId,
    this.paymentSessionId,
    this.signature,
    this.errorMessage,
  });

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  factory ZohoPaymentResponse.fromJson(Map<String, dynamic> json) {
    return ZohoPaymentResponse(
      status: json['status'] as String,
      paymentId: json['payment_id'] as String?,
      paymentSessionId: json['payment_session_id'] as String?,
      signature: json['signature'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (paymentId != null) 'payment_id': paymentId,
      if (paymentSessionId != null) 'payment_session_id': paymentSessionId,
      if (signature != null) 'signature': signature,
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }
}

class ZohoVerificationResponse {
  final bool success;
  final String purchaseId;
  final String? expiresAt;
  final String message;

  ZohoVerificationResponse({
    required this.success,
    required this.purchaseId,
    this.expiresAt,
    required this.message,
  });

  factory ZohoVerificationResponse.fromJson(Map<String, dynamic> json) {
    return ZohoVerificationResponse(
      success: json['success'] as bool,
      purchaseId: json['purchase_id'] as String,
      expiresAt: json['expires_at'] as String?,
      message: json['message'] ?? 'Payment verification successful',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'purchase_id': purchaseId,
      if (expiresAt != null) 'expires_at': expiresAt,
      'message': message,
    };
  }
}

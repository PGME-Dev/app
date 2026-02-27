/// Gateway Payment Models for PGME
/// These models handle Gateway payment session creation, responses, and verification

class GatewaySession {
  final String paymentSessionId;
  final num amount;
  final String currency;
  final String referenceNumber;
  final Map<String, dynamic>? metadata; // package/session/order details
  final bool isExisting; // Flag indicating if this is an existing pending payment
  final String? createdAt; // When the payment session was created

  GatewaySession({
    required this.paymentSessionId,
    required this.amount,
    required this.currency,
    required this.referenceNumber,
    this.metadata,
    this.isExisting = false,
    this.createdAt,
  });

  factory GatewaySession.fromJson(Map<String, dynamic> json) {
    return GatewaySession(
      paymentSessionId: json['payment_session_id'] as String,
      amount: json['amount'] as num,
      currency: json['currency'] as String,
      referenceNumber: json['reference_number'] as String,
      metadata: json['package'] ?? json['session'] ?? json['order_summary'],
      isExisting: json['is_existing'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_session_id': paymentSessionId,
      'amount': amount,
      'currency': currency,
      'reference_number': referenceNumber,
      if (metadata != null) 'metadata': metadata,
      'is_existing': isExisting,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}

class GatewayResponse {
  final String status; // 'success', 'failed', 'cancelled'
  final String? paymentId;
  final String? paymentSessionId;
  final String? signature;
  final String? errorMessage;

  GatewayResponse({
    required this.status,
    this.paymentId,
    this.paymentSessionId,
    this.signature,
    this.errorMessage,
  });

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  factory GatewayResponse.fromJson(Map<String, dynamic> json) {
    return GatewayResponse(
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

class GatewayVerificationResponse {
  final bool success;
  final String purchaseId;
  final String? expiresAt;
  final String message;

  GatewayVerificationResponse({
    required this.success,
    required this.purchaseId,
    this.expiresAt,
    required this.message,
  });

  factory GatewayVerificationResponse.fromJson(Map<String, dynamic> json) {
    return GatewayVerificationResponse(
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

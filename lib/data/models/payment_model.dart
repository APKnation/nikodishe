enum PaymentMethod { mpesa, airtelMoney, tigoPesa, haloPesa }

enum PaymentType { deposit, full, remainder }

enum PaymentStatus { pending, completed, failed }

class PaymentModel {
  final String id;
  final String bookingId;
  final String listingTitle;
  final String renterId;
  final String renterName;
  final String ownerId;
  final double amount;
  final PaymentMethod method;
  final PaymentType type;
  final PaymentStatus status;
  final String transactionRef;
  final String phoneNumber;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    this.listingTitle = '',
    this.renterId = '',
    this.renterName = '',
    this.ownerId = '',
    required this.amount,
    required this.method,
    required this.type,
    required this.status,
    required this.transactionRef,
    required this.phoneNumber,
    required this.createdAt,
  });

  // Keep old names as shims for backward compat
  PaymentMethod get paymentMethod => method;
  PaymentType get paymentType => type;
  String get referenceCode => transactionRef;

  String get methodLabel {
    switch (method) {
      case PaymentMethod.mpesa:
        return 'M-Pesa (Vodacom)';
      case PaymentMethod.airtelMoney:
        return 'Airtel Money';
      case PaymentMethod.tigoPesa:
        return 'Tigo Pesa / Mixx';
      case PaymentMethod.haloPesa:
        return 'HaloPesa';
    }
  }

  String get statusLabel {
    switch (status) {
      case PaymentStatus.pending:
        return 'Inashughulikiwa';
      case PaymentStatus.completed:
        return 'Imekamilika';
      case PaymentStatus.failed:
        return 'Imefeli';
    }
  }

  String get typeLabel {
    switch (type) {
      case PaymentType.deposit:
        return 'Amana (Deposit 40%)';
      case PaymentType.full:
        return 'Malipo Kamili (Full)';
      case PaymentType.remainder:
        return 'Kumalizia Salio (60%)';
    }
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? listingTitle,
    String? renterId,
    String? renterName,
    String? ownerId,
    double? amount,
    PaymentMethod? method,
    PaymentType? type,
    PaymentStatus? status,
    String? transactionRef,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      listingTitle: listingTitle ?? this.listingTitle,
      renterId: renterId ?? this.renterId,
      renterName: renterName ?? this.renterName,
      ownerId: ownerId ?? this.ownerId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      type: type ?? this.type,
      status: status ?? this.status,
      transactionRef: transactionRef ?? this.transactionRef,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum PaymentMethod { mpesa, airtelMoney, tigoPesa }

enum PaymentType { deposit, full }

enum PaymentStatus { pending, completed, failed }

class PaymentModel {
  final String id;
  final String bookingId;
  final String listingTitle;
  final String renterId;
  final String renterName;
  final String ownerId;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentType paymentType;
  final PaymentStatus status;
  final String referenceCode;
  final String phoneNumber;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.listingTitle,
    required this.renterId,
    required this.renterName,
    required this.ownerId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentType,
    required this.status,
    required this.referenceCode,
    required this.phoneNumber,
    required this.createdAt,
  });

  String get methodLabel {
    switch (paymentMethod) {
      case PaymentMethod.mpesa:
        return 'M-Pesa (Vodacom)';
      case PaymentMethod.airtelMoney:
        return 'Airtel Money';
      case PaymentMethod.tigoPesa:
        return 'Tigo Pesa / Mixx';
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
    switch (paymentType) {
      case PaymentType.deposit:
        return 'Amana (Deposit)';
      case PaymentType.full:
        return 'Malipo Kamili (Full)';
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
    PaymentMethod? paymentMethod,
    PaymentType? paymentType,
    PaymentStatus? status,
    String? referenceCode,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      referenceCode: referenceCode ?? this.referenceCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


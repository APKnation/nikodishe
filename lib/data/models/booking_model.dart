import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingModel {
  final String id;
  final String listingId;
  final String listingTitle;
  final String listingImage;
  final String renterId;
  final String renterName;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.listingId,
    this.listingTitle = '',
    this.listingImage = '',
    this.renterId = '',
    this.renterName = '',
    required this.ownerId,
    this.ownerName = '',
    this.ownerPhone = '',
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  int get totalDays {
    return endDate.difference(startDate).inDays.clamp(1, double.maxFinite.toInt());
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Inasubiri';
      case BookingStatus.confirmed:
        return 'Imethibitishwa';
      case BookingStatus.completed:
        return 'Imekamilika';
      case BookingStatus.cancelled:
        return 'Imefutwa';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFFA000); // amber
      case BookingStatus.confirmed:
        return const Color(0xFF1976D2); // blue
      case BookingStatus.completed:
        return const Color(0xFF388E3C); // green
      case BookingStatus.cancelled:
        return const Color(0xFFD32F2F); // red
    }
  }

  BookingModel copyWith({
    String? id,
    String? listingId,
    String? listingTitle,
    String? listingImage,
    String? renterId,
    String? renterName,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingImage: listingImage ?? this.listingImage,
      renterId: renterId ?? this.renterId,
      renterName: renterName ?? this.renterName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImage': listingImage,
      'renterId': renterId,
      'renterName': renterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      listingId: map['listingId'] as String,
      listingTitle: (map['listingTitle'] as String?) ?? '',
      listingImage: (map['listingImage'] as String?) ?? '',
      renterId: (map['renterId'] as String?) ?? '',
      renterName: (map['renterName'] as String?) ?? '',
      ownerId: (map['ownerId'] as String?) ?? '',
      ownerName: (map['ownerName'] as String?) ?? '',
      ownerPhone: (map['ownerPhone'] as String?) ?? '',
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'BookingModel(id: $id, listing: $listingTitle, status: $statusLabel)';
}

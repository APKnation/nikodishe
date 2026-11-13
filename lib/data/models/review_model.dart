class ReviewModel {
  final String id;
  final String bookingId;
  final String listingId;
  final String renterId;
  final String renterName;
  final String ownerId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.listingId,
    required this.renterId,
    required this.renterName,
    required this.ownerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  ReviewModel copyWith({
    String? id,
    String? bookingId,
    String? listingId,
    String? renterId,
    String? renterName,
    String? ownerId,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      listingId: listingId ?? this.listingId,
      renterId: renterId ?? this.renterId,
      renterName: renterName ?? this.renterName,
      ownerId: ownerId ?? this.ownerId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


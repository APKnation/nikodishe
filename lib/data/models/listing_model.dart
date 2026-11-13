enum ListingCategory { sherehe, ujenzi, ukumbi }

enum ListingType { kukodisha, kuuza, zote }

class ListingModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String title;
  final String description;
  final ListingCategory category;
  final ListingType type;
  final double pricePerDay;
  final List<String> images;
  final String location;
  final double? latitude;
  final double? longitude;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  const ListingModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.pricePerDay,
    required this.images,
    required this.location,
    this.latitude,
    this.longitude,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
  });

  String get categoryLabel {
    switch (category) {
      case ListingCategory.sherehe:
        return 'Sherehe';
      case ListingCategory.ujenzi:
        return 'Ujenzi';
      case ListingCategory.ukumbi:
        return 'Ukumbi';
    }
  }

  String get typeLabel {
    switch (type) {
      case ListingType.kukodisha:
        return 'Kukodisha';
      case ListingType.kuuza:
        return 'Kuuza';
      case ListingType.zote:
        return 'Kukodisha & Kuuza';
    }
  }

  ListingModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? title,
    String? description,
    ListingCategory? category,
    ListingType? type,
    double? pricePerDay,
    List<String>? images,
    String? location,
    double? latitude,
    double? longitude,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      images: images ?? this.images,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'title': title,
      'description': description,
      'category': category.name,
      'type': type.name,
      'pricePerDay': pricePerDay,
      'images': images,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      ownerName: map['ownerName'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: ListingCategory.values
          .firstWhere((e) => e.name == map['category']),
      type: ListingType.values.firstWhere((e) => e.name == map['type']),
      pricePerDay: (map['pricePerDay'] as num).toDouble(),
      images: List<String>.from(map['images'] as List),
      location: map['location'] as String,
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
      isAvailable: map['isAvailable'] as bool,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'ListingModel(id: $id, title: $title, category: $categoryLabel)';
}

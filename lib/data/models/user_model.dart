enum UserRole { renter, owner }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? location;
  final String? photoUrl;
  final String? whatsapp;
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.location,
    this.photoUrl,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.tiktok,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    UserRole? role,
    String? location,
    String? photoUrl,
    String? whatsapp,
    String? instagram,
    String? facebook,
    String? tiktok,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      whatsapp: whatsapp ?? this.whatsapp,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      tiktok: tiktok ?? this.tiktok,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role.name,
      'location': location,
      'photoUrl': photoUrl,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      location: map['location'] as String?,
      photoUrl: map['photoUrl'] as String?,
      whatsapp: map['whatsapp'] as String?,
      instagram: map['instagram'] as String?,
      facebook: map['facebook'] as String?,
      tiktok: map['tiktok'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, phone: $phone, role: $role)';
}

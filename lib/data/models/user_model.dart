enum UserRole { renter, owner }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? location;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.location,
    this.photoUrl,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    UserRole? role,
    String? location,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
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
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, phone: $phone, role: $role)';
}

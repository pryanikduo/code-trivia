class User {
  String id;
  String? username;
  String email;
  String hashedPassword;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    this.username,
    required this.email,
    required this.hashedPassword,
    required this.createdAt,
    required this.updatedAt
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String, 
      username: json['username'] as String?,
      email: json['email'] as String, 
      hashedPassword: json['hashedPassword'] as String, 
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'hashedPassword': hashedPassword,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String()
  };

  User copyWith({
    String? id,
    String? email,
    String? hashedPassword,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }  
}
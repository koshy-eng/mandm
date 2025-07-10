class Driver {
  final int id;
  final String name;
  final String username;
  final String type;
  final int coins;
  final String title;
  final String email;
  final String? emailVerifiedAt;
  String phone;
  final int isAdmin;
  final String createdAt;
  final String updatedAt;

  Driver({
    required this.id,
    required this.name,
    required this.username,
    required this.type,
    required this.coins,
    required this.title,
    required this.email,
    this.emailVerifiedAt,
    required this.phone,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      type: json['type'],
      coins: json['coins'],
      title: json['title'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      phone: json['phone'],
      isAdmin: json['is_admin'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'type': type,
      'coins': coins,
      'title': title,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'phone': phone,
      'is_admin': isAdmin,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

}

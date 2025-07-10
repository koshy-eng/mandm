class LoginResponse {
  final String status;
  final User user;
  final Authorisation authorisation;

  LoginResponse({
    required this.status,
    required this.user,
    required this.authorisation,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? '',
      user: User.fromJson(json['user']),
      authorisation: Authorisation.fromJson(json['authorisation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'user': user.toJson(),
      'authorisation': authorisation.toJson(),
    };
  }
}

class User {
  final int id;
  final String name;
  final String username;
  final String type;
  final String title;
  final String email;
  final String? emailVerifiedAt;
  final String phone;
  final int isAdmin;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.type,
    required this.title,
    required this.email,
    this.emailVerifiedAt,
    required this.phone,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      phone: json['phone'] ?? '',
      isAdmin: json['is_admin'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'type': type,
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

class Authorisation {
  final String token;
  final String type;

  Authorisation({
    required this.token,
    required this.type,
  });

  factory Authorisation.fromJson(Map<String, dynamic> json) {
    return Authorisation(
      token: json['token'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
    };
  }
}

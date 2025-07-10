
class RegisterModel {
  final User user;
  final String token;

  RegisterModel({
    required this.user,
    required this.token,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    user: User.fromJson(json["user"]),
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "token": token,
  };
}
class Register{
  final String token;
  final User user;
  Register({
    required this.token,
    required this.user,
});

  factory Register.fromJson(Map<String, dynamic> json) => Register(
    token: json["token"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "user": user.toJson(),
  };
}

class UserModel {
  final int statusCode;
  final User message;

  UserModel({
    required this.statusCode,
    required this.message,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    statusCode: json["status_code"],
    message: User.fromJson(json["message"]),
  );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message.toJson(),
  };
}
class User {
  final int id;
  final String name;
  final String username;
  final String email;
  // final String? type = '1';
  String? phone = '';
  final String created_at;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    // required this.type,
    required this.phone,
    required this.created_at,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    username: json["username"],
    email: json["email"],
    // type: json["type"],
    phone: json["phone"],
    created_at: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "username": username,
    "email": email,
    // "type": type,
    "phone": phone,
    "created_at": created_at,
  };
}

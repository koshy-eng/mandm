 class BrandModel {
  final int id;
  final String image;
  final String name;
  final String description;
  final String createdAt;

  BrandModel({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel  (
    id: json["id"],
    image: json["image"],
    name: json["name"],
    description: json["description"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "name": name,
    "description": description,
    "createdAt": createdAt,
  };
}

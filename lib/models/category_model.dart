 class CategoryModel {
  final int id;
  final String name;
  final String description;
  final String createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "createdAt": createdAt,
  };
}

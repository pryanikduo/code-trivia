class Category {
  final String id;
  final String name;
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',           // Защита от null и int
      name: json['name']?.toString() ?? 'Без названия',
      image: json['image']?.toString(),
    );
  }
}
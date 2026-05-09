class Category {
  String name;
  String slug;

  Category({required this.name, required this.slug});

  factory Category.fromJson(Map<String, dynamic> json){
    return Category(
      name: json['name'] as String, 
      slug: json['slug'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug
  };
}
class Category {
  String id;
  String name;
  String slug;

  Category({required this.id,required this.name, required this.slug});

  factory Category.fromJson(Map<String, dynamic> json){
    return Category(
      id: json['id'] as String,
      name: json['name'] as String, 
      slug: json['slug'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug
  };
}
class FoodItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String image;
  final bool isVeg;
  final double rating;
  final bool isPromo;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.image,
    required this.isVeg,
    required this.rating,
    this.isPromo = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'image': image,
      'is_veg': isVeg ? 1 : 0,
      'rating': rating,
      'is_promo': isPromo ? 1 : 0,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      categoryId: map['category_id'],
      image: map['image'],
      isVeg: map['is_veg'] == 1,
      rating: map['rating'].toDouble(),
      isPromo: map['is_promo'] == 1,
    );
  }
}

enum ProductCategory {
  electronics,
  clothing,
  furniture,
  books,
  sports,
  toys,
  home,
  other,
}

enum ProductCondition {
  new_,
  likeNew,
  good,
  fair,
}

enum ProductStatus {
  available,
  sold,
  pending,
}

class ProductModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double price;
  final ProductCategory category;
  final ProductCondition condition;
  final ProductStatus status;
  final List<String> imageUrls;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int views;
  final List<String> likes;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.status,
    required this.imageUrls,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.updatedAt,
    this.views = 0,
    this.likes = const [],
    this.isFeatured = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: ProductCategory.values.byName(json['category'] as String),
      condition: ProductCondition.values.byName(json['condition'] as String),
      status: ProductStatus.values.byName(json['status'] as String),
      imageUrls: List<String>.from(json['imageUrls'] as List),
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      views: (json['views'] as num?)?.toInt() ?? 0,
      likes: List<String>.from(json['likes'] as List? ?? []),
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'category': category.name,
      'condition': condition.name,
      'status': status.name,
      'imageUrls': imageUrls,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'views': views,
      'likes': likes,
      'isFeatured': isFeatured,
    };
  }

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    double? price,
    ProductCategory? category,
    ProductCondition? condition,
    ProductStatus? status,
    List<String>? imageUrls,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? views,
    List<String>? likes,
    bool? isFeatured,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

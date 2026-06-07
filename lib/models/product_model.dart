enum ProductCategory {
  electronics,
  clothing,
  furniture,
  books,
  sports,
  toys,
  home,
  fashion,
  other,
}

enum ProductCondition { new_, likeNew, good, fair }

enum ProductStatus { available, sold, pending }

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

  // Convenience getters for compatibility
  List<String> get images => imageUrls;

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
    try {
      return ProductModel(
        id: json['id']?.toString() ?? '',
        sellerId: json['sellerId']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled',
        description: json['description']?.toString() ?? '',
        price: _parseDouble(json['price']),
        category: _parseCategory(json['category']),
        condition: _parseCondition(json['condition']),
        status: _parseStatus(json['status']),
        imageUrls: _parseStringList(json['imageUrls'] ?? json['images']),
        location: json['location']?.toString() ?? 'Unknown',
        latitude: _parseDouble(json['latitude']),
        longitude: _parseDouble(json['longitude']),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? _parseDateTime(json['updatedAt'])
            : null,
        views: _parseInt(json['views']),
        likes: _parseStringList(json['likes']),
        isFeatured: _parseBool(json['isFeatured']),
      );
    } catch (e) {
      print('Error parsing product: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static ProductCategory _parseCategory(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) return ProductCategory.other;

    for (final category in ProductCategory.values) {
      if (category.name.toLowerCase() == normalized.toLowerCase()) {
        return category;
      }
    }

    return ProductCategory.other;
  }

  static ProductCondition _parseCondition(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) return ProductCondition.good;

    if (normalized.toLowerCase() == 'new') return ProductCondition.new_;

    for (final condition in ProductCondition.values) {
      if (condition.name.toLowerCase() == normalized.toLowerCase()) {
        return condition;
      }
    }

    return ProductCondition.good;
  }

  static ProductStatus _parseStatus(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return ProductStatus.available;
    }

    for (final status in ProductStatus.values) {
      if (status.name.toLowerCase() == normalized.toLowerCase()) {
        return status;
      }
    }

    return ProductStatus.available;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value?.toString().toLowerCase() == 'true';
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    // Handle Firestore Timestamp JSON shape
    if (value is Map && value.containsKey('_seconds')) {
      final seconds = value['_seconds'];
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
      }
    }
    // Handle Firestore Timestamp object
    try {
      final date = (value as dynamic).toDate();
      if (date is DateTime) return date;
    } catch (e) {
      // Fall back below.
    }
    return DateTime.now();
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

// Type alias for convenience
typedef Product = ProductModel;

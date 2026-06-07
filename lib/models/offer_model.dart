enum OfferStatus { pending, accepted, declined, expired }

enum OfferType { buyerOffer, sellerDiscount }

class OfferModel {
  final String id;
  final String productId;
  final String productTitle;
  final String buyerId;
  final String sellerId;
  final double offerPrice;
  final double originalPrice;
  final String? message;
  final OfferStatus status;
  final OfferType type;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OfferModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.buyerId,
    required this.sellerId,
    required this.offerPrice,
    required this.originalPrice,
    this.message,
    this.status = OfferStatus.pending,
    this.type = OfferType.buyerOffer,
    required this.createdAt,
    this.updatedAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productTitle: json['productTitle'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String?,
      status: _parseStatus(json['status']),
      type: _parseType(json['type']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] == null ? null : _parseDate(json['updatedAt']),
    );
  }

  static OfferStatus _parseStatus(dynamic value) {
    try {
      if (value is String) return OfferStatus.values.byName(value);
    } catch (_) {}
    return OfferStatus.pending;
  }

  static OfferType _parseType(dynamic value) {
    try {
      if (value is String) return OfferType.values.byName(value);
    } catch (_) {}
    return OfferType.buyerOffer;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productTitle': productTitle,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'offerPrice': offerPrice,
        'originalPrice': originalPrice,
        'message': message,
        'status': status.name,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  OfferModel copyWith({
    String? id,
    OfferStatus? status,
    DateTime? updatedAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      productId: productId,
      productTitle: productTitle,
      buyerId: buyerId,
      sellerId: sellerId,
      offerPrice: offerPrice,
      originalPrice: originalPrice,
      message: message,
      status: status ?? this.status,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

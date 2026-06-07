class ReviewModel {
  final String id;
  final String transactionId;
  final String productId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      reviewerId: json['reviewerId'] as String? ?? '',
      revieweeId: json['revieweeId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
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
        'transactionId': transactionId,
        'productId': productId,
        'reviewerId': reviewerId,
        'revieweeId': revieweeId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };
}

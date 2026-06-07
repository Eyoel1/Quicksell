enum TransactionStatus { pendingBuyerConfirmation, completed, cancelled }

class TransactionModel {
  final String id;
  final String productId;
  final String productTitle;
  final String buyerId;
  final String sellerId;
  final double finalPrice;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.buyerId,
    required this.sellerId,
    required this.finalPrice,
    this.status = TransactionStatus.pendingBuyerConfirmation,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productTitle: json['productTitle'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status']),
      createdAt: _parseDate(json['createdAt']),
      completedAt: json['completedAt'] == null ? null : _parseDate(json['completedAt']),
    );
  }

  static TransactionStatus _parseStatus(dynamic value) {
    try {
      if (value is String) return TransactionStatus.values.byName(value);
    } catch (_) {}
    return TransactionStatus.pendingBuyerConfirmation;
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
        'finalPrice': finalPrice,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };
}

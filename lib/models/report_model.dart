enum ReportReason { scam, prohibitedItem, offensive, duplicate, other }

class ReportModel {
  final String id;
  final String productId;
  final String reporterId;
  final ReportReason reason;
  final String details;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.productId,
    required this.reporterId,
    required this.reason,
    required this.details,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      reporterId: json['reporterId'] as String? ?? '',
      reason: _parseReason(json['reason']),
      details: json['details'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static ReportReason _parseReason(dynamic value) {
    try {
      if (value is String) return ReportReason.values.byName(value);
    } catch (_) {}
    return ReportReason.other;
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
        'reporterId': reporterId,
        'reason': reason.name,
        'details': details,
        'createdAt': createdAt.toIso8601String(),
      };
}

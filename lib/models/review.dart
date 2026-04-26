class Review {
  const Review({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.workerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String clientId;
  final String workerId;
  final int rating; // 1–5
  final String comment;
  final DateTime createdAt;

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String? ?? '',
      orderId: map['orderId'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      workerId: map['workerId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      comment: map['comment'] as String? ?? '',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'clientId': clientId,
      'workerId': workerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

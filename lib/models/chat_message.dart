class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.isFromClient,
  });

  final String id;
  final String orderId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isFromClient;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      orderId: map['orderId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      sentAt: _parseDateTime(map['sentAt']),
      isFromClient: map['isFromClient'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
      'isFromClient': isFromClient,
    };
  }

  static DateTime _parseDateTime(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return DateTime.now().toUtc();
  }
}

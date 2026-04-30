import '../app_config.dart';
import '../models/wash_models.dart';
import '../repositories/chat_repository.dart';
import '../repositories/firestore_chat_repository.dart';
import '../repositories/mock_chat_repository.dart';

class ChatService {
  ChatService._internal() : _repository = _buildRepository();

  static final ChatService _instance = ChatService._internal();

  factory ChatService() => _instance;

  final ChatRepository _repository;

  static ChatRepository _buildRepository() {
    switch (AppConfig.backendMode) {
      case BackendMode.firestore:
        return FirestoreChatRepository();
      case BackendMode.mock:
        return MockChatRepository();
    }
  }

  Stream<List<ChatMessage>> watchMessages(String orderId) {
    return _repository.watchMessages(orderId);
  }

  Future<void> sendMessage({
    required String orderId,
    required String text,
    required UserProfile sender,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final message = ChatMessage(
      id: '',
      orderId: orderId,
      senderId: sender.uid,
      senderName: sender.name,
      text: trimmed,
      sentAt: DateTime.now().toUtc(),
      isFromClient: sender.role == AppRole.client,
    );
    await _repository.sendMessage(message);
  }

  bool canChat(WashOrder order, UserProfile profile) {
    const chatableStatuses = {
      OrderStatus.assigned,
      OrderStatus.onTheWay,
      OrderStatus.arrived,
      OrderStatus.inProgress,
    };
    if (!chatableStatuses.contains(order.status)) return false;
    if (order.workerId == null) return false;

    if (profile.role == AppRole.client) {
      return order.clientId == profile.uid ||
          order.customerEmail.trim().toLowerCase() ==
              profile.email.trim().toLowerCase();
    }
    return order.workerId == profile.uid ||
        order.assignedWorkerEmail?.trim().toLowerCase() ==
            profile.email.trim().toLowerCase();
  }
}

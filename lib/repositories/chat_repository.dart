import '../models/wash_models.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchMessages(String orderId);
  Future<void> sendMessage(ChatMessage message);
}

import 'dart:async';

import '../models/wash_models.dart';
import 'chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final _messages = <String, List<ChatMessage>>{};
  final _controllers = <String, StreamController<List<ChatMessage>>>{};

  StreamController<List<ChatMessage>> _controllerFor(String orderId) {
    return _controllers.putIfAbsent(
      orderId,
      () => StreamController<List<ChatMessage>>.broadcast(),
    );
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String orderId) async* {
    yield List.unmodifiable(_messages[orderId] ?? []);
    yield* _controllerFor(orderId).stream;
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    final list = _messages.putIfAbsent(message.orderId, () => []);
    list.add(message);
    _controllerFor(message.orderId).add(List.unmodifiable(list));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wash_models.dart';
import 'chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messages(String orderId) =>
      _firestore.collection('conversations').doc(orderId).collection('messages');

  @override
  Stream<List<ChatMessage>> watchMessages(String orderId) {
    return _messages(orderId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
            .toList(growable: false));
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    await _messages(message.orderId).add(message.toMap());
  }
}

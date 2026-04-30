import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/chat_service.dart';
import '../services/profile_service.dart';
import '../theme/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.order});

  final WashOrder order;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _profileService = ProfileService();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    _inputCtrl.clear();
    setState(() => _sending = true);
    try {
      await _chatService.sendMessage(
        orderId: widget.order.id,
        text: text,
        sender: _profileService.profile.value,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo enviar el mensaje.')),
        );
        _inputCtrl.text = text;
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _otherName() {
    final profile = _profileService.profile.value;
    if (profile.role == AppRole.client) {
      return widget.order.assignedWasherName;
    }
    return widget.order.customerEmail.split('@').first;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileService.profile.value;

    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: Column(
            children: [
              _ChatAppBar(otherName: _otherName()),
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _chatService.watchMessages(widget.order.id),
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'Inicia la conversación',
                          style: TextStyle(
                            color: LavifyTheme.textSecondaryColor(context),
                          ),
                        ),
                      );
                    }
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                    );
                    return ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == profile.uid ||
                            (msg.senderId.isEmpty &&
                                msg.isFromClient ==
                                    (profile.role == AppRole.client));
                        return _MessageBubble(message: msg, isMe: isMe);
                      },
                    );
                  },
                ),
              ),
              _InputBar(
                controller: _inputCtrl,
                sending: _sending,
                onSend: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({required this.otherName});

  final String otherName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LavifyTheme.borderColor(context)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LavifyColors.primary.withAlpha(28),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: LavifyColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Chat del servicio',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  String get _time {
    final local = message.sentAt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);

    final bubbleColor = isMe
        ? (isLight ? LavifyColors.lightNavy : LavifyColors.primaryStrong)
        : LavifyTheme.surfaceAltColor(context);

    final textColor = isMe
        ? Colors.white
        : LavifyTheme.textPrimaryColor(context);

    final timeColor = isMe
        ? Colors.white60
        : LavifyTheme.textSecondaryColor(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: isMe
              ? null
              : Border.all(color: LavifyTheme.borderColor(context)),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: timeColor,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: LavifyTheme.borderColor(context)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: LavifyTheme.borderColor(context),
                  ),
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 10),
          AnimatedOpacity(
            opacity: sending ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Material(
              color: LavifyColors.primary,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: sending ? null : onSend,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

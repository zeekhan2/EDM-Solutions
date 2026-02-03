import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:edm_solutions/controllers/chat_controller.dart';
import 'package:edm_solutions/controllers/auth_controller.dart';

class ChatDetailView extends StatefulWidget {
  final String contactName;
  final String chatId;
  final int workerId;
  final int facilityId;
  final String workerName;
  final String facilityName;
  final String otherUserFirebaseUid;

  const ChatDetailView({
    super.key,
    required this.contactName,
    required this.chatId,
    required this.workerId,
    required this.facilityId,
    required this.workerName,
    required this.facilityName,
    required this.otherUserFirebaseUid,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final ChatController chat = Get.find<ChatController>();
  final AuthController auth = Get.find<AuthController>();

  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  String? myUid;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    myUid = auth.currentUser.value?.firebaseUid;

    if (myUid != null) {
      await chat.setOnline(
        chatId: widget.chatId,
        role: 'worker',
        online: true,
      );

      await chat.markRead(
        chatId: widget.chatId,
        role: 'worker',
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    if (myUid != null) {
      chat.setOnline(
        chatId: widget.chatId,
        role: 'worker',
        online: false,
      );
    }
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scroll.hasClients) return;

    final position = _scroll.position.maxScrollExtent;

    if (animated) {
      _scroll.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scroll.jumpTo(position);
    }
  }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty || myUid == null) return;

    final text = _ctrl.text.trim();
    _ctrl.clear();

    await chat.sendMessage(
      chatId: widget.chatId,
      senderUid: myUid!,
      receiverUid: widget.otherUserFirebaseUid,
      message: text,
      senderRole: 'worker',
      workerId: widget.workerId,
      facilityId: widget.facilityId,
      workerName: widget.workerName,
      facilityName: widget.facilityName,
    );

    // 🔥 ADD THIS BLOCK (DO NOT REMOVE ANYTHING ELSE)
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
      'facilityUnread': FieldValue.increment(1),
      'workerUnread': 0,
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (_scroll.hasClients) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (myUid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: chat.chatMeta(widget.chatId),
          builder: (_, snap) {
            final meta = snap.data?.data();

            /// ✅ FIXED FIELD NAMES
            final bool online = meta?['facilityOnline'] == true;
            final String? imageUrl = meta?['facilityImage'];

            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1E3A8A),
                  backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                      ? NetworkImage(imageUrl)
                      : null,
                  child: (imageUrl == null || imageUrl.isEmpty)
                      ? Text(
                          widget.contactName.isNotEmpty
                              ? widget.contactName[0].toUpperCase()
                              : 'F',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contactName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      online ? 'Online' : 'Offline',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),

      /// ================= BODY =================
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chat.messages(widget.chatId),
              builder: (_, snapshot) {
                final msgs = snapshot.data?.docs ?? [];

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_scroll.hasClients) return;

                  final max = _scroll.position.maxScrollExtent;
                  final current = _scroll.position.pixels;

                  if ((max - current) < 120) {
                    _scrollToBottom();
                  }
                });

                if (msgs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start the conversation 👋',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i].data();
                    final isMe = m['senderUid'] == myUid;

                    final time = m['createdAt'] != null
                        ? DateFormat('hh:mm a')
                            .format((m['createdAt'] as Timestamp).toDate())
                        : '';

                    return Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF2BB6C1)
                                : const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isMe ? 18 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 18),
                            ),
                          ),
                          child: Text(
                            m['message'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: IconButton(
                      icon:
                          const Icon(Icons.send, size: 18, color: Colors.white),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

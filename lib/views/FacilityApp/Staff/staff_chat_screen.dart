import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:edm_solutions/controllers/chat_controller.dart';
import 'package:edm_solutions/controllers/auth_controller.dart';

class StaffChatScreen extends StatefulWidget {
  final String contactName;
  final String chatId;
  final String otherUserFirebaseUid;
  final int workerId;
  final int facilityId;
  final String workerName;
  final String facilityName;

  const StaffChatScreen({
    super.key,
    required this.contactName,
    required this.chatId,
    required this.otherUserFirebaseUid,
    required this.workerId,
    required this.facilityId,
    required this.workerName,
    required this.facilityName,
  });

  @override
  State<StaffChatScreen> createState() => _StaffChatScreenState();
}

class _StaffChatScreenState extends State<StaffChatScreen> {
  final ChatController chat = Get.find();
  final AuthController auth = Get.find();

  final TextEditingController textCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  late final String myUid;

  @override
  void initState() {
    super.initState();

    myUid = auth.currentUser.value!.firebaseUid!;

    chat.setOnline(
      chatId: widget.chatId,
      role: 'facility',
      online: true,
    );

    chat.markRead(chatId: widget.chatId, role: 'facility');

    /// ✅ scroll after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    chat.setOnline(
      chatId: widget.chatId,
      role: 'facility',
      online: false,
    );
    scrollCtrl.dispose();
    textCtrl.dispose();
    super.dispose();
  }

  /// ================= IMAGE URL FIX =================
  String? _resolveImageUrl(String? image) {
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http')) return image;
    return 'https://admin.edmsolutions.org/storage/$image';
  }

  void _scrollToBottom({bool animated = true}) {
    if (!scrollCtrl.hasClients) return;

    final pos = scrollCtrl.position.maxScrollExtent;

    if (animated) {
      scrollCtrl.animateTo(
        pos,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      scrollCtrl.jumpTo(pos);
    }
  }

  Future<void> _send() async {
    if (textCtrl.text.trim().isEmpty) return;

    final msg = textCtrl.text.trim();
    textCtrl.clear();

    await chat.sendMessage(
      chatId: widget.chatId,
      senderUid: myUid,
      receiverUid: widget.otherUserFirebaseUid,
      message: msg,
      senderRole: 'facility',
      workerId: widget.workerId,
      facilityId: widget.facilityId,
      workerName: widget.workerName,
      facilityName: widget.facilityName,
    );

    // 🔥 ADD THIS BLOCK
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
      'workerUnread': FieldValue.increment(1),
      'facilityUnread': 0,
      'lastMessage': msg,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: chat.chatMeta(widget.chatId),
          builder: (_, snap) {
            final data = snap.data?.data();

            final bool isOnline = data?['workerOnline'] == true;

            final String? rawImage = data?['workerImage'];
            final String? workerImage = _resolveImageUrl(rawImage);

            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1E3A8A),
                  backgroundImage:
                      workerImage != null ? NetworkImage(workerImage) : null,
                  child: workerImage == null
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),

                /// ✅ THIS IS THE FIX
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.contactName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
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
                  if (!scrollCtrl.hasClients) return;

                  final max = scrollCtrl.position.maxScrollExtent;
                  final current = scrollCtrl.position.pixels;

                  // Auto-scroll ONLY if user is already near bottom
                  if ((max - current) < 120) {
                    scrollCtrl.animateTo(
                      max,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
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
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i].data();
                    final bool isMe = m['senderUid'] == myUid;

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
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            time,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          /// ================= INPUT =================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
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
                        controller: textCtrl,
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
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
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

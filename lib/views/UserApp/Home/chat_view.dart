import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/controllers/chat_controller.dart';
import 'package:edm_solutions/controllers/auth_controller.dart';

import 'chat_detail_view.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatController _chat = Get.find<ChatController>();
  final AuthController _auth = Get.find<AuthController>();

  String? myUid;
  int? workerId;
  String workerName = '';

  bool loading = true;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = _auth.currentUser.value;

    if (user == null || user.firebaseUid == null || user.id == null) {
      setState(() => loading = false);
      return;
    }

    myUid = user.firebaseUid;
    workerId = user.id;
    workerName = user.fullName ?? 'Worker';

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading || myUid == null || workerId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          /// CHAT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chat.chatList(myUid!),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                final chats = snapshot.data?.docs ?? [];

                if (chats.isEmpty) {
                  return const Center(child: Text('No chats yet'));
                }

                return ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) =>
                      const Divider(indent: 80, endIndent: 16),
                  itemBuilder: (_, i) {
                    final chatDoc = chats[i];
                    final chat = chatDoc.data();

                    final String facilityName =
                        (chat['facilityName'] ?? 'Facility').toString();
                    final String facilityImage =
                        (chat['facilityImage'] ?? '').toString();
                    final String lastMessage =
                        (chat['lastMessage'] ?? '').toString();

                    final int unreadCount = (chat['workerUnread'] is int)
                        ? chat['workerUnread']
                        : 0;

                    final bool unread = unreadCount > 0;

                    final bool online = chat['facilityOnline'] == true;

                    final Timestamp? updatedAt = chat['updatedAt'];
                    final String time = updatedAt != null
                        ? DateFormat('hh:mm a').format(updatedAt.toDate())
                        : '';

                    final int facilityId = chat['facilityId'];
                    final String chatId =
                        (chat['chatId'] as String?)?.isNotEmpty == true
                            ? chat['chatId']
                            : chatDoc.id;

                    /// ✅ FIXED PARTICIPANTS HANDLING
                    final List participants = chat['participants'] ?? [];

                    final String facilityUid = participants.firstWhere(
                      (e) => e != myUid,
                      orElse: () => '',
                    );

                    if (facilityUid.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Dismissible(
                      key: ValueKey(chatId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        color: Colors.red,
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (_) async {
                        return await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Delete Chat'),
                            content: const Text(
                                'Are you sure you want to delete this chat?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        await _chat.deleteChat(chatId);
                      },
                      child: InkWell(
                        onTap: () {
                          Get.to(
                            () => ChatDetailView(
                              contactName: facilityName,
                              chatId: chatId,
                              workerId: workerId!,
                              facilityId: facilityId,
                              workerName: workerName,
                              facilityName: facilityName,
                              otherUserFirebaseUid: facilityUid,
                            ),
                          );

                          // 🔥 fire-and-forget (NO await)
                          _chat.markRead(
                            chatId: chatId,
                            role: 'worker',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    backgroundImage: facilityImage.isNotEmpty
                                        ? NetworkImage(facilityImage)
                                        : null,
                                    child: facilityImage.isEmpty
                                        ? Text(
                                            facilityName.isNotEmpty
                                                ? facilityName[0].toUpperCase()
                                                : 'F',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),

                                  // ✅ ONLINE DOT
                                  if (online)
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      facilityName,
                                      style: TextStyle(
                                        fontWeight: unread
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: unread
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: unread
                                            ? Colors.black87
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    time,
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  unread
                                      ? CircleAvatar(
                                          radius: 10,
                                          backgroundColor: AppColors.primary,
                                          child: Text(
                                            unreadCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.done_all,
                                          size: 16, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}

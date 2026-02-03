import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:edm_solutions/controllers/chat_controller.dart';
import 'package:edm_solutions/controllers/auth_controller.dart';

import 'staff_chat_screen.dart';

class StaffChatList extends StatefulWidget {
  const StaffChatList({super.key});

  @override
  State<StaffChatList> createState() => _StaffChatListState();
}

class _StaffChatListState extends State<StaffChatList> {
  final ChatController chat = Get.find<ChatController>();
  final AuthController auth = Get.find<AuthController>();

  String? myUid;
  int? facilityId;
  String facilityName = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = auth.currentUser.value;
    if (user == null || user.firebaseUid == null || user.id == null) return;

    myUid = user.firebaseUid;
    facilityId = user.id;
    facilityName = user.fullName ?? '';

    setState(() {});
  }

  String _chatId(int facilityId, int workerId) =>
      'facility_${facilityId}_worker_${workerId}';

  @override
  Widget build(BuildContext context) {
    if (myUid == null || facilityId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Chat',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ),

      /// ================= BODY =================
      body: Column(
        children: [
          /// SEARCH BAR (UI ONLY)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Search...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

          /// CHAT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chat.chatList(myUid!),
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
                    final doc = chats[i];
                    final c = doc.data();

                    final List participants = c['participants'] ?? [];
                    if (!participants.contains(myUid)) {
                      return const SizedBox.shrink();
                    }

                    final int workerId = c['workerId'];
                    final String workerName = c['workerName'] ?? 'Worker';
                    final String lastMessage = c['lastMessage'] ?? '';
                    final String workerImage = c['workerImage'] ?? '';

                    final int unreadCount =
                    (c['facilityUnread'] is int) ? c['facilityUnread'] : 0;

                    final bool unread = unreadCount > 0;

                    final bool online = c['workerOnline'] == true;

                    final Timestamp? updatedAt = c['updatedAt'];
                    final String time = updatedAt != null
                        ? DateFormat('hh:mm a')
                            .format(updatedAt.toDate())
                        : '';

                    final chatId = _chatId(facilityId!, workerId);

                    final otherUid = participants
                        .firstWhere((e) => e != myUid, orElse: () => '');

                    return Dismissible(
                      key: ValueKey(chatId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      /// ✅ FIXED DELETE LOGIC (ONLY CHANGE)
                      confirmDismiss: (_) async {
                        final bool? confirm = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Delete Chat'),
                            content: const Text(
                                'Are you sure you want to delete this chat?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Get.back(result: false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.back(result: true),
                                child: const Text(
                                  'Delete',
                                  style:
                                      TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          barrierDismissible: false,
                        );

                        if (confirm == true) {
                          await chat.deleteChat(chatId);
                        }

                        /// ❗ Prevent Dismissible from auto-removing
                        return false;
                      },

                      child: InkWell(
                        onTap: () async {
                          await chat.markRead(
                            chatId: chatId,
                            role: 'facility',
                          );

                          Get.to(
                            () => StaffChatScreen(
                              contactName: workerName,
                              chatId: chatId,
                              workerId: workerId,
                              facilityId: facilityId!,
                              workerName: workerName,
                              facilityName: facilityName,
                              otherUserFirebaseUid: otherUid,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              /// AVATAR
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor:
                                        const Color(0xFF1E3A8A),
                                    backgroundImage:
                                        workerImage.isNotEmpty
                                            ? NetworkImage(
                                                workerImage)
                                            : null,
                                    child: workerImage.isEmpty
                                        ? Text(
                                            workerName[0]
                                                .toUpperCase(),
                                            style:
                                                const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  if (online)
                                    const Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: CircleAvatar(
                                        radius: 5,
                                        backgroundColor:
                                            Color(0xFF22C55E),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 12),

                              /// NAME + MESSAGE
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workerName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: unread
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            Colors.grey[600],
                                        fontWeight: unread
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// TIME + UNREAD
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    time,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  unread
  ? CircleAvatar(
      radius: 10,
      backgroundColor: const Color(0xFF1E3A8A),
      child: Text(
        unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    )

                                      : const Icon(
                                          Icons.done_all,
                                          size: 16,
                                          color:
                                              Color(0xFF1E3A8A),
                                        ),
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
}

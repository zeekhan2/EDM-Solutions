import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edm_solutions/controllers/auth_controller.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= CHAT LIST =================
  Stream<QuerySnapshot<Map<String, dynamic>>> chatList(String firebaseUid) {
    if (firebaseUid.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: firebaseUid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // ================= MESSAGES =================
  Stream<QuerySnapshot<Map<String, dynamic>>> messages(String chatId) {
    if (chatId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAtLocal', descending: false)
        .snapshots();
  }

  // ================= SEND MESSAGE =================
  Future<void> sendMessage({
    required String chatId,
    required String senderUid,
    required String receiverUid,
    required String message,
    required String senderRole,
    required int workerId,
    required int facilityId,
    required String workerName,
    required String facilityName,
  }) async {
    if (message.trim().isEmpty) return;

    final auth = Get.find<AuthController>();
    final currentUser = auth.currentUser.value;

    final chatRef = _firestore.collection('chats').doc(chatId);

    // ---------- READ EXISTING CHAT ----------
    final snap = await chatRef.get();
    final data = snap.data() ?? {};

    final int currentWorkerUnread =
        (data['workerUnread'] is int) ? data['workerUnread'] : 0;
    final int currentFacilityUnread =
        (data['facilityUnread'] is int) ? data['facilityUnread'] : 0;

    final String workerImage =
        (data['workerImage'] ?? '').toString().isNotEmpty
            ? data['workerImage']
            : (senderRole == 'worker' ? (currentUser?.image ?? '') : '');

    final String facilityImage =
        (data['facilityImage'] ?? '').toString().isNotEmpty
            ? data['facilityImage']
            : (senderRole == 'facility' ? (currentUser?.image ?? '') : '');

    // ---------- UNREAD LOGIC ----------
    final int newWorkerUnread =
        senderRole == 'facility' ? currentWorkerUnread + 1 : 0;

    final int newFacilityUnread =
        senderRole == 'worker' ? currentFacilityUnread + 1 : 0;

    // ---------- CHAT DOCUMENT ----------
    await chatRef.set(
      {
        'chatId': chatId,
        'participants': [senderUid, receiverUid],

        'workerId': workerId,
        'facilityId': facilityId,

        'workerName': workerName,
        'facilityName': facilityName,

        'workerImage': workerImage,
        'facilityImage': facilityImage,

        'lastMessage': message,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedAtLocal': DateTime.now().millisecondsSinceEpoch,

        'workerUnread': newWorkerUnread,
        'facilityUnread': newFacilityUnread,
      },
      SetOptions(merge: true),
    );

    // ---------- MESSAGE ----------
    await chatRef.collection('messages').add({
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'senderRole': senderRole,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtLocal': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ================= MARK READ =================
  Future<void> markRead({
    required String chatId,
    required String role,
  }) async {
    if (chatId.isEmpty) return;

    await _firestore.collection('chats').doc(chatId).update({
      role == 'worker' ? 'workerUnread' : 'facilityUnread': 0,
    });
  }

  // ================= ONLINE STATUS =================
  Future<void> setOnline({
    required String chatId,
    required String role,
    required bool online,
  }) async {
    if (chatId.isEmpty) return;

    await _firestore.collection('chats').doc(chatId).set(
      {
        role == 'worker' ? 'workerOnline' : 'facilityOnline': online,
      },
      SetOptions(merge: true),
    );
  }

  // ================= CHAT META =================
  Stream<DocumentSnapshot<Map<String, dynamic>>> chatMeta(String chatId) {
    if (chatId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore.collection('chats').doc(chatId).snapshots();
  }

  // ================= DELETE CHAT =================
  Future<void> deleteChat(String chatId) async {
    if (chatId.isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(chatId);

    final messages = await chatRef.collection('messages').get();
    for (final doc in messages.docs) {
      await doc.reference.delete();
    }

    await chatRef.delete();
  }
}

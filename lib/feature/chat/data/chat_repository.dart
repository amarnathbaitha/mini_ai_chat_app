import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<String> createConversation() async {
    final uid = _auth.currentUser!.uid;
    final conversationId = const Uuid().v4();

    await _firestore.collection('conversations').doc(conversationId).set({
      'ownerUid': uid,
      'title': 'New Chat',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return conversationId;
  }

  Stream<QuerySnapshot> getUserConversations() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('conversations')
        .where('ownerUid', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
}

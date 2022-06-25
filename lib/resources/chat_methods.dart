import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/strings.dart';
import '../models/contact.dart';
import '../models/message.dart';

class ChatMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _messageCollection =
      _firestore.collection(messageCollection);

  final CollectionReference _userCollection =
      _firestore.collection(usersCollection);

  Future<void> addMessageToDb(
    Message message,
  ) async {
    var map = message.toMap();
    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map);
    addToContacts(senderId: message.senderId!, receiverId: message.receiverId!);
    await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  DocumentReference getContactsDocument(
          {required String of, required String forContact}) =>
      _userCollection.doc(of).collection(contactsCOLLECTION).doc(forContact);
  addToContacts({required String senderId, required String receiverId}) async {
    Timestamp currentTime = Timestamp.now();
    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);
      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

  Future<void> addToReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();
    if (!receiverSnapshot.exists) {
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );
      var senderMap = senderContact.toMap(senderContact);
      await getContactsDocument(of: receiverId, forContact: senderId)
          .set(senderMap);
    }
  }

  void setImageMsg(String url, String receiverId, String senderId) async {
    Message message = Message.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'image');

    var map = message.toImageMap();

    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map);
    await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({required String userId}) =>
      _userCollection.doc(userId).collection(contactsCOLLECTION).snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({
    required String senderId,
    required String receiverId,
  }) =>
      _messageCollection
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();
}

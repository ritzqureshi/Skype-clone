import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/strings.dart';
import '../models/message.dart';
import '../models/person.dart';
import '../provider/image_upload_provider.dart';
import '../utils/utilities.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Person user = Person();

  Future<User> getCurrentUser() async {
    return _auth.currentUser!;
  }

  Future<Person> getUserDetails() async {
    User user = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await firestore.collection(usersCollection).doc(user.uid).get();
    return Person.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<bool> authenticateUser(UserCredential userCredential) async {
    QuerySnapshot result = await firestore
        .collection(usersCollection)
        .where(emailField, isEqualTo: userCredential.user?.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;
    // If user is registered then length of list > 0 or else less than 0
    return docs.isEmpty ? true : false;
  }

  Future<void> addDataToDb(UserCredential userCred) async {
    String username = Utils.getUsername(userCred.user!.email!);
    Person user = Person(
        uid: userCred.user?.uid,
        name: userCred.user?.displayName,
        email: userCred.user?.email,
        username: username,
        profilePhoto: userCred.user?.photoURL);

    firestore.collection(usersCollection).doc(userCred.user?.uid).set(
          user.toMap(user),
        );
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<List<Person>> fetchAllUsers(User currentUser) async {
    List<Person> userList = [];

    QuerySnapshot querySnapshot =
        await firestore.collection(usersCollection).get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(
          Person.fromMap(querySnapshot.docs[i].data() as Map<String, dynamic>),
        );
      }
    }

    return userList;
  }

  Future<void> addMessageToDb(Message message) async {
    var msg = message.toMap();
    await firestore
        .collection(messageCollection)
        .doc(message.senderId)
        .collection(message.receiverId.toString())
        .add(msg);
    await firestore
        .collection(messageCollection)
        .doc(message.receiverId)
        .collection(message.senderId.toString())
        .add(msg);
  }

  Future<String> uploadImageToStorage(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String url = "";
    Reference ref =
        storage.ref().child(DateTime.now().millisecondsSinceEpoch.toString());
    UploadTask uploadTask = ref.putFile(image);
    await uploadTask.whenComplete(() {
      ref.getDownloadURL().then((value) {
        url = value;
      });
    }).catchError((onError) {
      debugPrint("Error in uploading image to storage: $onError");
    });
    return url;
  }

  void uploadImage(File image, String receiverId, String senderId,
      ImageUploadProvider imageProvider) async {
    imageProvider.setToLoading();
    String url = await uploadImageToStorage(image);
    imageProvider.setToIdle();
    Message message = Message.imageMessage(
        senderId: senderId,
        receiverId: receiverId,
        message: "IMAGE",
        type: "IMAGE",
        timestamp: Timestamp.now(),
        photoUrl: url);
    var msg = message.toImageMap();
    await firestore
        .collection(messageCollection)
        .doc(message.senderId)
        .collection(message.receiverId.toString())
        .add(msg);

    await firestore
        .collection(messageCollection)
        .doc(message.receiverId)
        .collection(message.senderId.toString())
        .add(msg);
  }
}

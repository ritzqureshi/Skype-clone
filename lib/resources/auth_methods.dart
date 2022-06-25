import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/strings.dart';
import '../enum/user_state.dart';
import '../models/person.dart';
import '../utils/utilities.dart';

class AuthMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static final CollectionReference _userCollection =
      _firestore.collection(usersCollection);

  Future<User> getCurrentUser() async {
    return _auth.currentUser!;
  }

  Future<User> getUserDetails() async {
    User currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser.uid).get();
    return documentSnapshot.data() as User;
  }

  Future getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(id).get();
      return Person.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<UserCredential> signIn() async {
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
    QuerySnapshot result = await _firestore
        .collection(usersCollection)
        .where(emailField, isEqualTo: userCredential.user?.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;
    // If user is registered then length of list > 0 or else less than 0
    return docs.isEmpty ? true : false;
  }

  Future<void> addDataToDb(UserCredential userCredential) async {
    String username = Utils.getUsername(userCredential.user?.email ?? "");
    Person user = Person(
        uid: userCredential.user?.uid,
        name: userCredential.user?.displayName,
        email: userCredential.user?.email,
        username: username,
        profilePhoto: userCredential.user?.photoURL);

    _firestore.collection(usersCollection).doc(userCredential.user?.uid).set(
          user.toMap(user),
        );
  }

  Future<List<Person>> fetchAllUsers(User currentUser) async {
    List<Person> userList = <Person>[];

    QuerySnapshot querySnapshot =
        await _firestore.collection(usersCollection).get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(
          Person.fromMap(querySnapshot.docs[i].data() as Map<String, dynamic>),
        );
      }
    }
    return userList;
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  void setUserState({required String userId, required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.doc(userId).update({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({required String uid}) =>
      _userCollection.doc(uid).snapshots();
}

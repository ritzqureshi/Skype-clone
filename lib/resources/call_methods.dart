import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../models/call.dart';

class CallMethods {
  final CollectionReference _callCollection =
      FirebaseFirestore.instance.collection(callCollection);

  Stream<DocumentSnapshot> callStream({required String uid}) =>
      _callCollection.doc(uid).snapshots();

  Future<bool> makeCall({required Call call}) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await _callCollection.doc(call.callerId).set(hasDialledMap);
      await _callCollection.doc(call.receiverId).set(hasNotDialledMap);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> endCall({required Call call}) async {
    try {
      await _callCollection.doc(call.callerId).delete();
      await _callCollection.doc(call.receiverId).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

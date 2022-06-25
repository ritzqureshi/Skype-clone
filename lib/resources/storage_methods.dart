import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

import '../provider/image_upload_provider.dart';
import '../resources/chat_methods.dart';

class StorageMethods {
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadImageToStorage(File image) async {
    String url = "";
    Reference ref = _firebaseStorage
        .ref()
        .child(DateTime.now().millisecondsSinceEpoch.toString());
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

  void uploadImage({
    required File image,
    required String receiverId,
    required String senderId,
    required ImageUploadProvider imageUploadProvider,
  }) async {
    final ChatMethods chatMethods = ChatMethods();
    imageUploadProvider.setToLoading();
    String url = await uploadImageToStorage(image);
    imageUploadProvider.setToIdle();
    chatMethods.setImageMsg(url, receiverId, senderId);
  }
}

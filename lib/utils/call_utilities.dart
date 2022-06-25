import 'package:flutter/material.dart';

import '../Screens/callscreens/call_screen.dart';
import '../models/call.dart';
import '../models/person.dart';
import '../resources/call_methods.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {required Person from,
      required Person to,
      required BuildContext context}) async {
    Call call = Call(
        callerId: from.uid,
        callerName: from.name,
        callerPic: from.profilePhoto,
        receiverId: to.uid,
        receiverName: to.name,
        receiverPic: to.profilePhoto,
        channelId: '',
        hasDialled: null);

    bool callMade = await callMethods.makeCall(call: call);
    call.hasDialled = true;

    if (callMade) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CallScreen(call: call)));
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Screens/callscreens/pickup/pickup_screen.dart';
import '../../../models/call.dart';
import '../../../provider/user_provider.dart';
import '../../../resources/call_methods.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    Key? key,
    required this.scaffold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: callMethods.callStream(uid: userProvider.getUser.uid!),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.data != null) {
          Call call = Call.fromMap(snapshot.data?.data as Map<String, dynamic>);
          if (call.hasDialled != null) {
            return PickupScreen(call: call);
          }
        }
        return scaffold;
      },
    );
  }
}

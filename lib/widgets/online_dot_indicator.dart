import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../enum/user_state.dart';
import '../../models/person.dart';
import '../../resources/auth_methods.dart';
import '../../utils/utilities.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final AuthMethods _authMethods = AuthMethods();

  OnlineDotIndicator({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.offline:
          return Colors.red;
        case UserState.online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _authMethods.getUserStream(uid: uid),
        builder: (context, snapshot) {
          Person _user = Person();
          if (snapshot.hasData && snapshot.data?.data != null) {
            _user = Person.fromMap(snapshot.data?.data as Map<String, dynamic>);
          }

          return Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.only(right: 8, top: 8),
            decoration: BoxDecoration(
              color: getColor(_user.state ?? 3),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}

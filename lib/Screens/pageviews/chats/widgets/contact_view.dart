import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Screens/chatscreens/widget/cached_image.dart';
import '../../../../models/contact.dart';
import '../../../../models/person.dart';
import '../../../../provider/user_provider.dart';
import '../../../../resources/auth_methods.dart';
import '../../../../resources/chat_methods.dart';
import '../../../../screens/chatscreens/chat_screen.dart';
import '../../../../widgets/custom_tile.dart';
import '../../../../widgets/online_dot_indicator.dart';
import 'last_message_container.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  ContactView(this.contact, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Person user = snapshot.data as Person;
          return ViewLayout(
            contact: user,
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final Person contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          )),
      title: Text(
        contact.name ?? "..",
        style: const TextStyle(
            color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: userProvider.getUser.uid!,
          receiverId: contact.uid!,
        ),
      ),
      leading: Container(
        constraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.profilePhoto!,
              radius: 80,
              isRound: true,
            ),
            OnlineDotIndicator(
              uid: contact.uid!,
            ),
          ],
        ),
      ),
    );
  }
}

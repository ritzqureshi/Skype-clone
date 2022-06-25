import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Screens/pageviews/chats/widgets/new_chat_button.dart';
import '../../../models/contact.dart';
import '../../../provider/user_provider.dart';
import '../../../resources/chat_methods.dart';
import '../../../screens/callscreens/pickup/pickup_layout.dart';
import '../../../utils/universal_variables.dart';
import '../../../widgets/quiet_box.dart';
import '../../../widgets/skype_appbar.dart';
import 'widgets/contact_view.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: SkypeAppBar(
          title: const Text("User"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/search_screen");
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButton: const NewChatButton(),
        body: ChatListContainer(),
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();

  ChatListContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<QuerySnapshot>(
        stream: _chatMethods.fetchContacts(
          userId: userProvider.getUser.uid!,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docList = snapshot.data?.docs;
            if (docList == null || docList.isEmpty) {
              return const QuietBox(
                heading: "This is where all the contacts are listed",
                subtitle:
                    "Search for your friends and family to start calling or chatting with them",
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: docList.length,
              itemBuilder: (context, index) {
                Contact contact = Contact.fromMap(
                    docList[index].data as Map<String, dynamic>);
                return ContactView(contact);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        });
  }
}

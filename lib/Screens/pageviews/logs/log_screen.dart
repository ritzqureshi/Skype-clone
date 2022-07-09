import 'package:flutter/material.dart';

import '../../../resources/auth_methods.dart';
import '../../../screens/callscreens/pickup/pickup_layout.dart';
import '../../../screens/login_screen.dart';
import '../../../utils/universal_variables.dart';
import '../../../widgets/skype_appbar.dart';
import 'widgets/log_list_container.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: SkypeAppBar(
          title: const Text("Calls"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pushNamed(context, "/search_screen"),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(10, 10, 10, 10),
                    items: [
                      PopupMenuItem<String>(
                        child: const Text('Sign Out'),
                        value: '1',
                        onTap: () async {
                          await AuthMethods().signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                    ]);
              },
            ),
          ],
        ),
        // floatingActionButton: const FloatingColumn(),
        body: const Padding(
          padding: EdgeInsets.only(left: 15),
          child: LogListContainer(),
        ),
      ),
    );
  }
}

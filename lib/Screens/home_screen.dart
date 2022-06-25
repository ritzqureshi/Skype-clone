import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../enum/user_state.dart';
import '../../provider/user_provider.dart';
import '../../resources/auth_methods.dart';
import '../../resources/local_db/repository/log_repository.dart';
import '../../screens/callscreens/pickup/pickup_layout.dart';
import '../../screens/pageviews/chats/chat_list_screen.dart';
import '../../screens/pageviews/logs/log_screen.dart';
import '../../utils/universal_variables.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AuthMethods _authMethods = AuthMethods();
  PageController pageController = PageController();
  UserProvider userProvider = UserProvider();
  int _page = 0;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refreshUser();

      _authMethods.setUserState(
        userId: userProvider.getUser.uid ?? "",
        userState: UserState.online,
      );

      LogRepository.init(
        isHive: true,
        dbName: userProvider.getUser.uid ?? "",
      );
    });

    WidgetsBinding.instance?.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId = userProvider.getUser.uid ?? "";
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != ""
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.online)
            : debugPrint("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != ""
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.offline)
            : debugPrint("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != ""
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.waiting)
            : debugPrint("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != ""
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.offline)
            : debugPrint("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        body: PageView(
          children: const <Widget>[
            ChatListScreen(),
            LogScreen(),
            Center(
                child: Text(
              "Contact Screen",
              style: TextStyle(color: Colors.white),
            )),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: CupertinoTabBar(
            backgroundColor: UniversalVariables.blackColor,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.chat,
                    color: (_page == 0)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor),
                label: "Chats",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call,
                    color: (_page == 1)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor),
                label: "Calls",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contact_phone,
                    color: (_page == 2)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor),
                label: "Contacts",
              ),
            ],
            onTap: navigationTapped,
            currentIndex: _page,
          ),
        ),
      ),
    );
  }
}

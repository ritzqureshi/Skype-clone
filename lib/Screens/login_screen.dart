import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../resources/auth_methods.dart';
import '../../utils/universal_variables.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: UniversalVariables.blueColor,
        body: Stack(
          children: [
            Center(
              child: loginButton(),
            ),
            isLoginPressed
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget loginButton() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: const Color.fromARGB(255, 190, 109, 47),
      child: TextButton(
        child: const Text(
          "LOGIN",
          style: TextStyle(
              fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        // onPressed: () {
        //   Navigator.push(context, MaterialPageRoute(builder: (context) {
        //     return const HomeScreen();
        //   }));
        // }

        onPressed: () => performLogin(),
      ),
    );
  }

  void performLogin() async {
    setState(() {
      isLoginPressed = true;
    });

    UserCredential userCredential = await _authMethods.signIn();
    authenticateUser(userCredential);
    setState(() {
      isLoginPressed = false;
    });
  }

  void authenticateUser(UserCredential userCredential) {
    _authMethods.authenticateUser(userCredential).then((isNewUser) {
      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        _authMethods.addDataToDb(userCredential).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return const HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const HomeScreen();
        }));
      }
    });
  }
}

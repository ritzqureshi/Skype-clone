import 'package:flutter/material.dart';

import '../models/person.dart';
import '../resources/firebase_methods.dart';

class UserProvider with ChangeNotifier {
  Person _user = Person();
  final FirebaseMethods _firebaseMethods = FirebaseMethods();

  Person get getUser => _user;

  void refreshUser() async {
    Person user = await _firebaseMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}

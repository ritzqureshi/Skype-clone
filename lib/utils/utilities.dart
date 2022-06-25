import 'dart:io';

import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../enum/user_state.dart';

class Utils {
  static String getUsername(String email) {
    return "live:${email.split('@')[0]}";
  }

  static String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String firstNameInitial = nameSplit[0][0];
    String secondNameInitial = nameSplit[1][0];
    return firstNameInitial + secondNameInitial;
  }

  static Future<File> pickImage({required ImageSource source}) async {
    File selectedImage = await pickImage(source: source);
    return await compressImage(selectedImage);
  }

  static Future<File> compressImage(File imageToCompress) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    String rand = DateTime.now().millisecondsSinceEpoch.toString();
    final image = decodeImage(File('test.webp').readAsBytesSync())!;
    copyResize(image, width: 500, height: 500);

    return File('$path/img_$rand.jpg')
      ..writeAsBytesSync(encodeJpg(image, quality: 85));
  }

  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.offline:
        return 0;

      case UserState.online:
        return 1;

      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.offline;

      case 1:
        return UserState.online;

      default:
        return UserState.waiting;
    }
  }

  static String formatDateString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(dateTime);
  }
}

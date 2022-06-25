import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> cameraAndMicrophonePermissionsGranted() async {
    PermissionStatus cameraPermissionStatus = await _getCameraPermission();
    PermissionStatus microphonePermissionStatus =
        await _getMicrophonePermission();

    if (cameraPermissionStatus == PermissionStatus.granted &&
        microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handleInvalidPermissions(
          cameraPermissionStatus, microphonePermissionStatus);
      return false;
    }
  }

  static Future<PermissionStatus> _getCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> permissionStatus = await [
        Permission.camera,
      ].request();
      debugPrint(permissionStatus[Permission.camera].toString());
      return permissionStatus[Permission.camera]!;
    }
    return status;
  }

  static Future<PermissionStatus> _getMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.microphone].request();
      debugPrint(permissionStatus[Permission.microphone].toString());
      return permissionStatus[Permission.microphone]!;
    } else {
      return status;
    }
  }

  static void _handleInvalidPermissions(
    PermissionStatus cameraPermissionStatus,
    PermissionStatus microphonePermissionStatus,
  ) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
            microphonePermissionStatus == PermissionStatus.denied ||
        cameraPermissionStatus == PermissionStatus.permanentlyDenied &&
            microphonePermissionStatus == PermissionStatus.permanentlyDenied) {
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.restricted &&
        microphonePermissionStatus == PermissionStatus.restricted) {
      throw PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }
}

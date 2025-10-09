import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) return "Web browser - no device ID";

  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? ""; // ✅ androidId, serialNumber removed
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "";
    }
  } catch (e) {
    print("Error getting device ID: $e");
  }

  return "Unknown device ID";
}

import 'dart:io';

import 'package:flutter/services.dart';

class PackageInstaller {
  static const _channel = MethodChannel('tas/install');

  static Future<bool> canInstall() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('canInstall') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> install(String path) async {
    if (!Platform.isAndroid) {
      return;
    }
    await _channel.invokeMethod<void>('install', {'path': path});
  }

  static Future<void> openUrl(String url) async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('openUrl', {'url': url});
    } catch (_) {
      // Opening the browser is best-effort. The URL stays visible in the dialog.
    }
  }
}

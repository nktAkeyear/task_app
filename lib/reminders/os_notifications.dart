import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/models.dart';

/// OS notifications are best-effort. The in-app scheduler remains the source
/// of truth when a platform plugin cannot be initialized.
class OsNotifications {
  OsNotifications._();

  static final OsNotifications instance = OsNotifications._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _zoneReady = false;

  Future<void> init() async {
    if (_runningTests || _ready) {
      return;
    }
    // Linux has no session bus in many dev environments, and the plugin's
    // D-Bus listen can surface as an unhandled async error. Reminders stay
    // in-app. Android and Windows still use the OS plugin.
    if (!kIsWeb && Platform.isLinux) {
      return;
    }
    try {
      tzdata.initializeTimeZones();
      final name = DateTime.now().timeZoneName;
      try {
        tz.setLocalLocation(tz.getLocation(name));
        _zoneReady = true;
      } catch (_) {
        _zoneReady = false;
      }
      final granted = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          linux: LinuxInitializationSettings(defaultActionName: '開く'),
          windows: WindowsInitializationSettings(
            appName: 'Tas',
            appUserModelId: 'TasApp.Tas.Task.1',
            guid: '6f1c1d2a-7b4e-4c1a-9d2e-3a5b6c7d8e9f',
          ),
        ),
      );
      _ready = granted ?? true;
    } catch (error, stack) {
      _ready = false;
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'tas notifications'));
    }
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } catch (_) {
        // The in-app banner still fires if the system prompt cannot be shown.
      }
    }
  }

  Future<void> showTask(TaskModel task) async {
    if (!_ready) {
      return;
    }
    try {
      await _plugin.show(
        id: task.id.hashCode & 0x7fffffff,
        title: 'Tas',
        body: task.title,
        notificationDetails: _details(),
        payload: task.id,
      );
    } catch (_) {
      // The in-app banner still shows.
    }
  }

  Future<void> schedule(TaskModel task) async {
    if (!_ready || !_zoneReady || task.reminderAt == null) {
      return;
    }
    if (kIsWeb || !(Platform.isAndroid || Platform.isWindows)) {
      return;
    }
    final when = task.reminderAt!;
    if (!when.isAfter(DateTime.now())) {
      return;
    }
    try {
      await _plugin.zonedSchedule(
        id: task.id.hashCode & 0x7fffffff,
        title: 'Tas',
        body: task.title,
        scheduledDate: tz.TZDateTime(
          tz.local,
          when.year,
          when.month,
          when.day,
          when.hour,
          when.minute,
          when.second,
        ),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: task.id,
      );
    } catch (_) {
      // Background delivery is optional. In-app reminders still fire.
    }
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'tas.reminders',
        'リマインダー',
        channelDescription: 'Tas のタスクリマインダー',
        importance: Importance.high,
        priority: Priority.high,
      ),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );
  }
}

bool get _runningTests {
  return WidgetsBinding.instance.runtimeType.toString().contains('Test');
}

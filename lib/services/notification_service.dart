import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Singleton that wraps the browser Web Notifications API.
///
/// Call [init] once from main() — it will request notification permission.
/// Call [scheduleMedicineReminders] after the user saves medicines.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  bool _permissionGranted = false;

  // ──────────────────────────────────────────────────────────────────────────
  // Initialisation — request browser permission
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (!kIsWeb) return;

    try {
      final String current = web.Notification.permission;
      if (current == 'granted') {
        _permissionGranted = true;
        debugPrint('[NotificationService] Permission already granted.');
        return;
      }

      if (current == 'denied') {
        debugPrint('[NotificationService] Permission denied by user.');
        return;
      }

      // 'default' — ask the user.
      final String result =
          (await web.Notification.requestPermission().toDart).toDart;
      _permissionGranted = result == 'granted';
      debugPrint('[NotificationService] Permission result: $result');
    } catch (e) {
      debugPrint('[NotificationService] Could not request permission: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Scheduling
  // ──────────────────────────────────────────────────────────────────────────

  /// Maps the weekday labels used by MedicineLoggingScreen to Dart's
  /// [DateTime.weekday] values (1 = Monday … 7 = Sunday).
  static const Map<String, int> _weekdayMap = {
    'Mon': DateTime.monday,
    'Tue': DateTime.tuesday,
    'Wed': DateTime.wednesday,
    'Thu': DateTime.thursday,
    'Fri': DateTime.friday,
    'Sat': DateTime.saturday,
    'Sun': DateTime.sunday,
  };

  /// Schedules a native browser notification for every medicine whose
  /// day-of-week list includes today and whose dose time is still in the future.
  ///
  /// Each map in [medicines] must contain:
  ///   medicineName, quantity, doseUnit, doseTime (formatted HH:mm a), days.
  Future<void> scheduleMedicineReminders(
    List<Map<String, dynamic>> medicines,
  ) async {
    if (!kIsWeb) return;
    if (!_permissionGranted) {
      await init();
      if (!_permissionGranted) {
        debugPrint('[NotificationService] No permission — skipping reminders.');
        return;
      }
    }

    final DateTime now = DateTime.now();
    final int todayWeekday = now.weekday; // 1 = Mon … 7 = Sun

    for (final medicine in medicines) {
      final List<String> days =
          List<String>.from(medicine['days'] as List? ?? []);

      // Is today in this medicine's schedule?
      final bool isToday = days.any(
        (d) => (_weekdayMap[d] ?? -1) == todayWeekday,
      );
      if (!isToday) continue;

      final DateTime? doseDateTime =
          _parseDoseTime(medicine['doseTime'] as String? ?? '');
      if (doseDateTime == null) continue;

      final Duration delay = doseDateTime.difference(now);
      if (delay.isNegative) {
        debugPrint(
          '[NotificationService] Skipping ${medicine['medicineName']} '
          '— dose time already passed.',
        );
        continue;
      }

      final String medicineName =
          medicine['medicineName'] as String? ?? 'Medicine';
      final String quantity = medicine['quantity'] as String? ?? '';
      final String unit = medicine['doseUnit'] as String? ?? '';
      final String timeStr = medicine['doseTime'] as String? ?? '';

      debugPrint(
        '[NotificationService] Scheduling "$medicineName" '
        'in ${delay.inMinutes} min(s).',
      );

      // Dart Timer triggers the browser notification at dose time as long as
      // the Chrome tab remains open.
      Future.delayed(delay, () {
        _showNotification(
          title: 'Time for $medicineName',
          body: 'Take $quantity $unit at $timeStr. Stay on track with Glub!',
        );
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Internal helpers
  // ──────────────────────────────────────────────────────────────────────────

  void _showNotification({
    required String title,
    required String body,
  }) {
    try {
      web.Notification(
        title,
        web.NotificationOptions(
          body: body,
          icon: '/icons/Icon-192.png',
        ),
      );
      debugPrint('[NotificationService] Notification shown: $title');
    } catch (e) {
      debugPrint('[NotificationService] Failed to show notification: $e');
    }
  }

  /// Parses a time string such as "8:30 AM" or "14:05" into a [DateTime]
  /// for today.
  DateTime? _parseDoseTime(String timeStr) {
    if (timeStr.isEmpty) return null;

    try {
      final DateTime now = DateTime.now();
      int hour;
      int minute;

      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        // 12-hour format: "8:30 AM" / "12:05 PM"
        final bool isPM = timeStr.contains('PM');
        final String clean = timeStr.replaceAll(RegExp(r'[APM\s]'), '');
        final List<String> parts = clean.split(':');
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);

        if (hour == 12) {
          hour = isPM ? 12 : 0;
        } else if (isPM) {
          hour += 12;
        }
      } else {
        // 24-hour: "14:05"
        final List<String> parts = timeStr.split(':');
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      debugPrint('[NotificationService] Failed to parse time "$timeStr": $e');
      return null;
    }
  }
}

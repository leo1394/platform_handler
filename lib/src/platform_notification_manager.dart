import 'package:flutter/services.dart';
import 'platform_notification.dart';

abstract class PlatformNotificationManager {
  dynamic n2fCallDispatcher(MethodCall call);
  void subscribe(List<PlatformNotification> notifications);
}
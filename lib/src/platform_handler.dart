import 'package:flutter/services.dart';
import 'package:enhanced_change_notifier/enhanced_change_notifier.dart';
import 'platform_notification.dart';
import 'platform_notification_manager.dart';

class PlatformHandler extends EnhancedChangeNotifier
    implements PlatformNotificationManager {
  @override
  void subscribe(List<PlatformNotification> notifications) {
    for (var element in notifications) {
      super.addListener(element.receiver, target: element.getSubscriptions());
    }
  }

  @override
  Future<dynamic> n2fCallDispatcher(MethodCall call) async {
    if (hasListeners) {
      super.properties[call.method] = call.arguments;
      notifyListeners(call.method);
    }
    return "SUCCESS";
  }
}

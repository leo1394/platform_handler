import 'package:enhanced_change_notifier/signal.dart';

class PlatformNotification {
  Signal throttlingSignal = Signal();
  Map<String, Function> subscribers = {};
  bool docking = false;

  dynamic receiver(String method, dynamic arguments) {
    if (!docking || subscribers.isEmpty || !subscribers.containsKey(method)) {
      return;
    }
    Function.apply(subscribers[method]!, [arguments]);
  }

  List<String> getSubscriptions() => subscribers.keys.toList();
  void dockingOff() {
    docking = false;
  }

  void dockingOn() {
    docking = true;
  }
}

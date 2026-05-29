import 'package:flutter/services.dart';
import 'package:platform_handler/platform_handler.dart';
import 'package:platform_handler/platform_notification.dart';

Future<void> main() async {
  final handler = AppPlatformHandler();
  final logNotification = LogNotification()..listen();
  final ruleNotification = RuleNotification(
    onResult: (result) => print('rule result: $result'),
  )..listen();

  handler.registerChannel('native.demo.com/messageChannel');
  handler.subscribe([
    logNotification,
    ruleNotification,
  ]);

  await handler.invokeMethod('startLog');
  await handler.invokeMethod('luaScript', 'return 1', ruleNotification);
}

class AppPlatformHandler extends PlatformHandler {
  @override
  Future<dynamic> n2fCallDispatcher(MethodCall call) async {
    print('native -> flutter: ${call.method}, ${call.arguments}');
    return super.n2fCallDispatcher(call);
  }
}

class LogNotification extends PlatformNotification {
  LogNotification() {
    subscribers = {
      'LogCallback': onLog,
    };
  }

  void listen() {
    docking = true;
  }

  void onLog(dynamic arguments) {
    print('log: $arguments');
  }
}

class RuleNotification extends PingPongPlatformNotification {
  final void Function(dynamic result) onResult;

  RuleNotification({required this.onResult}) {
    subscribers = {
      'RuleResult': onRuleResult,
    };
  }

  void listen() {
    docking = true;
  }

  void onRuleResult(dynamic responseData) {
    onResult(responseData);
  }
}

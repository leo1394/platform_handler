import 'dart:async';
import 'dart:convert';

import 'package:enhanced_change_notifier/enhanced_change_notifier.dart';
import 'package:flutter/services.dart';
import 'package:platform_handler/platform_handler.dart';
import 'package:platform_handler/platform_notification.dart';

const MethodChannel _methodChannel = MethodChannel('native.clobotics.com/dualMessageChannel');

void main() {
  final GlobalFactory<MPlatformHandler> handler = GlobalFactory(() => MPlatformHandler());
  _methodChannel.setMethodCallHandler(handler.getInstance().n2fCallDispatcher);

  FusedLocationCallback fusedLocationCallback = FusedLocationCallback();
  List<PlatformNotification> listeners = [ fusedLocationCallback ];

  handler.getInstance().subscribe(listeners);

  fusedLocationCallback.dockingOn();
  _methodChannel.invokeMethod("locationUpdate");
}

class MPlatformHandler extends PlatformHandler {
  @override
  Future<dynamic> n2fCallDispatcher(MethodCall call) async {
    print("call.method: ${call.method}, call.arguments: ${call.arguments}");
    switch (call.method) {
      case "LogCallback": //日志回调
        String tag = call.arguments["tag"];
        String message = call.arguments["message"];
        print("$tag: $message");
        break;
    }

    return super.n2fCallDispatcher(call);
  }
}

class FusedLocationCallback extends PlatformNotification {
  int lastUpdatedTimestamp = 0;
  List<Completer> _completers = [];
  Timer? updateLatestLocationTimer;

  FusedLocationCallback() {
    subscribers = {
      "fineLocationCallback": fusedLocationResultCallback, // fine location update
      "coarseLocationCallback": fusedLocationResultCallback, // coarse location update
    };
  }

  @override
  void dockingOn({Completer? completer}) {
    if(completer != null && !completer.isCompleted) {
      _completers.add(completer);
    }
    _completers = _completers.where((element) => !element.isCompleted).toList();
    docking = true;
  }

  void fusedLocationResultCallback(dynamic callbackJson) {
    Map<String, dynamic>? result = json.decode(callbackJson);
    if(result == null || result["code"] != 0) {
      _completers.map((e) => e.complete(2));
      _completers = [];
      return ;
    }

    var longitude = result["longitude"];
    var latitude = result["latitude"];
    lastUpdatedTimestamp = DateTime.now().millisecondsSinceEpoch;
    print("longitude: $longitude, latitude: $latitude");
    _completers.map((e) => e.complete(0));
    _completers = [];
  }
}

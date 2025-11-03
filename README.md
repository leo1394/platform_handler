## enhanced_change_notifier
[![pub package](https://img.shields.io/pub/v/platform_handler.svg)](https://pub.dev/packages/platform_handler)
[![pub points](https://img.shields.io/pub/points/platform_handler?color=2E8B57&label=pub%20points)](https://pub.dev/packages/platform_handler/score)
[![GitHub Issues](https://img.shields.io/github/issues/leo1394/platform_handler.svg?branch=master)](https://github.com/leo1394/platform_handler/issues)
[![GitHub Forks](https://img.shields.io/github/forks/leo1394/platform_handler.svg?branch=master)](https://github.com/leo1394/platform_handler/network)
[![GitHub Stars](https://img.shields.io/github/stars/leo1394/platform_handler.svg?branch=master)](https://github.com/leo1394/platform_handler/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT%20-blue.svg)](https://raw.githubusercontent.com/leo1394/platform_handler/master/LICENSE)

A handler plugin package that provides a cross-platform solution for handling platform message channel notifications.

## How to use

- Create a custom class for the platform handler.
```dart
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
```

- Define a custom class for the platform notification.
```dart
class FusedLocationCallback extends PlatformNotification {
  int lastUpdatedTimestamp = 0;
  List<Completer> _completers = [];
  Timer? updateLatestLocationTimer;

  FusedLocationCallback() {
    subscribers = {
      "fineLocationCallback":
          fusedLocationResultCallback, // fine location update
      "coarseLocationCallback":
          fusedLocationResultCallback, // coarse location update
    };
  }

  @override
  void dockingOn({Completer? completer}) {
    if (completer != null && !completer.isCompleted) {
      _completers.add(completer);
    }
    _completers = _completers.where((element) => !element.isCompleted).toList();
    docking = true;
  }

  void fusedLocationResultCallback(dynamic callbackJson) {
    Map<String, dynamic>? result = json.decode(callbackJson);
    print("The fused location updated: $result");
    _completers.map((e) => e.complete(0));
    _completers = [];
  }
}
```

- Create an instance of the platform handler and set the method call handler.
```dart
  import 'package:enhanced_change_notifier/enhanced_change_notifier.dart';

  const MethodChannel _methodChannel = MethodChannel('native.demo.com/messageChannel');
  final GlobalFactory<MPlatformHandler> handler =
    GlobalFactory(() => MPlatformHandler());
  _methodChannel.setMethodCallHandler(handler.getInstance().n2fCallDispatcher);

  FusedLocationCallback fusedLocationCallback = FusedLocationCallback();
  List<PlatformNotification> listeners = [fusedLocationCallback];

  handler.getInstance().subscribe(listeners);

  fusedLocationCallback.dockingOn();
  _methodChannel.invokeMethod("locationUpdate");
```

## Additional information
Feel free to file an issue if you have any problem.
import 'dart:async';

import 'package:flutter/services.dart';

//Initalisierung der Brücke zwischen ios nativ und dart
class NativeCode {
  static EventChannel epicStreamer =
      const EventChannel("com.tracker.bundisim/data_stream");

  static Stream streamData() {
    return epicStreamer.receiveBroadcastStream("Stream");
  }
}

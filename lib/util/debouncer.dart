import 'dart:async';

import 'package:flutter/foundation.dart';

// https://medium.com/fantageek/how-to-debounce-action-in-flutter-ed7177843407
class Debouncer {
  late int milliseconds;
  late VoidCallback action;
  Timer? _timer;
  Debouncer({ required this.milliseconds });
  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
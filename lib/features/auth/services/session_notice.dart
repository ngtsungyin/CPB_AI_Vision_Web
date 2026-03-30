import 'package:flutter/foundation.dart';

class SessionNotice {
  SessionNotice._();

  static final ValueNotifier<String?> message = ValueNotifier<String?>(null);

  static void show(String text) {
    message.value = text;
  }

  static void clear() {
    message.value = null;
  }
}
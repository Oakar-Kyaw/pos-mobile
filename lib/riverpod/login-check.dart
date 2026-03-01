import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckLoginNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Default to Logged Out

  void login() => state = true;
  void logout() => state = false;
}

final checkLoginProvider = NotifierProvider<CheckLoginNotifier, bool>(
  CheckLoginNotifier.new,
);

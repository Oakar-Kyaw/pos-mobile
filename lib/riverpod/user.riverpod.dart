import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/models/user.dart';

class UserNotifier extends Notifier<User?> {
  @override
  User? build() {
    return null;
  }

  void setUser(User user) {
    state = user;
  }

  void clear() {
    state = null;
  }
}

final userStateProvider = NotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);

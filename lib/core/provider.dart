// // core/providers.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pos/api/dio.dart';
// import 'package:pos/core/session-navigation.dart';
// import 'package:pos/utils/secure-storage.dart';

// final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

// final sessionProvider = Provider<Session>((ref) {
//   return Session(ref: ref, secureStorage: ref.watch(secureStorageProvider));
// });

// final dioServiceProvider = Provider<DioService>((ref) {
//   return DioService(session: ref.watch(sessionProvider));
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos/api/dio.dart';
import 'package:pos/core/session-navigation.dart';
import 'package:pos/utils/secure-storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final sessionProvider = Provider<Session>((ref) {
  return Session(ref: ref, secureStorage: ref.watch(secureStorageProvider));
});

final dioServiceProvider = Provider<DioService>((ref) {
  return DioService(
    session: ref.watch(sessionProvider),

    secureStorage: ref.watch(secureStorageProvider),
  );
});

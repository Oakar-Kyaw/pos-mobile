import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/service/firebase-service.dart';
import 'package:pos/core/widgets/app-local-notification.dart';
import 'package:pos/core/widgets/no-internet.dart';
import 'package:pos/localization/localization.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/go-router.dart';
import 'package:pos/utils/secure-storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:restart_app/restart_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only what's strictly needed for the FIRST FRAME goes here.
  // Run them in parallel instead of sequential await.
  await Future.wait([
    FlutterLocalization.instance.ensureInitialized(),
    dotenv.load(fileName: ".env"),
  ]);
  initLocalization();
  //Pre-load font so it's ready before any theme build
  if (Platform.isAndroid || Platform.isIOS) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // await GoogleFonts.pendingFonts([
  //   GoogleFonts.merriweather(),
  //   //GoogleFonts.notoSansMyanmar(),
  // ]);
  await AppLocalNotification.initialize();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

// final _fontFamily = GoogleFonts.merriweather().fontFamily;
//final _fontFamily = GoogleFonts.notoSansMyanmar().fontFamily;

class _MyAppState extends ConsumerState<MyApp> {
  final _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    localization.onTranslatedLanguage = (_) {
      setState(() {});
    };
    //add login status in this
    // _checkLogin();
    // _checkTheme();
    // _checkLanguage();

    // Non-critical for first frame — defer until AFTER first paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLocalNotification.initialize();
      _setupFirebaseNotification();
      _checkForShorebirdUpdate();
    });
  }

  Future<void> _checkForShorebirdUpdate() async {
    final updater = ShorebirdUpdater();
    final notifier = AppLocalNotification();
    const shorebirdNotiId = 2001;

    if (!updater.isAvailable) {
      print('Shorebird is not available on this platform.');
      return;
    }

    try {
      final status = await updater.checkForUpdate();
      print('Update status: $status');

      if (status == UpdateStatus.outdated) {
        print('Downloading Shorebird patch...');

        await notifier.showShorebirdUpdateProgress(
          notiId: shorebirdNotiId,
          title: 'Updating POS Master',
          body: 'Downloading the latest update…',
        );

        await updater.update();
        await _showRestartDialog(context);
        // print('Patch downloaded successfully.');
        // print('Restart the app to apply the patch.');

        await notifier.showShorebirdUpdateReady(
          notiId: shorebirdNotiId,
          title: 'Update ready',
          body: 'Restart the app to apply the latest update.',
        );
      } else {
        print('No patch available.');
      }
    } catch (e) {
      print('Shorebird update error: $e');
      await notifier.cancelShorebirdNotification(notiId: shorebirdNotiId);
    }
  }

  void _setupFirebaseNotification() async {
    //if window and linux , doesn't provider id
    if (Platform.isWindows || Platform.isLinux) return;
    await FirebaseService.instance.init();
    FirebaseMessaging instance = FirebaseMessaging.instance;
    print("setup firbase notification is: 😘 $instance");
    await instance.requestPermission(alert: true, badge: true, sound: true);
    //for foreground
    await instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get & Print Token
    String? token = await instance.getToken() ?? "";
    debugPrint("🔑 FCM Tokens: $token");
    if (!mounted) return;

    //if token exist
    if (token.isNotEmpty) {
      await _secureStorage.saveFirebaseToken(token);
    }

    FirebaseService.instance.noitificationListen().listen((notif) {
      print("notif 👨‍🏭 ${notif.description}");
      AppLocalNotification().showNotification(
        notiId: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: notif.title,
        body: notif.description,
        imageUrl: notif.imageUrl,
        isAndroidImage: notif.isAndroidImage,
        isIOSImage: notif.isIOSImage,
      );
    });
  }

  //Restart app if update
  Future<void> _showRestartDialog(BuildContext context) async {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final notifier = AppLocalNotification();
    final restart = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Update ready'),
        content: const Text('Restart the app to apply the latest update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restart now'),
          ),
        ],
      ),
    );

    if (restart == true) {
      await notifier.cancelShorebirdNotification(notiId: 2001);
      Restart.restartApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routeProvider);
    final fontFamily = "NotoSerif";

    return ShadApp.custom(
      themeMode: themeMode,
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      appBuilder: (context) {
        return MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          supportedLocales: localization.supportedLocales,
          localizationsDelegates: localization.localizationsDelegates,
          theme: Theme.of(context).copyWith(
            scaffoldBackgroundColor: kBgLight,
            textTheme: Theme.of(
              context,
            ).textTheme.apply(fontFamily: fontFamily),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: kBgDark, // 👈 add this
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: fontFamily),
          ),
          themeMode: themeMode,
          themeAnimationDuration: Duration.zero,
          routerConfig: router,
          builder: (context, child) {
            final baseTheme = Theme.of(context);

            final responsiveTextTheme = baseTheme.textTheme.copyWith(
              // Title
              titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
                fontSize: FontSizeConfig.title1(context),
              ),
              titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
                fontSize: FontSizeConfig.title2(context),
              ),

              // Body
              bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
                fontSize: FontSizeConfig.body1(context),
              ),
              bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
                fontSize: FontSizeConfig.body1(context),
              ),
              bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
                fontSize: FontSizeConfig.body2(context),
              ),
            );

            return Theme(
              data: baseTheme.copyWith(
                textTheme: responsiveTextTheme,
                // Icon default size
                iconTheme: baseTheme.iconTheme.copyWith(
                  size: FontSizeConfig.iconSize1(context),
                ),
              ),
              child: ShadToaster(child: NoInternetBanner(child: child!)),
            );
          },
        );
      },
    );
  }
}

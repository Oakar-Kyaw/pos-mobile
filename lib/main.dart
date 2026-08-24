import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/core/service/firebase-service.dart';
import 'package:pos/core/widgets/app-local-notification.dart';
import 'package:pos/localization/localization.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/go-router.dart';
import 'package:pos/utils/local-user.dart';
import 'package:pos/utils/secure-storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  initLocalization();
  await dotenv.load(fileName: ".env");
  //Pre-load font so it's ready before any theme build

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // await GoogleFonts.pendingFonts([
  //   GoogleFonts.merriweather(),
  //   //GoogleFonts.notoSansMyanmar(),
  // ]);
  AppLocalNotification.initialize();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

final _fontFamily = "NotoSerif";
// final _fontFamily = GoogleFonts.merriweather().fontFamily;
//final _fontFamily = GoogleFonts.notoSansMyanmar().fontFamily;

class _MyAppState extends ConsumerState<MyApp> {
  final _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _setupFirebaseNotification();
    localization.onTranslatedLanguage = (_) {
      setState(() {});
    };
    //add login status in this
    _checkLogin();
    _checkTheme();
    _checkLanguage();
    _checkForShorebirdUpdate();
  }

  Future<void> _checkTheme() async {
    final isDark = await _secureStorage.getTheme();
    ref
        .read(themeModeProvider.notifier)
        .setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _checkLogin() async {
    final isLogin = await _secureStorage.getLogin();

    if (!mounted) return; // VERY IMPORTANT

    if (isLogin) {
      ref.read(checkLoginProvider.notifier).login();
      await addToUserLocalStateWidget(ref);
    } else {
      ref.read(checkLoginProvider.notifier).logout();
    }
  }

  Future<void> _checkLanguage() async {
    final languageCode = await _secureStorage.getLanguageSetting();
    localization.translate(languageCode);
  }

  Future<void> _checkForShorebirdUpdate() async {
    final updater = ShorebirdUpdater();

    // Check if updates are available on this platform.
    if (!updater.isAvailable) {
      print('Shorebird is not available on this platform.');
      return;
    }

    try {
      final status = await updater.checkForUpdate();
      print('Update status: $status');

      if (status == UpdateStatus.outdated) {
        print('Downloading Shorebird patch...');

        await updater.update();

        print('Patch downloaded successfully.');
        print('Restart the app to apply the patch.');
      } else {
        print('No patch available.');
      }
    } catch (e) {
      print('Shorebird update error: $e');
    }
  }

  void _setupFirebaseNotification() async {
    await FirebaseService.instance.init();
    FirebaseMessaging instance = FirebaseMessaging.instance;
    print("setup firbase notification is: 😘 $instance");
    await instance.requestPermission(alert: true, badge: true, sound: true);
    // Get & Print Token
    String? token = await instance.getToken() ?? "";
    debugPrint("🔑 FCM Tokens: $token");
    if (!mounted) return;

    //if token exist
    if (token.isNotEmpty) {
      ref
          .read(userProvider.notifier)
          .createorUpdateNotificationDeviceToken(deviceToken: token);
    }

    FirebaseService.instance.noitificationListen().listen((notif) {
      // print("notif 👨‍🏭 ${notif.description}");
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

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routeProvider);

    return ShadApp.custom(
      themeMode: themeMode,
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      appBuilder: (context) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          supportedLocales: localization.supportedLocales,
          localizationsDelegates: localization.localizationsDelegates,
          theme: Theme.of(context).copyWith(
            scaffoldBackgroundColor: kBgLight,
            textTheme: Theme.of(
              context,
            ).textTheme.apply(fontFamily: _fontFamily),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: kBgDark, // 👈 add this
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: _fontFamily,
            ),
          ),
          themeMode: themeMode,
          themeAnimationDuration: Duration.zero,
          routerConfig: router,
          builder: (context, child) {
            final baseTheme = Theme.of(context);
            final responsiveTextTheme = baseTheme.textTheme.copyWith(
              titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
                fontSize: FontSizeConfig.title(context),
              ),
              titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
                fontSize: FontSizeConfig.title(context),
              ),
              bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
                fontSize: FontSizeConfig.body(context),
              ),
              bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
                fontSize: FontSizeConfig.body(context),
              ),
            );
            return Theme(
              data: baseTheme.copyWith(textTheme: responsiveTextTheme),
              child: ShadToaster(child: child!),
            );
          },
        );
      },
    );
  }
}

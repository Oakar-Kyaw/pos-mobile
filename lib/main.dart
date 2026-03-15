import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/localization/localization.dart';
import 'package:pos/models/user.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/riverpod/company.riverpod.dart';
import 'package:pos/models/company.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/go-router.dart';
import 'package:pos/utils/local-user.dart';
import 'package:pos/utils/secure-storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  initLocalization();
  await dotenv.load(fileName: ".env");
  //Pre-load font so it's ready before any theme build
  await GoogleFonts.pendingFonts([
    GoogleFonts.merriweather(),
    //GoogleFonts.notoSansMyanmar(),
  ]);
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

final _fontFamily = GoogleFonts.merriweather().fontFamily;
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
    _checkLogin();
    _checkTheme();
    _checkLanguage();
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
            return ShadToaster(child: child!);
          },
        );
      },
    );
  }
}

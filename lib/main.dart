import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/app-local.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/localization/localization.dart';
import 'package:pos/utils/drawer.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/go-router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  initLocalization();
  await dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    localization.onTranslatedLanguage = (_) {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.light,
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
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: GoogleFonts.merriweather().fontFamily,
            ),
          ),
          routerConfig: goRouter,
        );
      },
    );
  }
}

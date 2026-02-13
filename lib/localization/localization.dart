import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/app-local.dart';

final FlutterLocalization localization = FlutterLocalization.instance;

void initLocalization() {
  localization.init(
    mapLocales: [
      const MapLocale('en', AppLocale.EN),
      const MapLocale('mm', AppLocale.MM),
    ],
    initLanguageCode: 'en',
  );
}

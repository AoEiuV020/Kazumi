import 'dart:io';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:kazumi/utils/storage.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  Box setting = GStorage.setting;

  @override
  Widget build(BuildContext context) {
    dynamic color;
    dynamic defaultThemeColor =
        setting.get(SettingBoxKey.themeColor, defaultValue: 'default');
    if (defaultThemeColor == 'default') {
      color = Colors.green;
    } else {
      color = Color(int.parse(defaultThemeColor, radix: 16));
    }
    bool oledEnhance =
        setting.get(SettingBoxKey.oledEnhance, defaultValue: false);
    var defaultDarkTheme = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: color);
    var oledDarkTheme = Utils.oledDarkTheme(defaultDarkTheme);
    var app = AdaptiveTheme(
      light: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: color),
      dark: oledEnhance ? oledDarkTheme : defaultDarkTheme,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp.router(
        title: "Kazumi",
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale.fromSubtags(
              languageCode: 'zh', scriptCode: 'Hans', countryCode: "CN")
        ],
        locale: const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hans', countryCode: "CN"),
        theme: theme,
        darkTheme: darkTheme,
        routerConfig: Modular.routerConfig,
        builder: FlutterSmartDialog.init(),
      ),
    );
    Modular.setObservers([FlutterSmartDialog.observer]);

    // 强制设置高帧率
    if (Platform.isAndroid) {
      try {
        late List modes;
        FlutterDisplayMode.supported.then((value) {
          modes = value;
          var storageDisplay = setting.get(SettingBoxKey.displayMode);
          DisplayMode f = DisplayMode.auto;
          if (storageDisplay != null) {
            f = modes.firstWhere((e) => e.toString() == storageDisplay);
          }
          DisplayMode preferred = modes.toList().firstWhere((el) => el == f);
          FlutterDisplayMode.setPreferredMode(preferred);
        });
      } catch (e) {
        debugPrint('高帧率设置失败 ${e.toString()}');
      }
    }

    return app;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/locale.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/router/route_map.dart';
import 'package:flutter_template/utils/provider.dart';
import 'package:flutter_template/utils/sputils.dart';
import '../core/utils/toast.dart';

//默认App的启动
class DefaultApp {
  //运行app
  static void run() {
    WidgetsFlutterBinding.ensureInitialized();
    initFirst().then((value) => runApp(Store.init(ToastUtils.init(MyApp()))));
    initApp();
  }

  /// 必须要优先初始化的内容
  static Future<void> initFirst() async {
    await SPUtils.init();
    await LocaleUtils.init();
  }

  /// 程序初始化操作
  static void initApp() {
    XHttp.init();
  }
}

final localProvider = StateNotifierProvider<LocaleModel, Locale?>((ref) {
  return LocaleModel(SPUtils.getLocale());
});

final appthemeProvider = StateNotifierProvider<AppTheme, dynamic>((ref) {
  return AppTheme(AppThemeClass(getDefaultTheme(), getDefaultBrightness()));
});

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appthemeProvider);
    final local = ref.watch(localProvider);

    return MaterialApp(
      title: 'Flutter Project',
      theme: ThemeData(
        brightness: appTheme.brightness,
        primarySwatch: appTheme.themeColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(appTheme.themeColor),
          ),
        ),
      ),
      routes: RouteMap.routers,
      locale: local,
      supportedLocales: I18n.delegate.supportedLocales,
      localizationsDelegates: [
        I18n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (Locale? _locale, Iterable<Locale> supportedLocales) {
        if (local != null) {
          //如果已经选定语言，则不跟随系统
          return ref.read(localProvider.notifier).getLocale();
        } else {
          //跟随系统
          Locale? systemLocale = LocaleUtils.getSystemLocale();
          if (I18n.delegate.isSupported(systemLocale)) {
            return systemLocale;
          }
          return supportedLocales.first;
        }
      },
    );
  }
}

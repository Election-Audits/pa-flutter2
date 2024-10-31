import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'sputils.dart';

final appStatusProvider = StateNotifierProvider<AppTabIndex, int>((ref) {
  return AppTabIndex(TAB_HOME_INDEX);
});

final userProfileProvider = StateNotifierProvider<UserProfile, String?>((ref) {
  return UserProfile(SPUtils.getNickName());
});

//状态管理
class Store {
  Store._internal();

  //全局初始化
  static init(Widget child) {
    //多个Provider
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(
    //         create: (_) => AppTheme(getDefaultTheme(), getDefaultBrightness())),
    //     ChangeNotifierProvider.value(value: LocaleModel(SPUtils.getLocale())),
    //     ChangeNotifierProvider.value(value: UserProfile(SPUtils.getNickName())),
    //     ChangeNotifierProvider.value(value: AppStatus(TAB_HOME_INDEX)),
    //   ],
    //   child: child,
    // );
    return ProviderScope(child: child);
  }

  //获取值 of(context)  这个会引起页面的整体刷新，如果全局是页面级别的
  // static T value<T>(BuildContext context, {bool listen = false}) {
  //   // return Provider.of<T>(context, listen: listen);
  //   // return Provider.of<T>(context);
  // }

  //获取值 of(context)  这个会引起页面的整体刷新，如果全局是页面级别的
  // static T of<T>(BuildContext context, {bool listen = true}) {
  //   return provider.Provider.of<T>(context, listen: listen);
  // }

  // 不会引起页面的刷新，只刷新了 Consumer 的部分，极大地缩小你的控件刷新范围
  // static Consumer connect<T>({required builder, child}) {
  //   return Consumer<T>(builder: builder, child: child);
  // }
}

MaterialColor getDefaultTheme() {
  return AppTheme.materialColors[SPUtils.getThemeIndex()!];
}

Brightness getDefaultBrightness() {
  return SPUtils.getBrightness();
}

class AppThemeClass {
  MaterialColor themeColor;

  Brightness brightness;

  AppThemeClass(this.themeColor, this.brightness);
}

///主题
class AppTheme extends StateNotifier<AppThemeClass> {
  static final List<MaterialColor> materialColors = [
    Colors.blue,
    Colors.lightBlue,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.grey,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.lime
  ];

  MaterialColor _themeColor;

  Brightness _brightness;

  AppThemeClass appThemeClass;

  AppTheme(this.appThemeClass)
      : _themeColor = appThemeClass.themeColor,
        _brightness = appThemeClass.brightness,
        super(appThemeClass);

  void setColor(MaterialColor color) {
    _themeColor = color;
  }

  void changeColor(int index) {
    _themeColor = materialColors[index];
    SPUtils.saveThemeIndex(index);
    state = AppThemeClass(_themeColor, _brightness);
  }

  void setBrightness(bool isLight) {}

  void changeBrightness(bool isDark) {
    _brightness = isDark ? Brightness.dark : Brightness.light;
    SPUtils.saveBrightness(isDark);
    state = AppThemeClass(_themeColor, _brightness);
  }

  get themeColor => _themeColor;

  get brightness => _brightness;
}

///跟随系统
const String LOCALE_FOLLOW_SYSTEM = "auto";

///语言
class LocaleModel extends StateNotifier<Locale?> {
  // 获取当前用户的APP语言配置Locale类，如果为null，则语言跟随系统语言
  Locale? getLocale() {
    if (_locale == LOCALE_FOLLOW_SYSTEM) return null;
    var t = _locale.split("_");
    return Locale(t[0], t[1]);
  }

  String _locale = LOCALE_FOLLOW_SYSTEM;

  LocaleModel(this._locale) : super(_locale == "auto" ? null : Locale(_locale.split("_")[0], _locale.split("_")[1]));

  // 获取当前Locale的字符串表示
  String get locale => _locale;

  // 用户改变APP语言后，通知依赖项更新，新语言会立即生效
  set locale(String locale) {
    if (_locale != locale) {
      _locale = locale;
      I18n.locale = getLocale();
      SPUtils.saveLocale(_locale);
      state = getLocale();
    }
  }
}

///用户账户信息
class UserProfile extends StateNotifier<String?> {
  String? nickName;

  UserProfile(this.nickName) : super(nickName ?? "");

  void changeNickName(String nickName) {
    state = nickName;
    SPUtils.saveNickName(nickName);
  }
}

///主页
const int TAB_HOME_INDEX = 0;

///分类
const int TAB_CATEGORY_INDEX = 1;

///活动
const int TAB_ACTIVITY_INDEX = 2;

///消息
const int TAB_MESSAGE_INDEX = 3;

///我的
const int TAB_PROFILE_INDEX = 4;

///应用状态
class AppTabIndex extends StateNotifier<int> {
  int _tabIndex;
  AppTabIndex(this._tabIndex) : super(_tabIndex);

  int get tabIndex => _tabIndex;

  void change(int index) {
    state = index;
  }
}

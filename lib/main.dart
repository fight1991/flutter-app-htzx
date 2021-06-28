import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ydsd/channel/app_event_channel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'adapter/binding_adapter.dart';
import 'common/index.dart';
import 'ui/index.dart';
import 'i18n/index.dart';
import 'notifiers/index.dart';
void main() {
  Global.init();
  InnerWidgetsFlutterBinding.ensureInitialized()
    ..attachRootWidget(new App())
    ..scheduleWarmUpFrame();
}

class App extends StatelessWidget {
  bool _equal(Locale src, Locale dest, bool languageCode, bool countryCode,
      bool scriptCode) {
    if (src == null && dest == null) {
      return true;
    }
    if (src != null && dest != null) {
      if (languageCode && src.languageCode != dest.languageCode) {
        return false;
      }
      if (countryCode && src.countryCode != dest.countryCode) {
        return false;
      }
      if (scriptCode && src.scriptCode != dest.scriptCode) {
        return false;
      }
      return true;
    }
    return false;
  }

  Locale _localeCallback(
      localNotifier, Locale locale, Iterable<Locale> supported) {
    if (localNotifier.getLocale() != null) {
      return localNotifier.getLocale();
    } else {
      var allSameLocale = supported
          .where((item) => _equal(item, locale, true, true, false))
          .toList();

      if (allSameLocale.length >= 1) {
        return allSameLocale[0];
      }

      var countrySameLocale = supported
          .where((item) => _equal(item, locale, true, true, false))
          .toList();
      if (countrySameLocale.length == 1) {
        return countrySameLocale[0];
      }

      var languageSameLocale = supported
          .where((item) => _equal(item, locale, true, false, false))
          .toList();
      if (languageSameLocale.length == 1) {
        return languageSameLocale[0];
      }

      return Locale('zh', 'CN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeChangeNotifier()),
        ChangeNotifierProvider.value(value: LocaleChangeNotifier()),
        ChangeNotifierProvider.value(value: ProfileChangeNotifier()),
      ],
      child: Consumer2<ThemeChangeNotifier, LocaleChangeNotifier>(
        builder: (buildContext, themeNotifier, localNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: !Global.isRelease,
            onGenerateTitle: (BuildContext context) {
              return "小蛮腰";
            },
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Color(0xFFFFFFFF),
              brightness: Brightness.light,
              appBarTheme: AppBarTheme(
                elevation: 0,
                color: Colors.white,
                iconTheme: IconThemeData(color: Color(0xFF333333)),
                textTheme: TextTheme(
                  title: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            locale: localNotifier.getLocale(),
            supportedLocales: [
              const Locale("en", "US"),
              const Locale("zh", "CN"),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              AppLocalizationsDelegate(),
            ],
            localeResolutionCallback: (locale, supportedLocales) =>
                _localeCallback(localNotifier, locale, supportedLocales),
            home: SplashPage(),
            navigatorKey: Global.navigatorKey,
            routes: {
              PageName.splash: (context) => SplashPage(),
              PageName.passwordLogin: (context) => PasswordLoginPage(),
              PageName.changePassword: (context) => ChangePasswordPage(),
              PageName.main: (context) => HomePage(),
              PageName.minePage: (context) => MinePagePage(),
              PageName.feedback: (context) => FeedbackPage(),
              PageName.about: (context) => AboutPage(),
              PageName.orderList: (context) => OrderListPage(),
              PageName.orderDetail: (context) => OrderDetailPage(),
              PageName.orderSearch: (context) => OrderSearchPage(),
              PageName.scanPage: (context) => ScanPage(),
              PageName.bnScanPage: (context) => BNScanPage(),
              PageName.inputMoney: (context) => InputMoneyPage(),
              PageName.collectionSuccess: (context) => CollectionSuccessPage(),
              PageName.collectionError: (context) => CollectionErrorPage(),
              PageName.collectionWaiting: (context) => CollectionWaittingPage(),
              PageName.webview: (context) => WebViewPage(),
              PageName.test: (context) => TestPage(),
              PageName.userInfo: (context) => UserInfoPage(),
              PageName.bNDeviceManagerPagePage: (context) => BNDeviceManagerPage(),
            },
          );
        },
      ),
    );
  }
}

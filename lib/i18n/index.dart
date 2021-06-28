import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class L {
  static Future<L> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return new L();
    });
  }

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L);
  }

  String get title => Intl.message('App Title', name: 'title');

  String get navLabelHome => Intl.message('Home', name: 'navLabelHome');
  String get navLabelBrowse => Intl.message('Browse', name: 'navLabelBrowse');
  String get navLabelSearch => Intl.message('Search', name: 'navLabelSearch');
  String get navLabelMine => Intl.message('Mine', name: 'navLabelMine');

  String get loading => Intl.message('loading', name: 'loading');
  String get retry => Intl.message('retry', name: 'retry');
  String get clickForRetry => Intl.message('click for retry', name: 'clickForRetry');
  String get dataEmpty => Intl.message('data is empty', name: 'dataEmpty');
  String get nextPageLoading => Intl.message('loading', name: 'nextPageLoading');

  String get apiHttpCancel => Intl.message('Request Cancel', name: 'apiHttpCancel');
  String get apiHttpError4xx => Intl.message('Request No Found', name: 'apiHttpError4xx');
  String get apiHttpError5xx => Intl.message('Server Has Error', name: 'apiHttpError5xx');
  String get apiHttpError => Intl.message('Network Has Error', name: 'apiHttpError');
  String get apiArgumentError => Intl.message('Api Argument Error', name: 'apiArgumentError');
  String get apiJsonError => Intl.message('Serivce Json Error', name: 'apiJsonError');
  String get apiServiceError => Intl.message('Serivce Error', name: 'apiServiceError');
  String get apiServiceSuccess => Intl.message('Serivce Error', name: 'apiServiceError');

  String get homeTitle => Intl.message('Home', name: 'homeTitle');

  String get mineTitle => navLabelMine;
  String get mineUserNone => Intl.message('Anonymous', name: 'mineUserNone');
  String get mineLabelStar => Intl.message('My Star', name: 'mineLabelStar');
  String get mineLabelHistory => Intl.message('My History', name: 'mineLabelHistory');
  String get mineLabelNightmode => Intl.message('Night Mode', name: 'mineLabelNightmode');
  String get mineLabelLanguage => Intl.message('Language', name: 'mineLabelLanguage');
  String get mineLabelSetting => Intl.message('Setting', name: 'mineLabelSetting');

  String get languageTitle => Intl.message('Language', name: 'languageTitle');

  String get themeTitle => Intl.message('Theme', name: 'themeTitle');

  String get videoPlayTitle => Intl.message('VideoPlay', name: 'videoPlayTitle');
  String get videoPlayLockTooltip => Intl.message('Lock or unlock video controls', name: 'videoPlayLockTooltip');

  String get webviewTitle => Intl.message(title, name: 'webviewTitle');

  String get settingTitle => Intl.message('Setting', name: 'settingTitle');
  String get settingLabelTheme => Intl.message('Theme', name: 'settingLabelTheme');
  String get settingLabelRecommend => Intl.message('Recommend', name: 'settingLabelRecommend');
  String get settingLabelAbout => Intl.message('About', name: 'settingLabelAbout');

  String get aboutTitle => Intl.message('About', name: 'aboutTitle');
}

//Locale代理类
class AppLocalizationsDelegate extends LocalizationsDelegate<L> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<L> load(Locale locale) => L.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

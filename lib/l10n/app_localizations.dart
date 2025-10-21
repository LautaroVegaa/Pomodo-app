import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pomodō'**
  String get appTitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get shortBreak;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get longBreak;

  /// No description provided for @workSession.
  ///
  /// In en, this message translates to:
  /// **'Focus Time'**
  String get workSession;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get wellDone;

  /// No description provided for @motivationalQuote.
  ///
  /// In en, this message translates to:
  /// **'Stay focused, you got this!'**
  String get motivationalQuote;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcome(Object name);

  /// No description provided for @pomodoroTechnique.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro technique for students'**
  String get pomodoroTechnique;

  /// No description provided for @customizePomodoro.
  ///
  /// In en, this message translates to:
  /// **'Customize Pomodoro'**
  String get customizePomodoro;

  /// No description provided for @workDuration.
  ///
  /// In en, this message translates to:
  /// **'Work duration'**
  String get workDuration;

  /// No description provided for @breakDuration.
  ///
  /// In en, this message translates to:
  /// **'Break duration'**
  String get breakDuration;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @breakLabel.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakLabel;

  /// No description provided for @keepFocus.
  ///
  /// In en, this message translates to:
  /// **'Stay focused!'**
  String get keepFocus;

  /// No description provided for @defaultMotivation.
  ///
  /// In en, this message translates to:
  /// **'Each completed cycle brings you closer to your study goals.'**
  String get defaultMotivation;

  /// No description provided for @viewMoreStats.
  ///
  /// In en, this message translates to:
  /// **'View more statistics'**
  String get viewMoreStats;

  /// No description provided for @moreStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'More statistics'**
  String get moreStatsTitle;

  /// No description provided for @historyAndAverages.
  ///
  /// In en, this message translates to:
  /// **'History and Averages'**
  String get historyAndAverages;

  /// No description provided for @weeklyFocusProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly focus progress'**
  String get weeklyFocusProgress;

  /// No description provided for @bestDaySummary.
  ///
  /// In en, this message translates to:
  /// **'Your best day was {day} ({minutes} min).'**
  String bestDaySummary(Object day, Object minutes);

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet.'**
  String get noDataYet;

  /// No description provided for @weeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'Weekly average: {minutes} min.'**
  String weeklyAverage(Object minutes);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutesLabel;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minutesShort;

  /// No description provided for @focus1.
  ///
  /// In en, this message translates to:
  /// **'No one will do it for you. Do it now or keep dreaming about it.'**
  String get focus1;

  /// No description provided for @focus2.
  ///
  /// In en, this message translates to:
  /// **'Don’t get distracted: every time you do, you choose to delay the life you want.'**
  String get focus2;

  /// No description provided for @focus3.
  ///
  /// In en, this message translates to:
  /// **'While you hesitate, someone else is moving forward.'**
  String get focus3;

  /// No description provided for @focus4.
  ///
  /// In en, this message translates to:
  /// **'The time you lose never comes back.'**
  String get focus4;

  /// No description provided for @focus5.
  ///
  /// In en, this message translates to:
  /// **'You’re not tired. You’re avoiding growth.'**
  String get focus5;

  /// No description provided for @focus6.
  ///
  /// In en, this message translates to:
  /// **'Stop making excuses, start making results.'**
  String get focus6;

  /// No description provided for @focus7.
  ///
  /// In en, this message translates to:
  /// **'Each Pomodoro you finish is a promise kept to yourself. Breaking it hurts more.'**
  String get focus7;

  /// No description provided for @focus8.
  ///
  /// In en, this message translates to:
  /// **'You wanted different results, but keep doing the same.'**
  String get focus8;

  /// No description provided for @focus9.
  ///
  /// In en, this message translates to:
  /// **'You are not your potential, you are what you do every day.'**
  String get focus9;

  /// No description provided for @focus10.
  ///
  /// In en, this message translates to:
  /// **'Today’s sacrifice is tomorrow’s freedom.'**
  String get focus10;

  /// No description provided for @focus11.
  ///
  /// In en, this message translates to:
  /// **'Your future depends on what you do in the next 25 minutes, not tomorrow.'**
  String get focus11;

  /// No description provided for @focus12.
  ///
  /// In en, this message translates to:
  /// **'If you can’t handle the effort, you’ll have to handle the consequences.'**
  String get focus12;

  /// No description provided for @focus13.
  ///
  /// In en, this message translates to:
  /// **'Your goals aren’t waiting; someone else is taking them.'**
  String get focus13;

  /// No description provided for @focus14.
  ///
  /// In en, this message translates to:
  /// **'Every interruption is a small surrender.'**
  String get focus14;

  /// No description provided for @focus15.
  ///
  /// In en, this message translates to:
  /// **'You don’t lack time, you lack decision.'**
  String get focus15;

  /// No description provided for @break1.
  ///
  /// In en, this message translates to:
  /// **'Breathe. You’re not stopping, you’re recharging.'**
  String get break1;

  /// No description provided for @break2.
  ///
  /// In en, this message translates to:
  /// **'Take this moment to recover energy, not to give up.'**
  String get break2;

  /// No description provided for @break3.
  ///
  /// In en, this message translates to:
  /// **'Resting is also part of the work if you know how to return.'**
  String get break3;

  /// No description provided for @break4.
  ///
  /// In en, this message translates to:
  /// **'Let go for a moment, but don’t forget why you started.'**
  String get break4;

  /// No description provided for @break5.
  ///
  /// In en, this message translates to:
  /// **'This break is not a reward or punishment, it’s strategy.'**
  String get break5;

  /// No description provided for @break6.
  ///
  /// In en, this message translates to:
  /// **'Relax your body but keep your intention alive.'**
  String get break6;

  /// No description provided for @break7.
  ///
  /// In en, this message translates to:
  /// **'A short break doesn’t erase progress, it strengthens it.'**
  String get break7;

  /// No description provided for @break8.
  ///
  /// In en, this message translates to:
  /// **'Your mind needs a pause, not abandonment.'**
  String get break8;

  /// No description provided for @break9.
  ///
  /// In en, this message translates to:
  /// **'Use this break to think about what’s coming, not what’s missing.'**
  String get break9;

  /// No description provided for @break10.
  ///
  /// In en, this message translates to:
  /// **'Relax, but remember the clock will run again soon.'**
  String get break10;

  /// No description provided for @break11.
  ///
  /// In en, this message translates to:
  /// **'Self-care is also discipline.'**
  String get break11;

  /// No description provided for @break12.
  ///
  /// In en, this message translates to:
  /// **'This moment is yours — use it to return clearer.'**
  String get break12;

  /// No description provided for @break13.
  ///
  /// In en, this message translates to:
  /// **'It’s not about stopping, it’s about coming back better.'**
  String get break13;

  /// No description provided for @break14.
  ///
  /// In en, this message translates to:
  /// **'A good rest sustains good performance.'**
  String get break14;

  /// No description provided for @break15.
  ///
  /// In en, this message translates to:
  /// **'Breathe deeply. Consistency is also trained through rest.'**
  String get break15;

  /// No description provided for @notificationFocusEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus session finished! 🔔'**
  String get notificationFocusEndTitle;

  /// No description provided for @notificationFocusEndBody.
  ///
  /// In en, this message translates to:
  /// **'Take a short or long break and recharge your energy.'**
  String get notificationFocusEndBody;

  /// No description provided for @notificationBreakEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Break finished! 💪'**
  String get notificationBreakEndTitle;

  /// No description provided for @notificationBreakEndBody.
  ///
  /// In en, this message translates to:
  /// **'Time to get back to focus. Let’s go!'**
  String get notificationBreakEndBody;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

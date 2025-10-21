// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pomodō';

  @override
  String get start => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get shortBreak => 'Short Break';

  @override
  String get longBreak => 'Long Break';

  @override
  String get workSession => 'Focus Time';

  @override
  String get wellDone => 'Well done!';

  @override
  String get motivationalQuote => 'Stay focused, you got this!';

  @override
  String welcome(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get pomodoroTechnique => 'Pomodoro technique for students';

  @override
  String get customizePomodoro => 'Customize Pomodoro';

  @override
  String get workDuration => 'Work duration';

  @override
  String get breakDuration => 'Break duration';

  @override
  String get minutes => 'minutes';

  @override
  String get work => 'Work';

  @override
  String get breakLabel => 'Break';

  @override
  String get keepFocus => 'Stay focused!';

  @override
  String get defaultMotivation => 'Each completed cycle brings you closer to your study goals.';

  @override
  String get viewMoreStats => 'View more statistics';

  @override
  String get moreStatsTitle => 'More statistics';

  @override
  String get historyAndAverages => 'History and Averages';

  @override
  String get weeklyFocusProgress => 'Weekly focus progress';

  @override
  String bestDaySummary(Object day, Object minutes) {
    return 'Your best day was $day ($minutes min).';
  }

  @override
  String get noDataYet => 'No data yet.';

  @override
  String weeklyAverage(Object minutes) {
    return 'Weekly average: $minutes min.';
  }

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get sessions => 'Sessions';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get minutesShort => 'Min';

  @override
  String get focus1 => 'No one will do it for you. Do it now or keep dreaming about it.';

  @override
  String get focus2 => 'Don’t get distracted: every time you do, you choose to delay the life you want.';

  @override
  String get focus3 => 'While you hesitate, someone else is moving forward.';

  @override
  String get focus4 => 'The time you lose never comes back.';

  @override
  String get focus5 => 'You’re not tired. You’re avoiding growth.';

  @override
  String get focus6 => 'Stop making excuses, start making results.';

  @override
  String get focus7 => 'Each Pomodoro you finish is a promise kept to yourself. Breaking it hurts more.';

  @override
  String get focus8 => 'You wanted different results, but keep doing the same.';

  @override
  String get focus9 => 'You are not your potential, you are what you do every day.';

  @override
  String get focus10 => 'Today’s sacrifice is tomorrow’s freedom.';

  @override
  String get focus11 => 'Your future depends on what you do in the next 25 minutes, not tomorrow.';

  @override
  String get focus12 => 'If you can’t handle the effort, you’ll have to handle the consequences.';

  @override
  String get focus13 => 'Your goals aren’t waiting; someone else is taking them.';

  @override
  String get focus14 => 'Every interruption is a small surrender.';

  @override
  String get focus15 => 'You don’t lack time, you lack decision.';

  @override
  String get break1 => 'Breathe. You’re not stopping, you’re recharging.';

  @override
  String get break2 => 'Take this moment to recover energy, not to give up.';

  @override
  String get break3 => 'Resting is also part of the work if you know how to return.';

  @override
  String get break4 => 'Let go for a moment, but don’t forget why you started.';

  @override
  String get break5 => 'This break is not a reward or punishment, it’s strategy.';

  @override
  String get break6 => 'Relax your body but keep your intention alive.';

  @override
  String get break7 => 'A short break doesn’t erase progress, it strengthens it.';

  @override
  String get break8 => 'Your mind needs a pause, not abandonment.';

  @override
  String get break9 => 'Use this break to think about what’s coming, not what’s missing.';

  @override
  String get break10 => 'Relax, but remember the clock will run again soon.';

  @override
  String get break11 => 'Self-care is also discipline.';

  @override
  String get break12 => 'This moment is yours — use it to return clearer.';

  @override
  String get break13 => 'It’s not about stopping, it’s about coming back better.';

  @override
  String get break14 => 'A good rest sustains good performance.';

  @override
  String get break15 => 'Breathe deeply. Consistency is also trained through rest.';

  @override
  String get notificationFocusEndTitle => 'Focus session finished! 🔔';

  @override
  String get notificationFocusEndBody => 'Take a short or long break and recharge your energy.';

  @override
  String get notificationBreakEndTitle => 'Break finished! 💪';

  @override
  String get notificationBreakEndBody => 'Time to get back to focus. Let’s go!';
}

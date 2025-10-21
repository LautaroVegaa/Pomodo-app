// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pomodō';

  @override
  String get start => 'Iniciar';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get shortBreak => 'Descanso corto';

  @override
  String get longBreak => 'Descanso largo';

  @override
  String get workSession => 'Tiempo de concentración';

  @override
  String get wellDone => '¡Bien hecho!';

  @override
  String get motivationalQuote => 'Concentrate, vos podés!';

  @override
  String welcome(Object name) {
    return 'Bienvenido, $name';
  }

  @override
  String get pomodoroTechnique => 'Técnica Pomodoro para estudiantes';

  @override
  String get customizePomodoro => 'Personalizar Pomodoro';

  @override
  String get workDuration => 'Duración del trabajo';

  @override
  String get breakDuration => 'Duración del descanso';

  @override
  String get minutes => 'minutos';

  @override
  String get work => 'Trabajo';

  @override
  String get breakLabel => 'Descanso';

  @override
  String get keepFocus => '¡Mantén el enfoque!';

  @override
  String get defaultMotivation => 'Cada ciclo completado te acerca más a tus objetivos de estudio.';

  @override
  String get viewMoreStats => 'Ver más estadísticas';

  @override
  String get moreStatsTitle => 'Más estadísticas';

  @override
  String get historyAndAverages => 'Historial y Promedios';

  @override
  String get weeklyFocusProgress => 'Progreso de concentración semanal';

  @override
  String bestDaySummary(Object day, Object minutes) {
    return 'Tu mejor día fue el $day ($minutes min).';
  }

  @override
  String get noDataYet => 'Aún no hay datos suficientes.';

  @override
  String weeklyAverage(Object minutes) {
    return 'Promedio semanal: $minutes min.';
  }

  @override
  String get today => 'Hoy';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get sessions => 'Sesiones';

  @override
  String get minutesLabel => 'Minutos';

  @override
  String get dailyAverage => 'Promedio diario';

  @override
  String get minutesShort => 'Min';

  @override
  String get focus1 => 'Nadie lo va a hacer por vos. O lo hacés ahora, o seguís soñando con hacerlo algún día.';

  @override
  String get focus2 => 'No te distraigas: cada vez que lo hacés, elegís postergar la vida que querés.';

  @override
  String get focus3 => 'Mientras dudás, alguien más está avanzando.';

  @override
  String get focus4 => 'El tiempo que perdés no vuelve. Nunca.';

  @override
  String get focus5 => 'No estás cansado. Estás evitando crecer.';

  @override
  String get focus6 => 'No busques excusas, buscá resultados.';

  @override
  String get focus7 => 'Cada Pomodoro que terminás es una promesa cumplida con vos mismo. Romperla duele más.';

  @override
  String get focus8 => 'Querías resultados distintos, pero seguís haciendo lo mismo.';

  @override
  String get focus9 => 'No sos tu potencial, sos lo que hacés cada día.';

  @override
  String get focus10 => 'El sacrificio de hoy es la libertad de mañana.';

  @override
  String get focus11 => 'Tu futuro depende de lo que hagas en los próximos 25 minutos, no mañana.';

  @override
  String get focus12 => 'Si no soportás el esfuerzo, vas a tener que soportar las consecuencias.';

  @override
  String get focus13 => 'Tus metas no te están esperando, se las está llevando otro que sí trabaja.';

  @override
  String get focus14 => 'Cada interrupción es una forma de rendirte un poco.';

  @override
  String get focus15 => 'No te falta tiempo. Te falta decisión.';

  @override
  String get break1 => 'Respirá. No estás frenando, estás recargando.';

  @override
  String get break2 => 'Tomate este momento para recuperar energía, no para rendirte.';

  @override
  String get break3 => 'Descansar también es parte del trabajo, si sabés volver.';

  @override
  String get break4 => 'Soltá un poco, pero no olvides por qué empezaste.';

  @override
  String get break5 => 'Este descanso no es premio ni castigo, es estrategia.';

  @override
  String get break6 => 'Aflojá el cuerpo, pero mantené viva la intención.';

  @override
  String get break7 => 'Un respiro no borra el progreso, lo refuerza.';

  @override
  String get break8 => 'Tu mente necesita pausa, no abandono.';

  @override
  String get break9 => 'Usá este descanso para pensar en lo que viene, no en lo que falta.';

  @override
  String get break10 => 'Relajate, pero sabé que el reloj vuelve a correr pronto.';

  @override
  String get break11 => 'Cuidarte también es disciplina.';

  @override
  String get break12 => 'Este momento es tuyo, aprovechalo para volver más claro.';

  @override
  String get break13 => 'No se trata de parar, sino de volver mejor.';

  @override
  String get break14 => 'Un buen descanso sostiene un buen rendimiento.';

  @override
  String get break15 => 'Respirá profundo. La constancia también se entrena descansando.';

  @override
  String get notificationFocusEndTitle => '¡Fin del Enfoque! 🔔';

  @override
  String get notificationFocusEndBody => 'Tómate un descanso y recarga energías.';

  @override
  String get notificationBreakEndTitle => '¡Fin del Descanso! 💪';

  @override
  String get notificationBreakEndBody => 'Es hora de volver al enfoque.';
}

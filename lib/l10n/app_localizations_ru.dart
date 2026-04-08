// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'NEON PULSE';

  @override
  String get taglineOneTap => 'Одно касание. Чистый скилл.';

  @override
  String get menuPlay => 'ИГРАТЬ';

  @override
  String get menuPlaySubtitle => 'Мгновенный забег — бей свой рекорд';

  @override
  String get menuLeaderboard => 'РЕЙТИНГ';

  @override
  String get menuLeaderboardSubtitle =>
      'Сейчас локально • глобал и друзья с Firebase';

  @override
  String get menuVersus => 'ВЫЗОВЫ';

  @override
  String get menuVersusSubtitle => 'Соревнуйся с другом — окно времени';

  @override
  String get menuProfile => 'ПРОФИЛЬ';

  @override
  String get menuProfileSubtitle => 'Статистика • Достижения • Карточка';

  @override
  String get menuHelp => 'Помощь';

  @override
  String get helpDialogTitle => 'Как играть';

  @override
  String get helpDialogBody =>
      'NEON PULSE — игра на тайминг в одно касание. Неоновое кольцо сужается к центру — нажимайте, когда по радиусу кольца вы попадаете в нужную цветную зону.\n\n• Слишком рано (за зелёной зоной) или слишком поздно (чёрная дыра в центре) = MISS — забег заканчивается.\n• Зелёный OK +2, оранжевый GOOD +4, жёлтый COOL +6, красный PERFECT +8. Множитель цепочки (×2 → ×16) растёт только от подряд идущих PERFECT; любая другая зона сбрасывает цепочку.\n• На высоком счёте поле может смещаться — держите внимание на кольце.\n\nЗакройте окно и касайтесь экрана, чтобы играть.';

  @override
  String get menuFooterRankings =>
      'Рейтинг: сейчас локально • облако — в финале';

  @override
  String get splashGlobalCompetition => 'ГЛОБАЛЬНОЕ СОРЕВНОВАНИЕ';

  @override
  String get gameEndRunTooltip => 'Закончить забег';

  @override
  String get gameScoreX2 => 'СЧЁТ ×2';

  @override
  String gameStage(int stage, String seconds) {
    return 'Этап $stage · $seconds с';
  }

  @override
  String get gameRankRising => 'РЕЙТИНГ РАСТЁТ!';

  @override
  String get judgementOk => 'OK';

  @override
  String get judgementPerfect => 'PERFECT';

  @override
  String get judgementGood => 'GOOD';

  @override
  String get judgementCool => 'COOL';

  @override
  String get judgementMiss => 'MISS';

  @override
  String get resultsDefeat => 'ПОРАЖЕНИЕ';

  @override
  String get resultsRunOver => 'ЗАБЕГ ОКОНЧЕН';

  @override
  String get resultsFinalScore => 'ИТОГО ОЧКОВ';

  @override
  String get resultsRunNumber => 'ЗАБЕГ №';

  @override
  String get resultsAccuracy => 'ТОЧНОСТЬ';

  @override
  String resultsHits(int count) {
    return '$count попаданий';
  }

  @override
  String get resultsHitBreakdown => 'РАСКЛАД ПОПАДАНИЙ';

  @override
  String resultsBreakdown(int perfect, int cool, int good, int ok) {
    return 'PERFECT $perfect · COOL $cool · GOOD $good · OK $ok';
  }

  @override
  String get resultsBestCombo => 'ЛУЧШЕЕ КОМБО';

  @override
  String get resultsBestScore => 'ЛУЧШИЙ СЧЁТ';

  @override
  String get resultsNewBest => 'НОВЫЙ РЕКОРД';

  @override
  String get resultsRankEstimate => 'ОЦЕНКА МЕСТА';

  @override
  String get resultsPlayAgain => 'ЕЩЁ РАЗ';

  @override
  String get resultsShare => 'ПОДЕЛИТЬСЯ';

  @override
  String resultsShareSnackbar(int score) {
    return 'Я набрал $score в NEON PULSE!';
  }

  @override
  String get resultsMenu => 'МЕНЮ';

  @override
  String get leaderboardTitle => 'РЕЙТИНГ';

  @override
  String get leaderboardGlobalTab => 'ГЛОБАЛЬНЫЙ';

  @override
  String get leaderboardFriendsTab => 'ДРУЗЬЯ';

  @override
  String get leaderboardOfflineBanner =>
      'Офлайн: только ваши результаты на устройстве. Общий рейтинг — после Firebase.';

  @override
  String leaderboardOnlineUnavailable(String error) {
    return 'Глобальный рейтинг сейчас недоступен.\n$error';
  }

  @override
  String get leaderboardLoadError =>
      'Не удалось загрузить таблицу.\nПроверьте Firebase и правила RTDB.';

  @override
  String get leaderboardEmptyGlobal =>
      'Пока нет записей — сыграйте и улучшите лучший счёт.';

  @override
  String get leaderboardEmptyLocal =>
      'Сыграйте партию — здесь появится ваш лучший счёт.';

  @override
  String leaderboardErrorGeneric(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get leaderboardFriendsEmpty =>
      'Добавьте друзей по коду в Профиле — здесь будут ваши очки и их лучшие результаты.';

  @override
  String leaderboardComboLine(int combo) {
    return 'x$combo комбо';
  }

  @override
  String get leaderboardYouSuffix => ' (вы)';

  @override
  String get profileTitle => 'ПРОФИЛЬ';

  @override
  String get profileNameInTable => 'НИК';

  @override
  String get profileNameHint => 'Как тебя видят другие';

  @override
  String get profileSaveName => 'СОХРАНИТЬ';

  @override
  String get profileSaved => 'СОХРАНЕНО';

  @override
  String get profileOfflineFirebaseNote =>
      'Сейчас всё только на этом устройстве. Облако и общий рейтинг — когда поставите kFirebaseOnlineFeaturesEnabled = true и настроите Firebase.';

  @override
  String get profileYourFriendCode => 'ВАШ КОД ДРУГА';

  @override
  String get profileCopyCode => 'Копировать';

  @override
  String get profileCodeCopied => 'Код скопирован';

  @override
  String get profileFriendCodeHint =>
      'Передайте код другу — он введёт его ниже у себя.';

  @override
  String get profileAddFriend => 'ДОБАВИТЬ ДРУГА';

  @override
  String get profileFriendCodeFieldHint => '6-символьный код';

  @override
  String get profileOk => 'OK';

  @override
  String get profileFriends => 'ДРУЗЬЯ';

  @override
  String get profileFriendsEmpty => 'Пока никого — добавьте по коду.';

  @override
  String get profileBack => 'НАЗАД';

  @override
  String get profileFirebaseLaterNote =>
      'Код друга и список друзей появятся после включения Firebase (см. lib/src/config/online_config.dart).';

  @override
  String get profileLanguage => 'ЯЗЫК';

  @override
  String get profileLanguageRu => 'Русский';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get versusTitle => 'ВЫЗОВЫ';

  @override
  String get versusHistoryTitle => 'ИСТОРИЯ ВЫЗОВОВ';

  @override
  String get versusHistoryEmpty =>
      'История пока пуста.\nСоздайте вызов — он появится здесь после завершения.';

  @override
  String get versusHeadline => 'РЕЖИМ ВЫЗОВОВ';

  @override
  String get versusBody =>
      'Кинь другу вызов на 1, 6 или 24 часа.\nВнутри окна времени вы оба стараетесь набрать максимум — считается лучший забег каждого.\n\nПока идёт вызов, таймер будет виден в главном меню.';

  @override
  String get versusOpenChallenges => 'ОТКРЫТЬ ВЫЗОВЫ';

  @override
  String get versusBack => 'НАЗАД';

  @override
  String versusActiveTimer(String timeLeft) {
    return 'АКТИВНЫЙ ВЫЗОВ · $timeLeft';
  }

  @override
  String get versusHelpTitle => 'Что такое вызовы?';

  @override
  String get versusHelpBody =>
      'Ты выбираешь друга и длительность (1ч / 6ч / 24ч). В течение окна каждый делает попытки, и учитывается лучший результат каждого. Можно принять/отклонить вызов, а также смотреть историю.';

  @override
  String get challengesTitle => 'ВЫЗОВЫ';

  @override
  String get challengesNewTooltip => 'Новый вызов';

  @override
  String get challengesMakeChallenge => 'СДЕЛАТЬ ВЫЗОВ';

  @override
  String get challengesFirebaseDisabled =>
      'Вызовы между игроками включатся после Firebase.\n\nПоставьте kFirebaseOnlineFeaturesEnabled = true\nи выполните шаги из firebase/README.md';

  @override
  String get challengesEmpty =>
      'Пока нет вызовов.\nНажмите + чтобы отправить другу.';

  @override
  String challengeVersus(String from, String to) {
    return '$from vs $to';
  }

  @override
  String get challengeStatusPending => 'ОЖИДАЕТ';

  @override
  String get challengeStatusActive => 'ИДЁТ';

  @override
  String get challengeStatusFinishing => 'ФИНИШ';

  @override
  String get challengeStatusCompleted => 'ЗАВЕРШЁН';

  @override
  String get challengeStatusDeclined => 'ОТКЛОНЁН';

  @override
  String get challengeStatusCancelled => 'ОТМЕНЁН';

  @override
  String challengeEnds(String when) {
    return 'До: $when';
  }

  @override
  String get challengeAccept => 'ПРИНЯТЬ';

  @override
  String get challengeDecline => 'ОТКЛОНИТЬ';

  @override
  String get challengeCancel => 'ОТМЕНИТЬ';

  @override
  String get challengeRiskArm => 'РИСК ×1.25';

  @override
  String get challengeRiskDisarm => 'СБРОС РИСКА';

  @override
  String get challengeRiskHint =>
      'Риск: один раз на игрока — следующий забег может дать ×1.25 (0 остаётся 0, риск сгорает).';

  @override
  String get challengeRiskReady => 'ГОТОВ';

  @override
  String get challengeRiskUsed => 'РИСК ИСП.';

  @override
  String get createChallengeTitle => 'НОВЫЙ ВЫЗОВ';

  @override
  String get createChallengeFriend => 'ДРУГ';

  @override
  String get createChallengeNoFriends =>
      'Сначала добавьте хотя бы одного друга в Профиле.';

  @override
  String get createChallengeDuration => 'ДЛИТЕЛЬНОСТЬ';

  @override
  String get createChallengeSend => 'ОТПРАВИТЬ';

  @override
  String get createChallengeBusy => '...';

  @override
  String get createChallengeRuleHint =>
      'Правило: считается лучший один забег в окне. Risk round: один раз можно включить ×1.25 для следующего забега.';

  @override
  String get createChallengeCodeNotFound => 'Код не найден';

  @override
  String get createChallengeFailed => 'Не удалось создать вызов';

  @override
  String get createChallengeSent => 'Вызов отправлен';

  @override
  String snackIncomingChallenge(String name) {
    return 'Новый вызов от $name';
  }

  @override
  String get snackNameSaved => 'Имя сохранено';

  @override
  String get snackFriendAdded => 'Друг добавлен';

  @override
  String get friendErrorFirebaseDisabled =>
      'Друзья по коду — после включения Firebase (online_config.dart)';

  @override
  String get friendErrorNotReady => 'Нет сети или Firebase';

  @override
  String get friendErrorNoAccount => 'Нет аккаунта';

  @override
  String get friendErrorInvalidLength => 'Нужен ровно 6-символьный код';

  @override
  String get friendErrorNotFound => 'Код не найден';

  @override
  String get friendErrorBadData => 'Неверные данные';

  @override
  String get friendErrorOwnCode => 'Это ваш код';

  @override
  String get leaderboardNameYou => 'Вы';

  @override
  String get leaderboardNameNotInTable => 'Нет в таблице';

  @override
  String get defaultPlayerName => 'Игрок';

  @override
  String get durationHour1 => '1 час';

  @override
  String get durationHour6 => '6 часов';

  @override
  String get durationDay1 => '24 часа';

  @override
  String get settingsTitle => 'НАСТРОЙКИ';

  @override
  String get settingsAudioSection => 'ЗВУК';

  @override
  String get settingsSoundEnabled => 'Звуковые эффекты';

  @override
  String get settingsVolume => 'Громкость';

  @override
  String get settingsLanguage => 'Язык интерфейса';

  @override
  String get settingsLanguagePickerTitle => 'Выберите язык';

  @override
  String get profileOpenSettings => 'Настройки';
}

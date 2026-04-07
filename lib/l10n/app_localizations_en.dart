// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NEON PULSE';

  @override
  String get taglineOneTap => 'One tap. Pure skill.';

  @override
  String get menuPlay => 'PLAY';

  @override
  String get menuPlaySubtitle => 'Instant run — chase your best score';

  @override
  String get menuLeaderboard => 'LEADERBOARD';

  @override
  String get menuLeaderboardSubtitle =>
      'Local now • global & friends with Firebase';

  @override
  String get menuVersus => 'CHALLENGES';

  @override
  String get menuVersusSubtitle => 'Compete with a friend — timed window';

  @override
  String get menuProfile => 'PROFILE';

  @override
  String get menuProfileSubtitle => 'Stats • Achievements • Share card';

  @override
  String get menuHelp => 'Help';

  @override
  String get helpDialogTitle => 'How to play';

  @override
  String get helpDialogBody =>
      'NEON PULSE is a one-tap timing game. A neon ring shrinks toward the center — tap when your timing matches the colored zones.\n\n• Too early (outside the green band) or too late (center black hole) = MISS — the run ends.\n• Green OK +2, orange GOOD +4, yellow COOL +6, red PERFECT +8. PERFECT chain multipliers (×2 → ×16) grow only on consecutive PERFECTs; any other zone resets the chain.\n• At higher scores the field can drift — keep your eyes on the ring.\n\nClose this dialog and tap to play.';

  @override
  String get menuFooterRankings =>
      'Rankings: local now • cloud in the final build';

  @override
  String get splashGlobalCompetition => 'GLOBAL COMPETITION';

  @override
  String get gameEndRunTooltip => 'End run';

  @override
  String get gameScoreX2 => 'SCORE x2';

  @override
  String gameStage(int stage, String seconds) {
    return 'Stage $stage · ${seconds}s';
  }

  @override
  String get gameRankRising => 'RANK RISING!';

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
  String get resultsDefeat => 'DEFEAT';

  @override
  String get resultsRunOver => 'RUN OVER';

  @override
  String get resultsFinalScore => 'FINAL SCORE';

  @override
  String get resultsRunNumber => 'RUN #';

  @override
  String get resultsAccuracy => 'ACCURACY';

  @override
  String resultsHits(int count) {
    return '$count hits';
  }

  @override
  String get resultsHitBreakdown => 'HIT BREAKDOWN';

  @override
  String resultsBreakdown(int perfect, int cool, int good, int ok) {
    return 'PERFECT $perfect · COOL $cool · GOOD $good · OK $ok';
  }

  @override
  String get resultsBestCombo => 'BEST COMBO';

  @override
  String get resultsBestScore => 'BEST SCORE';

  @override
  String get resultsNewBest => 'NEW BEST';

  @override
  String get resultsRankEstimate => 'RANK ESTIMATE';

  @override
  String get resultsPlayAgain => 'PLAY AGAIN';

  @override
  String get resultsShare => 'SHARE';

  @override
  String resultsShareSnackbar(int score) {
    return 'I scored $score in NEON PULSE!';
  }

  @override
  String get resultsMenu => 'MENU';

  @override
  String get leaderboardTitle => 'LEADERBOARD';

  @override
  String get leaderboardGlobalTab => 'GLOBAL';

  @override
  String get leaderboardFriendsTab => 'FRIENDS';

  @override
  String get leaderboardOfflineBanner =>
      'Offline: only your scores on this device. Global board — after Firebase.';

  @override
  String leaderboardOnlineUnavailable(String error) {
    return 'Global leaderboard is unavailable right now.\n$error';
  }

  @override
  String get leaderboardLoadError =>
      'Could not load the table.\nCheck Firebase and RTDB rules.';

  @override
  String get leaderboardEmptyGlobal =>
      'No entries yet — play and improve your best score.';

  @override
  String get leaderboardEmptyLocal =>
      'Play a run — your best score will appear here.';

  @override
  String leaderboardErrorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get leaderboardFriendsEmpty =>
      'Add friends by code in Profile — your scores and their bests will show here.';

  @override
  String leaderboardComboLine(int combo) {
    return 'x$combo combo';
  }

  @override
  String get leaderboardYouSuffix => ' (you)';

  @override
  String get profileTitle => 'PROFILE';

  @override
  String get profileNameInTable => 'NICKNAME';

  @override
  String get profileNameHint => 'How others see you';

  @override
  String get profileSaveName => 'SAVE';

  @override
  String get profileSaved => 'SAVED';

  @override
  String get profileOfflineFirebaseNote =>
      'Everything is local on this device for now. Cloud and global board — when you set kFirebaseOnlineFeaturesEnabled = true and configure Firebase.';

  @override
  String get profileYourFriendCode => 'YOUR FRIEND CODE';

  @override
  String get profileCopyCode => 'Copy';

  @override
  String get profileCodeCopied => 'Code copied';

  @override
  String get profileFriendCodeHint =>
      'Share this code — your friend enters it below on their device.';

  @override
  String get profileAddFriend => 'ADD FRIEND';

  @override
  String get profileFriendCodeFieldHint => '6-character code';

  @override
  String get profileOk => 'OK';

  @override
  String get profileFriends => 'FRIENDS';

  @override
  String get profileFriendsEmpty => 'No one yet — add by code.';

  @override
  String get profileBack => 'BACK';

  @override
  String get profileFirebaseLaterNote =>
      'Friend code and list appear after Firebase is enabled (see lib/src/config/online_config.dart).';

  @override
  String get profileLanguage => 'LANGUAGE';

  @override
  String get profileLanguageRu => 'Русский';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get versusTitle => 'CHALLENGES';

  @override
  String get versusHeadline => 'CHALLENGE MODE';

  @override
  String get versusBody =>
      'Send a challenge to a friend for 1h, 6h, or 24h.\nWithin the time window, both of you play — only your best run counts.\n\nWhile a challenge is active, a countdown appears on the main menu.';

  @override
  String get versusOpenChallenges => 'OPEN CHALLENGES';

  @override
  String get versusBack => 'BACK';

  @override
  String versusActiveTimer(String timeLeft) {
    return 'ACTIVE CHALLENGE · $timeLeft';
  }

  @override
  String get versusHelpTitle => 'What are challenges?';

  @override
  String get versusHelpBody =>
      'Pick a friend and duration (1h / 6h / 24h). During the window you both attempt runs; the best score of each player counts. You can accept/decline and view history.';

  @override
  String get challengesTitle => 'CHALLENGES';

  @override
  String get challengesNewTooltip => 'New challenge';

  @override
  String get challengesFirebaseDisabled =>
      'Player vs player challenges unlock after Firebase.\n\nSet kFirebaseOnlineFeaturesEnabled = true\nand follow firebase/README.md';

  @override
  String get challengesEmpty =>
      'No challenges yet.\nTap + to send one to a friend.';

  @override
  String challengeVersus(String from, String to) {
    return '$from vs $to';
  }

  @override
  String get challengeStatusPending => 'PENDING';

  @override
  String get challengeStatusActive => 'ACTIVE';

  @override
  String get challengeStatusFinishing => 'FINISHING';

  @override
  String get challengeStatusCompleted => 'COMPLETED';

  @override
  String get challengeStatusDeclined => 'DECLINED';

  @override
  String get challengeStatusCancelled => 'CANCELLED';

  @override
  String challengeEnds(String when) {
    return 'Ends: $when';
  }

  @override
  String get challengeAccept => 'ACCEPT';

  @override
  String get challengeDecline => 'DECLINE';

  @override
  String get challengeCancel => 'CANCEL';

  @override
  String get challengeRiskArm => 'RISK ×1.25';

  @override
  String get challengeRiskDisarm => 'DISARM RISK';

  @override
  String get challengeRiskHint =>
      'Risk: once per player — next run can be ×1.25 (0 stays 0, risk is consumed).';

  @override
  String get challengeRiskReady => 'READY';

  @override
  String get challengeRiskUsed => 'RISK USED';

  @override
  String get createChallengeTitle => 'NEW CHALLENGE';

  @override
  String get createChallengeFriendCode => 'FRIEND CODE';

  @override
  String get createChallengeHint6 => '6 characters';

  @override
  String get createChallengeDuration => 'DURATION';

  @override
  String get createChallengeSend => 'SEND';

  @override
  String get createChallengeBusy => '...';

  @override
  String get createChallengeRuleHint =>
      'Rule: your best single run in the window counts. Risk round: once you can arm ×1.25 for the next run.';

  @override
  String get createChallengeCodeNotFound => 'Code not found';

  @override
  String get createChallengeFailed => 'Could not create challenge';

  @override
  String get createChallengeSent => 'Challenge sent';

  @override
  String get snackNameSaved => 'Name saved';

  @override
  String get snackFriendAdded => 'Friend added';

  @override
  String get friendErrorFirebaseDisabled =>
      'Friends by code — after Firebase is enabled (online_config.dart)';

  @override
  String get friendErrorNotReady => 'No network or Firebase';

  @override
  String get friendErrorNoAccount => 'No account';

  @override
  String get friendErrorInvalidLength => 'Code must be exactly 6 characters';

  @override
  String get friendErrorNotFound => 'Code not found';

  @override
  String get friendErrorBadData => 'Invalid data';

  @override
  String get friendErrorOwnCode => 'That is your code';

  @override
  String get leaderboardNameYou => 'You';

  @override
  String get leaderboardNameNotInTable => 'Not on leaderboard';

  @override
  String get defaultPlayerName => 'Player';

  @override
  String get durationHour1 => '1 hour';

  @override
  String get durationHour6 => '6 hours';

  @override
  String get durationDay1 => '24 hours';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsAudioSection => 'AUDIO';

  @override
  String get settingsSoundEnabled => 'Sound effects';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsLanguage => 'Interface language';

  @override
  String get settingsLanguagePickerTitle => 'Choose language';

  @override
  String get profileOpenSettings => 'Settings';
}

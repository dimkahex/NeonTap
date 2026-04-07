import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NEON PULSE'**
  String get appTitle;

  /// No description provided for @taglineOneTap.
  ///
  /// In en, this message translates to:
  /// **'One tap. Pure skill.'**
  String get taglineOneTap;

  /// No description provided for @menuPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get menuPlay;

  /// No description provided for @menuPlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instant run — chase your best score'**
  String get menuPlaySubtitle;

  /// No description provided for @menuLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD'**
  String get menuLeaderboard;

  /// No description provided for @menuLeaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local now • global & friends with Firebase'**
  String get menuLeaderboardSubtitle;

  /// No description provided for @menuVersus.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGES'**
  String get menuVersus;

  /// No description provided for @menuVersusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete with a friend — timed window'**
  String get menuVersusSubtitle;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get menuProfile;

  /// No description provided for @menuProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stats • Achievements • Share card'**
  String get menuProfileSubtitle;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get menuHelp;

  /// No description provided for @helpDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get helpDialogTitle;

  /// No description provided for @helpDialogBody.
  ///
  /// In en, this message translates to:
  /// **'NEON PULSE is a one-tap timing game. A neon ring shrinks toward the center — tap when your timing matches the colored zones.\n\n• Too early (outside the green band) or too late (center black hole) = MISS — the run ends.\n• Green OK +2, orange GOOD +4, yellow COOL +6, red PERFECT +8. PERFECT chain multipliers (×2 → ×16) grow only on consecutive PERFECTs; any other zone resets the chain.\n• At higher scores the field can drift — keep your eyes on the ring.\n\nClose this dialog and tap to play.'**
  String get helpDialogBody;

  /// No description provided for @menuFooterRankings.
  ///
  /// In en, this message translates to:
  /// **'Rankings: local now • cloud in the final build'**
  String get menuFooterRankings;

  /// No description provided for @splashGlobalCompetition.
  ///
  /// In en, this message translates to:
  /// **'GLOBAL COMPETITION'**
  String get splashGlobalCompetition;

  /// No description provided for @gameEndRunTooltip.
  ///
  /// In en, this message translates to:
  /// **'End run'**
  String get gameEndRunTooltip;

  /// No description provided for @gameScoreX2.
  ///
  /// In en, this message translates to:
  /// **'SCORE x2'**
  String get gameScoreX2;

  /// No description provided for @gameStage.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage} · {seconds}s'**
  String gameStage(int stage, String seconds);

  /// No description provided for @gameRankRising.
  ///
  /// In en, this message translates to:
  /// **'RANK RISING!'**
  String get gameRankRising;

  /// No description provided for @judgementOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get judgementOk;

  /// No description provided for @judgementPerfect.
  ///
  /// In en, this message translates to:
  /// **'PERFECT'**
  String get judgementPerfect;

  /// No description provided for @judgementGood.
  ///
  /// In en, this message translates to:
  /// **'GOOD'**
  String get judgementGood;

  /// No description provided for @judgementCool.
  ///
  /// In en, this message translates to:
  /// **'COOL'**
  String get judgementCool;

  /// No description provided for @judgementMiss.
  ///
  /// In en, this message translates to:
  /// **'MISS'**
  String get judgementMiss;

  /// No description provided for @resultsDefeat.
  ///
  /// In en, this message translates to:
  /// **'DEFEAT'**
  String get resultsDefeat;

  /// No description provided for @resultsRunOver.
  ///
  /// In en, this message translates to:
  /// **'RUN OVER'**
  String get resultsRunOver;

  /// No description provided for @resultsFinalScore.
  ///
  /// In en, this message translates to:
  /// **'FINAL SCORE'**
  String get resultsFinalScore;

  /// No description provided for @resultsRunNumber.
  ///
  /// In en, this message translates to:
  /// **'RUN #'**
  String get resultsRunNumber;

  /// No description provided for @resultsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'ACCURACY'**
  String get resultsAccuracy;

  /// No description provided for @resultsHits.
  ///
  /// In en, this message translates to:
  /// **'{count} hits'**
  String resultsHits(int count);

  /// No description provided for @resultsHitBreakdown.
  ///
  /// In en, this message translates to:
  /// **'HIT BREAKDOWN'**
  String get resultsHitBreakdown;

  /// No description provided for @resultsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'PERFECT {perfect} · COOL {cool} · GOOD {good} · OK {ok}'**
  String resultsBreakdown(int perfect, int cool, int good, int ok);

  /// No description provided for @resultsBestCombo.
  ///
  /// In en, this message translates to:
  /// **'BEST COMBO'**
  String get resultsBestCombo;

  /// No description provided for @resultsBestScore.
  ///
  /// In en, this message translates to:
  /// **'BEST SCORE'**
  String get resultsBestScore;

  /// No description provided for @resultsNewBest.
  ///
  /// In en, this message translates to:
  /// **'NEW BEST'**
  String get resultsNewBest;

  /// No description provided for @resultsRankEstimate.
  ///
  /// In en, this message translates to:
  /// **'RANK ESTIMATE'**
  String get resultsRankEstimate;

  /// No description provided for @resultsPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get resultsPlayAgain;

  /// No description provided for @resultsShare.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get resultsShare;

  /// No description provided for @resultsShareSnackbar.
  ///
  /// In en, this message translates to:
  /// **'I scored {score} in NEON PULSE!'**
  String resultsShareSnackbar(int score);

  /// No description provided for @resultsMenu.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get resultsMenu;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardGlobalTab.
  ///
  /// In en, this message translates to:
  /// **'GLOBAL'**
  String get leaderboardGlobalTab;

  /// No description provided for @leaderboardFriendsTab.
  ///
  /// In en, this message translates to:
  /// **'FRIENDS'**
  String get leaderboardFriendsTab;

  /// No description provided for @leaderboardOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline: only your scores on this device. Global board — after Firebase.'**
  String get leaderboardOfflineBanner;

  /// No description provided for @leaderboardOnlineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Global leaderboard is unavailable right now.\n{error}'**
  String leaderboardOnlineUnavailable(String error);

  /// No description provided for @leaderboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the table.\nCheck Firebase and RTDB rules.'**
  String get leaderboardLoadError;

  /// No description provided for @leaderboardEmptyGlobal.
  ///
  /// In en, this message translates to:
  /// **'No entries yet — play and improve your best score.'**
  String get leaderboardEmptyGlobal;

  /// No description provided for @leaderboardEmptyLocal.
  ///
  /// In en, this message translates to:
  /// **'Play a run — your best score will appear here.'**
  String get leaderboardEmptyLocal;

  /// No description provided for @leaderboardErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String leaderboardErrorGeneric(String error);

  /// No description provided for @leaderboardFriendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add friends by code in Profile — your scores and their bests will show here.'**
  String get leaderboardFriendsEmpty;

  /// No description provided for @leaderboardComboLine.
  ///
  /// In en, this message translates to:
  /// **'x{combo} combo'**
  String leaderboardComboLine(int combo);

  /// No description provided for @leaderboardYouSuffix.
  ///
  /// In en, this message translates to:
  /// **' (you)'**
  String get leaderboardYouSuffix;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileTitle;

  /// No description provided for @profileNameInTable.
  ///
  /// In en, this message translates to:
  /// **'NICKNAME'**
  String get profileNameInTable;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'How others see you'**
  String get profileNameHint;

  /// No description provided for @profileSaveName.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get profileSaveName;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get profileSaved;

  /// No description provided for @profileOfflineFirebaseNote.
  ///
  /// In en, this message translates to:
  /// **'Everything is local on this device for now. Cloud and global board — when you set kFirebaseOnlineFeaturesEnabled = true and configure Firebase.'**
  String get profileOfflineFirebaseNote;

  /// No description provided for @profileYourFriendCode.
  ///
  /// In en, this message translates to:
  /// **'YOUR FRIEND CODE'**
  String get profileYourFriendCode;

  /// No description provided for @profileCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get profileCopyCode;

  /// No description provided for @profileCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get profileCodeCopied;

  /// No description provided for @profileFriendCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Share this code — your friend enters it below on their device.'**
  String get profileFriendCodeHint;

  /// No description provided for @profileAddFriend.
  ///
  /// In en, this message translates to:
  /// **'ADD FRIEND'**
  String get profileAddFriend;

  /// No description provided for @profileFriendCodeFieldHint.
  ///
  /// In en, this message translates to:
  /// **'6-character code'**
  String get profileFriendCodeFieldHint;

  /// No description provided for @profileOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get profileOk;

  /// No description provided for @profileFriends.
  ///
  /// In en, this message translates to:
  /// **'FRIENDS'**
  String get profileFriends;

  /// No description provided for @profileFriendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one yet — add by code.'**
  String get profileFriendsEmpty;

  /// No description provided for @profileBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get profileBack;

  /// No description provided for @profileFirebaseLaterNote.
  ///
  /// In en, this message translates to:
  /// **'Friend code and list appear after Firebase is enabled (see lib/src/config/online_config.dart).'**
  String get profileFirebaseLaterNote;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get profileLanguage;

  /// No description provided for @profileLanguageRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get profileLanguageRu;

  /// No description provided for @profileLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @versusTitle.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGES'**
  String get versusTitle;

  /// No description provided for @versusHeadline.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE MODE'**
  String get versusHeadline;

  /// No description provided for @versusBody.
  ///
  /// In en, this message translates to:
  /// **'Send a challenge to a friend for 1h, 6h, or 24h.\nWithin the time window, both of you play — only your best run counts.\n\nWhile a challenge is active, a countdown appears on the main menu.'**
  String get versusBody;

  /// No description provided for @versusOpenChallenges.
  ///
  /// In en, this message translates to:
  /// **'OPEN CHALLENGES'**
  String get versusOpenChallenges;

  /// No description provided for @versusBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get versusBack;

  /// No description provided for @versusActiveTimer.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE CHALLENGE · {timeLeft}'**
  String versusActiveTimer(String timeLeft);

  /// No description provided for @versusHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'What are challenges?'**
  String get versusHelpTitle;

  /// No description provided for @versusHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a friend and duration (1h / 6h / 24h). During the window you both attempt runs; the best score of each player counts. You can accept/decline and view history.'**
  String get versusHelpBody;

  /// No description provided for @challengesTitle.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGES'**
  String get challengesTitle;

  /// No description provided for @challengesNewTooltip.
  ///
  /// In en, this message translates to:
  /// **'New challenge'**
  String get challengesNewTooltip;

  /// No description provided for @challengesMakeChallenge.
  ///
  /// In en, this message translates to:
  /// **'MAKE A CHALLENGE'**
  String get challengesMakeChallenge;

  /// No description provided for @challengesFirebaseDisabled.
  ///
  /// In en, this message translates to:
  /// **'Player vs player challenges unlock after Firebase.\n\nSet kFirebaseOnlineFeaturesEnabled = true\nand follow firebase/README.md'**
  String get challengesFirebaseDisabled;

  /// No description provided for @challengesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No challenges yet.\nTap + to send one to a friend.'**
  String get challengesEmpty;

  /// No description provided for @challengeVersus.
  ///
  /// In en, this message translates to:
  /// **'{from} vs {to}'**
  String challengeVersus(String from, String to);

  /// No description provided for @challengeStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get challengeStatusPending;

  /// No description provided for @challengeStatusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get challengeStatusActive;

  /// No description provided for @challengeStatusFinishing.
  ///
  /// In en, this message translates to:
  /// **'FINISHING'**
  String get challengeStatusFinishing;

  /// No description provided for @challengeStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get challengeStatusCompleted;

  /// No description provided for @challengeStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'DECLINED'**
  String get challengeStatusDeclined;

  /// No description provided for @challengeStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get challengeStatusCancelled;

  /// No description provided for @challengeEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends: {when}'**
  String challengeEnds(String when);

  /// No description provided for @challengeAccept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get challengeAccept;

  /// No description provided for @challengeDecline.
  ///
  /// In en, this message translates to:
  /// **'DECLINE'**
  String get challengeDecline;

  /// No description provided for @challengeCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get challengeCancel;

  /// No description provided for @challengeRiskArm.
  ///
  /// In en, this message translates to:
  /// **'RISK ×1.25'**
  String get challengeRiskArm;

  /// No description provided for @challengeRiskDisarm.
  ///
  /// In en, this message translates to:
  /// **'DISARM RISK'**
  String get challengeRiskDisarm;

  /// No description provided for @challengeRiskHint.
  ///
  /// In en, this message translates to:
  /// **'Risk: once per player — next run can be ×1.25 (0 stays 0, risk is consumed).'**
  String get challengeRiskHint;

  /// No description provided for @challengeRiskReady.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get challengeRiskReady;

  /// No description provided for @challengeRiskUsed.
  ///
  /// In en, this message translates to:
  /// **'RISK USED'**
  String get challengeRiskUsed;

  /// No description provided for @createChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'NEW CHALLENGE'**
  String get createChallengeTitle;

  /// No description provided for @createChallengeFriend.
  ///
  /// In en, this message translates to:
  /// **'FRIEND'**
  String get createChallengeFriend;

  /// No description provided for @createChallengeNoFriends.
  ///
  /// In en, this message translates to:
  /// **'Add at least one friend in Profile first.'**
  String get createChallengeNoFriends;

  /// No description provided for @createChallengeDuration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get createChallengeDuration;

  /// No description provided for @createChallengeSend.
  ///
  /// In en, this message translates to:
  /// **'SEND'**
  String get createChallengeSend;

  /// No description provided for @createChallengeBusy.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get createChallengeBusy;

  /// No description provided for @createChallengeRuleHint.
  ///
  /// In en, this message translates to:
  /// **'Rule: your best single run in the window counts. Risk round: once you can arm ×1.25 for the next run.'**
  String get createChallengeRuleHint;

  /// No description provided for @createChallengeCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Code not found'**
  String get createChallengeCodeNotFound;

  /// No description provided for @createChallengeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create challenge'**
  String get createChallengeFailed;

  /// No description provided for @createChallengeSent.
  ///
  /// In en, this message translates to:
  /// **'Challenge sent'**
  String get createChallengeSent;

  /// No description provided for @snackIncomingChallenge.
  ///
  /// In en, this message translates to:
  /// **'New challenge from {name}'**
  String snackIncomingChallenge(String name);

  /// No description provided for @snackNameSaved.
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get snackNameSaved;

  /// No description provided for @snackFriendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friend added'**
  String get snackFriendAdded;

  /// No description provided for @friendErrorFirebaseDisabled.
  ///
  /// In en, this message translates to:
  /// **'Friends by code — after Firebase is enabled (online_config.dart)'**
  String get friendErrorFirebaseDisabled;

  /// No description provided for @friendErrorNotReady.
  ///
  /// In en, this message translates to:
  /// **'No network or Firebase'**
  String get friendErrorNotReady;

  /// No description provided for @friendErrorNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get friendErrorNoAccount;

  /// No description provided for @friendErrorInvalidLength.
  ///
  /// In en, this message translates to:
  /// **'Code must be exactly 6 characters'**
  String get friendErrorInvalidLength;

  /// No description provided for @friendErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Code not found'**
  String get friendErrorNotFound;

  /// No description provided for @friendErrorBadData.
  ///
  /// In en, this message translates to:
  /// **'Invalid data'**
  String get friendErrorBadData;

  /// No description provided for @friendErrorOwnCode.
  ///
  /// In en, this message translates to:
  /// **'That is your code'**
  String get friendErrorOwnCode;

  /// No description provided for @leaderboardNameYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get leaderboardNameYou;

  /// No description provided for @leaderboardNameNotInTable.
  ///
  /// In en, this message translates to:
  /// **'Not on leaderboard'**
  String get leaderboardNameNotInTable;

  /// No description provided for @defaultPlayerName.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get defaultPlayerName;

  /// No description provided for @durationHour1.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get durationHour1;

  /// No description provided for @durationHour6.
  ///
  /// In en, this message translates to:
  /// **'6 hours'**
  String get durationHour6;

  /// No description provided for @durationDay1.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get durationDay1;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsAudioSection.
  ///
  /// In en, this message translates to:
  /// **'AUDIO'**
  String get settingsAudioSection;

  /// No description provided for @settingsSoundEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSoundEnabled;

  /// No description provided for @settingsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolume;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsLanguagePickerTitle;

  /// No description provided for @profileOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileOpenSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

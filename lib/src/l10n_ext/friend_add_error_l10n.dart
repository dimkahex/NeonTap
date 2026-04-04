import '../../l10n/app_localizations.dart';
import '../services/friends_service.dart';

extension FriendAddErrorL10n on FriendAddError {
  String message(AppLocalizations l10n) {
    return switch (this) {
      FriendAddError.firebaseDisabled => l10n.friendErrorFirebaseDisabled,
      FriendAddError.notReady => l10n.friendErrorNotReady,
      FriendAddError.noAccount => l10n.friendErrorNoAccount,
      FriendAddError.invalidLength => l10n.friendErrorInvalidLength,
      FriendAddError.notFound => l10n.friendErrorNotFound,
      FriendAddError.badData => l10n.friendErrorBadData,
      FriendAddError.ownCode => l10n.friendErrorOwnCode,
    };
  }
}

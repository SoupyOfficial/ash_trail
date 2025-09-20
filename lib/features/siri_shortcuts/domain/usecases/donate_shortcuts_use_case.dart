// Use case for donating shortcuts to Siri after first in-app use.
// Handles the business logic for determining when and which shortcuts to donate.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../repositories/siri_shortcuts_repository.dart';

class DonateShortcutsUseCase {
  const DonateShortcutsUseCase(this._repository);

  final SiriShortcutsRepository _repository;

  /// Donate shortcuts for Add Log and Start Timed Log after first in-app use.
  /// Creates shortcut configurations if they don't exist and donates them to Siri.
  Future<Either<AppFailure, void>> call() async {
    // Check if Siri shortcuts are supported
    final supportedResult = await _repository.isSiriShortcutsSupported();
    return supportedResult.fold(
      (failure) => Left(failure),
      (isSupported) async {
        if (!isSupported) {
          return const Left(AppFailure.validation(
            message: 'Siri shortcuts are not supported on this platform',
          ));
        }

        // Get shortcuts that need donation and donate them
        final needsDonationResult = await _repository.getShortcutsNeedingDonation();
        return needsDonationResult.fold(
          (failure) => Left(failure),
          (shortcutsToDonate) async {
            if (shortcutsToDonate.isNotEmpty) {
              return _repository.donateShortcuts(shortcutsToDonate);
            }
            return const Right(null);
          },
        );
      },
    );
  }
}
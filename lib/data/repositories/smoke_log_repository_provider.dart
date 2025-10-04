import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/capture_hit/domain/repositories/smoke_log_repository.dart';

// Conditional import selects the correct factory for web vs io builds.
import 'smoke_log_repository_provider_web.dart'
    if (dart.library.io) 'smoke_log_repository_provider_io.dart';

final smokeLogRepositoryProvider =
    FutureProvider<SmokeLogRepository>((ref) async {
  return await createSmokeLogRepository(ref);
});

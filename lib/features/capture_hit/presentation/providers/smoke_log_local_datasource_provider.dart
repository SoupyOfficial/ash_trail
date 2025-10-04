import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/smoke_log_local_datasource.dart';

// Conditional import selects the correct factory for web vs io builds.
import 'smoke_log_local_datasource_provider_web.dart'
    if (dart.library.io) 'smoke_log_local_datasource_provider_io.dart';

/// Platform-aware provider for SmokeLogLocalDataSource
final smokeLogLocalDataSourceProvider =
    FutureProvider<SmokeLogLocalDataSource>((ref) async {
  return await createSmokeLogLocalDataSource(ref);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/smoke_log_local_datasource.dart';
import '../../data/datasources/smoke_log_local_datasource_impl.dart';
import '../../../../data/services/isar_service.dart';

Future<SmokeLogLocalDataSource> createSmokeLogLocalDataSource(Ref ref) async {
  final isarService = await ref.watch(isarSmokeLogServiceProvider.future);
  return SmokeLogLocalDataSourceImpl(isarService);
}

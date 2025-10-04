import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/smoke_log_local_datasource.dart';
import '../../data/datasources/smoke_log_local_datasource_impl_web.dart';

Future<SmokeLogLocalDataSource> createSmokeLogLocalDataSource(Ref ref) async {
  return SmokeLogLocalDataSourceWeb();
}

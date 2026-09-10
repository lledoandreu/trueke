import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/report_model.dart';
import '../../domain/repositories/support_repository.dart';

class SupabaseSupportRepository implements SupportRepository {
  final SupabaseClient _client;
  static const _tableName = 'reports';

  SupabaseSupportRepository(this._client);

  @override
  Future<void> submitReport(ReportModel report) async {
    await _client.from(_tableName).insert(report.toJson());
  }

  @override
  Future<List<ReportModel>> fetchUserReports({required String userId}) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('reporter_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ReportModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

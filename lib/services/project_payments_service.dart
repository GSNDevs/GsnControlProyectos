import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectPaymentsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'project_payments';

  Future<List<Map<String, dynamic>>> getProjectPayments(
    String projectId,
  ) async {
    return await _client
        .from(_tableName)
        .select()
        .eq('project_id', projectId)
        .order('payment_date', ascending: false);
  }

  Future<void> addPayment(Map<String, dynamic> data) async {
    data['created_by'] = _client.auth.currentUser?.id;
    await _client.from(_tableName).insert(data);
  }

  Future<void> updatePayment(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }

  Future<void> deletePayment(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'notifications';

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    return await _client
        .from(_tableName)
        .select()
        .eq('recipient_id', user.id)
        .order('created_at', ascending: false);
  }

  Future<void> markAsRead(String id) async {
    await _client.from(_tableName).update({'read': true}).eq('id', id);
  }

  Future<void> createNotification(Map<String, dynamic> notificationData) async {
    await _client.from(_tableName).insert(notificationData);
  }
}

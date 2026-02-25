import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quote.dart';

class QuotesService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'quotes';
  final String _bucketName = 'quotes_documents';

  /// Fetch all quotes for admins
  Future<List<Quote>> getAllQuotes() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);
    return response.map((json) => Quote.fromJson(json)).toList();
  }

  /// Fetch quotes specific to a client
  Future<List<Quote>> getClientQuotes(String clientId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return response.map((json) => Quote.fromJson(json)).toList();
  }

  /// Create a new quote request
  Future<void> createQuote(Map<String, dynamic> quoteData) async {
    await _client.from(_tableName).insert(quoteData);
  }

  /// Upload a document to the quotes bucket and return its public URL
  Future<String> uploadQuoteDocument(
    String clientId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Format: clientId_timestamp_filename.ext
    final filePath = '${clientId}_${timestamp}_$fileName';

    await _client.storage.from(_bucketName).uploadBinary(filePath, fileBytes);

    return _client.storage.from(_bucketName).getPublicUrl(filePath);
  }
}

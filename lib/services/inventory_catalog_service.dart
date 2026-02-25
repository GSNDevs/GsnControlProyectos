import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryCatalogService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'inventory_catalog';

  Future<List<Map<String, dynamic>>> getProducts() async {
    return await _client.from(_tableName).select().order('name');
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    return await _client.from(_tableName).select().eq('id', id).maybeSingle();
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    await _client.from(_tableName).insert(productData);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}

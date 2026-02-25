import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ProductCategoriesService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'product_categories';

  Future<List<ProductCategory>> getCategories() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('name', ascending: true);

    return (response as List).map((i) => ProductCategory.fromJson(i)).toList();
  }

  Future<ProductCategory> createCategory(Map<String, dynamic> data) async {
    final response = await _client
        .from(_tableName)
        .insert(data)
        .select()
        .single();
    return ProductCategory.fromJson(response);
  }

  Future<ProductCategory> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_tableName)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ProductCategory.fromJson(response);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}

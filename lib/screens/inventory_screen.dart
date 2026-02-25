import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:intl/intl.dart';

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void toggle(String id) {
    if (state == id) {
      state = null;
    } else {
      state = id;
    }
  }
}

final selectedCategoryForInventoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Categoría"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Nombre de Categoría",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              ref.read(productCategoriesControllerProvider).addCategory({
                'name': nameCtrl.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(
    BuildContext context,
    WidgetRef ref,
    List<ProductCategory> categories,
    String? defaultCategoryId,
  ) {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    String? selectedCategoryId = defaultCategoryId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Agregar Producto"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: "Categoría",
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedCategoryId = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: skuCtrl,
                  decoration: const InputDecoration(
                    labelText: "SKU",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Precio Base",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Stock Inicial",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;

                final newProduct = {
                  'name': nameCtrl.text,
                  'sku': skuCtrl.text,
                  'category_id': selectedCategoryId,
                  'default_price': double.tryParse(priceCtrl.text) ?? 0,
                  'stock_count': int.tryParse(stockCtrl.text) ?? 0,
                };
                ref.read(inventoryControllerProvider).addProduct(newProduct);
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    ProductCategory category,
  ) {
    final nameCtrl = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Categoría"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Nombre de Categoría",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              ref.read(productCategoriesControllerProvider).updateCategory(
                category.id,
                {'name': nameCtrl.text},
              );
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
    List<ProductCategory> categories,
  ) {
    final nameCtrl = TextEditingController(text: product.name);
    final skuCtrl = TextEditingController(text: product.sku ?? '');
    final priceCtrl = TextEditingController(
      text: product.defaultPrice.toString(),
    );
    final stockCtrl = TextEditingController(
      text: product.stockCount.toString(),
    );
    String? selectedCategoryId = product.categoryId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Editar Producto"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: "Categoría",
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedCategoryId = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: skuCtrl,
                  decoration: const InputDecoration(
                    labelText: "SKU",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Precio Base",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Stock",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                ref
                    .read(inventoryControllerProvider)
                    .updateProduct(product.id, {
                      'name': nameCtrl.text,
                      'sku': skuCtrl.text,
                      'category_id': selectedCategoryId,
                      'default_price': double.tryParse(priceCtrl.text) ?? 0,
                      'stock_count': int.tryParse(stockCtrl.text) ?? 0,
                    });
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final productsAsync = ref.watch(inventoryProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );

    final selectedCategoryId = ref.watch(selectedCategoryForInventoryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        return Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Catálogo de Productos",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Agrega y administra los ítems de inventario y sus categorías",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final categoriasWidget = Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.softShadow,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Categorías",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddCategoryDialog(context, ref),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Nueva"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gsnBlue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Expanded(
                            child: categoriesAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, s) => Center(child: Text("Error: $e")),
                              data: (categories) {
                                if (categories.isEmpty)
                                  return const Center(
                                    child: Text("Sin categorías."),
                                  );
                                return ListView.separated(
                                  itemCount: categories.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final cat = categories[i];
                                    final isSelected =
                                        selectedCategoryId == cat.id;
                                    return ListTile(
                                      selected: isSelected,
                                      selectedTileColor: AppColors.gsnBlue
                                          .withValues(alpha: 0.1),
                                      onTap: () {
                                        ref
                                            .read(
                                              selectedCategoryForInventoryProvider
                                                  .notifier,
                                            )
                                            .toggle(cat.id);
                                      },
                                      leading: const Icon(
                                        Icons.folder_outlined,
                                        color: AppColors.gsnBlue,
                                      ),
                                      title: Text(
                                        cat.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: AppColors.gsnBlue,
                                            ),
                                            tooltip: "Editar",
                                            onPressed: () =>
                                                _showEditCategoryDialog(
                                                  context,
                                                  ref,
                                                  cat,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppColors.error,
                                            ),
                                            tooltip: "Eliminar",
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: const Text(
                                                        "Confirmar",
                                                      ),
                                                      content: const Text(
                                                        "¿Eliminar categoría? Los productos que tengan esta categoría se visualizarán huérfanos.",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                c,
                                                                false,
                                                              ),
                                                          child: const Text(
                                                            "Cancelar",
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                c,
                                                                true,
                                                              ),
                                                          child: const Text(
                                                            "Eliminar",
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .error,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                              if (confirm == true) {
                                                ref
                                                    .read(
                                                      productCategoriesControllerProvider,
                                                    )
                                                    .deleteCategory(cat.id);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );

                    final productosWidget = Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.softShadow,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Productos",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final currentCats =
                                      categoriesAsync.value ?? [];
                                  if (currentCats.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Añade una categoría primero.",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _showAddProductDialog(
                                    context,
                                    ref,
                                    currentCats,
                                    selectedCategoryId,
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Nuevo Producto"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gsnBlue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Expanded(
                            child: productsAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, s) => Center(child: Text("Error: $e")),
                              data: (products) {
                                if (selectedCategoryId == null) {
                                  return const Center(
                                    child: Text(
                                      "Selecciona una categoría para ver sus productos.",
                                    ),
                                  );
                                }

                                final filteredProducts = products
                                    .where(
                                      (p) => p.categoryId == selectedCategoryId,
                                    )
                                    .toList();

                                if (filteredProducts.isEmpty)
                                  return const Center(
                                    child: Text(
                                      "No existen productos en esta categoría.",
                                    ),
                                  );
                                return ListView.separated(
                                  itemCount: filteredProducts.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final product = filteredProducts[i];
                                    final cats = categoriesAsync.value ?? [];

                                    // Find the category by matching the ID
                                    String categoryName = 'General';
                                    if (product.categoryId != null) {
                                      try {
                                        categoryName = cats
                                            .firstWhere(
                                              (c) => c.id == product.categoryId,
                                            )
                                            .name;
                                      } catch (_) {
                                        // category not found (deleted)
                                        categoryName = 'Sin categoría';
                                      }
                                    }

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                      leading: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.gsnBlue.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          product.name.isNotEmpty
                                              ? product.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: AppColors.gsnBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "SKU: ${product.sku} • $categoryName",
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            currencyFormat.format(
                                              product.defaultPrice,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: product.stockCount < 5
                                                  ? AppColors.error.withValues(
                                                      alpha: 0.1,
                                                    )
                                                  : AppColors.success
                                                        .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "${product.stockCount} un.",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: product.stockCount < 5
                                                    ? AppColors.error
                                                    : AppColors.success,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: AppColors.gsnBlue,
                                            ),
                                            onPressed: () {
                                              _showEditProductDialog(
                                                context,
                                                ref,
                                                product,
                                                cats,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppColors.error,
                                            ),
                                            onPressed: () async {
                                              ref
                                                  .read(
                                                    inventoryControllerProvider,
                                                  )
                                                  .removeProduct(product.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );

                    if (isMobile) {
                      return DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            const TabBar(
                              labelColor: AppColors.gsnBlue,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.gsnBlue,
                              tabs: [
                                Tab(text: "Categorías"),
                                Tab(text: "Productos"),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: TabBarView(
                                children: [categoriasWidget, productosWidget],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: categoriasWidget),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: productosWidget),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

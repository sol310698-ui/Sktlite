import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/db_helper.dart';
import '../models/product.dart';

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return DbHelper.instance.getAllProducts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => DbHelper.instance.getAllProducts());
  }

  Future<void> add(Product product) async {
    await DbHelper.instance.insertProduct(product);
    await refresh();
  }

  Future<void> remove(int id) async {
    await DbHelper.instance.deleteProduct(id);
    await refresh();
  }

  Future<void> update(Product product) async {
    await DbHelper.instance.updateProduct(product);
    await refresh();
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(
  ProductListNotifier.new,
);

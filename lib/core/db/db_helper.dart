import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

/// Tek tablolu, sade SQLite katmanı. Eski uygulamadaki 30+ tablo/migration
/// zincirinin aksine burada TEK tablo ve TEK sürüm var — hafiflik için.
class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'skt_takip_lite.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            barcode TEXT NOT NULL,
            name TEXT NOT NULL,
            expiry_date TEXT NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_products_barcode ON products(barcode)',
        );
        await db.execute(
          'CREATE INDEX idx_products_expiry ON products(expiry_date)',
        );
      },
    );
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return db.insert('products', product.toMap()..remove('id'));
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  /// SKT'ye göre artan sırada (en yakın tarih en üstte) tüm ürünler.
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'expiry_date ASC');
    return rows.map(Product.fromMap).toList();
  }

  /// Aynı barkod daha önce eklenmişse hızlı erişim için (opsiyonel kullanım).
  Future<List<Product>> getByBarcode(String barcode) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      orderBy: 'expiry_date ASC',
    );
    return rows.map(Product.fromMap).toList();
  }
}

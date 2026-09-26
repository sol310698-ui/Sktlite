class Product {
  final int? id;
  final String barcode;
  final String name;
  final DateTime expiryDate;
  final int quantity;
  final DateTime createdAt;

  const Product({
    this.id,
    required this.barcode,
    required this.name,
    required this.expiryDate,
    required this.quantity,
    required this.createdAt,
  });

  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    DateTime? expiryDate,
    int? quantity,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'expiry_date': expiryDate.toIso8601String(),
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      name: map['name'] as String,
      expiryDate: DateTime.parse(map['expiry_date'] as String),
      quantity: map['quantity'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

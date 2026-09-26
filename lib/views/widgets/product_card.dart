import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onDelete,
  });

  Color _statusColor(int daysLeft) {
    if (daysLeft < 0) return Colors.red.shade700;
    if (daysLeft <= 3) return Colors.red;
    if (daysLeft <= 7) return Colors.orange;
    return Colors.green;
  }

  String _statusLabel(int daysLeft) {
    if (daysLeft < 0) return '${-daysLeft} gün geçti';
    if (daysLeft == 0) return 'Bugün';
    return '$daysLeft gün kaldı';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(product.daysLeft);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.inventory_2_outlined, color: color),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${product.barcode} · Adet: ${product.quantity}\n'
          'SKT: ${DateFormat('dd.MM.yyyy').format(product.expiryDate)}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _statusLabel(product.daysLeft),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

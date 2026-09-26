import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/models/product.dart';
import '../core/providers/product_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  DateTime? _expiryDate;
  bool _scannerOpen = false;
  bool _saving = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    setState(() {
      _barcodeController.text = value;
      _scannerOpen = false;
    });
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SKT (son kullanma tarihi) seç')),
      );
      return;
    }
    setState(() => _saving = true);
    final product = Product(
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      expiryDate: _expiryDate!,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
      createdAt: DateTime.now(),
    );
    await ref.read(productListProvider.notifier).add(product);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Ekle')),
      body: Column(
        children: [
          if (_scannerOpen)
            SizedBox(
              height: 280,
              child: MobileScanner(onDetect: _onBarcodeDetected),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barkod',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _scannerOpen
                                ? Icons.close
                                : Icons.qr_code_scanner,
                          ),
                          onPressed: () {
                            setState(() => _scannerOpen = !_scannerOpen);
                          },
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Barkod gir' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Ürün Adı'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ürün adı gir'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Adet'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _expiryDate == null
                            ? 'SKT seç'
                            : 'SKT: ${_expiryDate!.day.toString().padLeft(2, '0')}.'
                                '${_expiryDate!.month.toString().padLeft(2, '0')}.'
                                '${_expiryDate!.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickExpiryDate,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kaydet'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

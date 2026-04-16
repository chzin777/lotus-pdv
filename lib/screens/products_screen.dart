import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductDialog({Product? product}) {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final costCtrl = TextEditingController(text: product?.costPrice.toString() ?? '');
    final priceCtrl = TextEditingController(text: product?.sellingPrice.toString() ?? '');
    final qtdCtrl = TextEditingController(text: product?.quantity.toString() ?? '0');
    final categoryCtrl = TextEditingController(text: product?.category ?? 'Geral');
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Novo Produto' : 'Editar Produto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() => selectedImage = File(image.path));
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : product?.imagePath != null
                              ? Image.file(File(product!.imagePath!), fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => selectedImage = File(image.path));
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Selecionar Imagem'),
                ),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Categoria')),
                TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU')),
                TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Preço de Custo')),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Preço de Venda')),
                TextField(controller: qtdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantidade')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String? imagePath = product?.imagePath;

                if (selectedImage != null) {
                  final fileName = '${const Uuid().v4()}.jpg';
                  final savedFile = await StorageService.saveImage(selectedImage!, fileName);
                  imagePath = savedFile.path;
                }

                final newProduct = Product(
                  id: product?.id ?? const Uuid().v4(),
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  costPrice: double.tryParse(costCtrl.text) ?? 0,
                  sellingPrice: double.tryParse(priceCtrl.text) ?? 0,
                  quantity: int.tryParse(qtdCtrl.text) ?? 0,
                  category: categoryCtrl.text.isEmpty ? 'Geral' : categoryCtrl.text,
                  imagePath: imagePath,
                  sku: skuCtrl.text,
                );

                if (product != null) {
                  await context.read<ProductProvider>().updateProduct(newProduct);
                } else {
                  await context.read<ProductProvider>().addProduct(newProduct);
                }

                if (mounted) Navigator.pop(context);
              },
              child: Text(product == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final searchText = _searchController.text.toLowerCase();
    final filtered = products.where((p) => p.name.toLowerCase().contains(searchText)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar produtos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showProductDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Novo Produto'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final product = filtered[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: product.imagePath != null
                      ? Image.file(File(product.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text(product.name),
                  subtitle: Text('R\$ ${product.sellingPrice.toStringAsFixed(2)} | Est: ${product.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showProductDialog(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                        onPressed: () => context.read<ProductProvider>().deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

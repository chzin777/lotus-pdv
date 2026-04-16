import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  product == null ? Icons.add_rounded : Icons.edit_rounded,
                  size: 18,
                  color: const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                product == null ? 'Novo Produto' : 'Editar Produto',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image picker
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
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(selectedImage!, fit: BoxFit.cover),
                              )
                            : product?.imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(File(product!.imagePath!), fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 36, color: const Color(0xFF94A3B8)),
                                      const SizedBox(height: 8),
                                      const Text('Clique para selecionar imagem', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fields
                  _DialogField(controller: nameCtrl, label: 'Nome'),
                  _DialogField(controller: descCtrl, label: 'Descrição'),
                  Row(
                    children: [
                      Expanded(child: _DialogField(controller: categoryCtrl, label: 'Categoria')),
                      const SizedBox(width: 12),
                      Expanded(child: _DialogField(controller: skuCtrl, label: 'SKU')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _DialogField(controller: costCtrl, label: 'Preço de Custo', keyboard: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _DialogField(controller: priceCtrl, label: 'Preço de Venda', keyboard: TextInputType.number)),
                    ],
                  ),
                  _DialogField(controller: qtdCtrl, label: 'Quantidade', keyboard: TextInputType.number),
                ],
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(product == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar exclusão', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        content: Text('Deseja realmente excluir "$productName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(productId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final searchText = _searchController.text.toLowerCase();
    final filtered = searchText.isEmpty
        ? products
        : products.where((p) => p.name.toLowerCase().contains(searchText)).toList();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Produtos',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${products.length} produtos cadastrados',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showProductDialog(),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Novo Produto', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.06, end: 0),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          // Product list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF94A3B8), size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text('Nenhum produto encontrado', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                        const SizedBox(height: 4),
                        const Text('Cadastre um novo produto para começar', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(28, 4, 28, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return _ProductListItem(
                        product: product,
                        onEdit: () => _showProductDialog(product: product),
                        onDelete: () => _showDeleteConfirm(product.id, product.name),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          ),
        ],
      ),
    );
  }
}

// ── Product List Item ──

class _ProductListItem extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductListItem({required this.product, required this.onEdit, required this.onDelete});

  @override
  State<_ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<_ProductListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF1F5F9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
          boxShadow: _hovered
              ? [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: p.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(p.imagePath!), width: 52, height: 52, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.image_outlined, color: Color(0xFFCBD5E1), size: 24),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _TagChip(label: p.category, color: const Color(0xFF7C3AED)),
                      const SizedBox(width: 8),
                      if (p.sku.isNotEmpty)
                        Text(p.sku, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${p.sellingPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: p.quantity > 5
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : p.quantity > 0
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                            : const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${p.quantity} un',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.quantity > 5
                          ? const Color(0xFF10B981)
                          : p.quantity > 0
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // Actions
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
              onPressed: widget.onEdit,
              tooltip: 'Editar',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
              onPressed: widget.onDelete,
              tooltip: 'Excluir',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag Chip ──

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ── Dialog Field ──

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboard;

  const _DialogField({required this.controller, required this.label, this.keyboard});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

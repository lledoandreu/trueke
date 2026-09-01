import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/products_provider.dart';

class PublishProductPage extends ConsumerStatefulWidget {
  const PublishProductPage({super.key, this.product});
  final Product? product;

  @override
  ConsumerState<PublishProductPage> createState() => _PublishProductPageState();
}

class _PublishProductPageState extends ConsumerState<PublishProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _wantedController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;

  String _category = 'Electrónica';
  String _condition = 'Buen estado';
  TradeType _tradeType = TradeType.trade;
  bool _isSaving = false;
  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleController = TextEditingController(text: product?.title);
    _descriptionController = TextEditingController(text: product?.description);
    _wantedController = TextEditingController(text: product?.wanted);
    _locationController = TextEditingController(text: product?.location);
    _priceController = TextEditingController(
      text: product?.price?.toStringAsFixed(0),
    );

    if (product != null) {
      _category = product.category;
      _condition = product.condition;
      _tradeType = product.tradeType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _wantedController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80);
    if (!mounted) return;
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages
          ..clear()
          ..addAll(images);
      });
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    if (_tradeType != TradeType.trade && price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Precio no válido')));
      return;
    }
    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) return;

    setState(() => _isSaving = true);
    final uploadedImages = <String>[];
    var persistenceCompleted = false;

    try {
      final existingProduct = widget.product;
      for (final image in _selectedImages) {
        final url = await ref
            .read(productsProvider.notifier)
            .uploadProductImage(image);
        if (!uploadedImages.contains(url)) uploadedImages.add(url);
      }

      final allImages = <String>[
        ...(existingProduct?.images ?? <String>[]),
        ...uploadedImages,
      ];
      final product = Product(
        id:
            existingProduct?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        images: allImages,
        price: _tradeType == TradeType.trade ? null : price,
        tradeType: _tradeType,
        category: _category,
        location: _locationController.text.trim(),
        owner: existingProduct?.owner ?? AuthService.currentUserLabel,
        ownerId: existingProduct?.ownerId ?? currentUserId,
        condition: _condition,
        description: _descriptionController.text.trim(),
        wanted: _wantedController.text.trim(),
        createdAt: existingProduct?.createdAt ?? DateTime.now(),
      );

      if (existingProduct == null) {
        await ref.read(productsProvider.notifier).addProduct(product);
      } else {
        await ref.read(productsProvider.notifier).updateProduct(product);
      }
      persistenceCompleted = true;
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!persistenceCompleted) {
        for (final url in uploadedImages) {
          await ref.read(productsProvider.notifier).deleteProductImage(url);
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Publicar artículo' : 'Editar anuncio',
        ),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TradeType>(
                      initialValue: _tradeType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de trueque',
                      ),
                      items: TradeType.values
                          .map(
                            (t) =>
                                DropdownMenuItem(value: t, child: Text(t.name)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _tradeType = val ?? TradeType.trade),
                    ),
                    if (_tradeType != TradeType.trade) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio estimado (€)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Fotos'),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _publish,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

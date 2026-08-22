import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/auth_service.dart';
import '../../models/product.dart';
import 'providers/products_provider.dart';

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

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo selector de imágenes...')),
    );

    final images = await picker.pickMultiImage(imageQuality: 80);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imágenes seleccionadas: ${images.length}')),
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages
          ..clear()
          ..addAll(images);
      });
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    if (_tradeType != TradeType.trade && price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Indica un precio válido.')));
      return;
    }

    setState(() => _isSaving = true);

    final existingProduct = widget.product;
    final currentUserId = AuthService.currentUserId;

    if (currentUserId == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión para publicar un artículo.'),
        ),
      );
      return;
    }

    final uploadedImages = <String>[];

    for (final image in _selectedImages) {
      final url = await ref
          .read(productsProvider.notifier)
          .uploadProductImage(image);

      uploadedImages.add(url);
    }

    final product = Product(
      id:
          existingProduct?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      images: uploadedImages.isNotEmpty
          ? uploadedImages
          : existingProduct?.images ?? const [],
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
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    if (existingProduct != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anuncio actualizado correctamente.')),
      );
      Navigator.pop(context);
      return;
    }
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _wantedController.clear();
    _locationController.clear();
    _priceController.clear();
    setState(() {
      _category = 'Electrónica';
      _condition = 'Buen estado';
      _tradeType = TradeType.trade;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Artículo publicado correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Publicar artículo' : 'Editar anuncio',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.product == null
                    ? 'Comparte algo que ya no usas'
                    : 'Actualiza la información de tu anuncio',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Añade fotos de tu artículo.'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Añadir fotos'),
              ),
              const SizedBox(height: 24),
              _field(
                controller: _titleController,
                label: 'Título',
                hint: 'Ej. Cámara réflex Canon',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(_category),
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (category) => setState(() => _category = category!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TradeType>(
                key: ValueKey(_tradeType),
                initialValue: _tradeType,
                decoration: const InputDecoration(labelText: 'Modalidad'),
                items: TradeType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_tradeTypeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (type) => setState(() => _tradeType = type!),
              ),
              if (_tradeType != TradeType.trade) ...[
                const SizedBox(height: 16),
                _field(
                  controller: _priceController,
                  label: 'Precio (€)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(_condition),
                initialValue: _condition,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: _conditions
                    .map(
                      (condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      ),
                    )
                    .toList(),
                onChanged: (condition) =>
                    setState(() => _condition = condition!),
              ),
              const SizedBox(height: 16),
              _field(
                controller: _locationController,
                label: 'Ubicación',
                hint: 'Ej. Valencia',
              ),
              const SizedBox(height: 16),
              _field(
                controller: _descriptionController,
                label: 'Descripción',
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _wantedController,
                label: '¿Qué buscas a cambio?',
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isSaving ? null : _publish,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.publish_outlined),
                label: Text(
                  _isSaving
                      ? 'Guardando...'
                      : widget.product == null
                      ? 'Publicar artículo'
                      : 'Guardar cambios',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Este campo es obligatorio.'
          : null,
    );
  }

  String _tradeTypeLabel(TradeType type) {
    return switch (type) {
      TradeType.trade => 'Trueque',
      TradeType.sale => 'Venta',
      TradeType.tradeAndMoney => 'Trueque + dinero',
    };
  }
}

const _categories = ['Electrónica', 'Moda', 'Hogar', 'Gaming', 'Deporte'];
const _conditions = ['Nuevo', 'Como nuevo', 'Buen estado', 'Usado'];

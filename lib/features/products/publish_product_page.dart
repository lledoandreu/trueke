import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/publish_product_provider.dart';
import '../../core/services/location_service.dart';

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});
  final ImageProvider image;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: image,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                minimumSize: const Size(28, 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

  static const _categories = [
    'Electrónica',
    'Moda',
    'Hogar',
    'Gaming',
    'Deporte',
    'Otros',
  ];
  static const _conditions = ['Nueva', 'Como nuevo', 'Buen estado', 'Usado'];

  String _category = 'Electrónica';
  String _condition = 'Buen estado';
  TradeType _tradeType = TradeType.trade;
  double? _latitude;
  double? _longitude;
  final List<XFile> _selectedImages = [];
  final List<String> _existingImages = [];

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
      _existingImages.addAll(product.images);
      _category = product.category;
      _condition = product.condition;
      _tradeType = product.tradeType;
      _latitude = product.latitude;
      _longitude = product.longitude;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
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
        for (final image in images) {
          if (!_selectedImages.any((selected) => selected.path == image.path)) {
            _selectedImages.add(image);
            ref
                .read(publishProductNotifierProvider.notifier)
                .setImages(
                  _selectedImages.map((img) => File(img.path)).toList(),
                );
          }
        }
      });
    }
  }

  void _removeSelectedImage(XFile image) {
    setState(() {
      _selectedImages.remove(image);
      if (_selectedImages.isEmpty) {
        ref.read(publishProductNotifierProvider.notifier).clearImages();
      } else {
        ref
            .read(publishProductNotifierProvider.notifier)
            .setImages(_selectedImages.map((img) => File(img.path)).toList());
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService().getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          if (_locationController.text.isEmpty ||
              _locationController.text == 'Ubicación GPS establecida') {
            _locationController.text = 'Ubicación GPS establecida';
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    if (_tradeType != TradeType.trade && (price == null || price <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un precio mayor que cero.')),
      );
      return;
    }

    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para publicar.')),
      );
      return;
    }

    if (widget.product != null) {
      await ref
          .read(publishProductNotifierProvider.notifier)
          .updateExistingProduct(
            productId: widget.product!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: _tradeType == TradeType.trade ? null : price,
            category: _category,
            owner: widget.product!.owner,
            ownerId: currentUserId,
            condition: _condition,
            tradeType: _tradeType,
            wanted: _wantedController.text.trim(),
            location: _locationController.text.trim(),
            latitude: _latitude,
            longitude: _longitude,
            existingImages: _existingImages,
            createdAt: widget.product!.createdAt,
          );
    } else {
      await ref
          .read(publishProductNotifierProvider.notifier)
          .submitProduct(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: _tradeType == TradeType.trade ? null : price,
            category: _category,
            owner: AuthService.currentUserLabel,
            ownerId: currentUserId,
            condition: _condition,
            tradeType: _tradeType,
            wanted: _wantedController.text.trim(),
            location: _locationController.text.trim(),
            latitude: _latitude,
            longitude: _longitude,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publishProductNotifierProvider);

    ref.listen<PublishProductState>(publishProductNotifierProvider, (
      previous,
      next,
    ) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? '¡Producto publicado con éxito!'
                  : 'Anuncio modificado con éxito.',
            ),
          ),
        );
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Publicar artículo' : 'Editar anuncio',
        ),
      ),
      body: state.isPublishing
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Fotos del producto',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._selectedImages.map(
                            (img) => _ImagePreview(
                              image: FileImage(File(img.path)),
                              onRemove: () => _removeSelectedImage(img),
                            ),
                          ),
                          IconButton(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_a_photo, size: 32),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(96, 96),
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _condition,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: _conditions
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _condition = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TradeType>(
                      initialValue: _tradeType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de intercambio',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: TradeType.trade,
                          child: Text('Trueque puro'),
                        ),
                        DropdownMenuItem(
                          value: TradeType.sale,
                          child: Text('Venta directa'),
                        ),
                        DropdownMenuItem(
                          value: TradeType.tradeAndMoney,
                          child: Text('Trueque + dinero'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _tradeType = v!),
                    ),
                    if (_tradeType != TradeType.trade) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio (€)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Campo obligatorio'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _wantedController,
                      decoration: const InputDecoration(
                        labelText: '¿Qué buscas a cambio?',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Ubicación',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _publish,
                      child: Text(
                        widget.product == null ? 'Publicar' : 'Guardar cambios',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

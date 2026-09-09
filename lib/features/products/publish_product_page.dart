import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/products_provider.dart';
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
  bool _isSaving = false;
  double? _latitude;
  double? _longitude;
  final List<XFile> _selectedImages = [];
  final List<String> _existingImages = [];
  final List<String> _removedImages = [];

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
          }
        }
      });
    }
  }

  void _removeExistingImage(String url) {
    setState(() {
      _existingImages.remove(url);
      if (!_removedImages.contains(url)) _removedImages.add(url);
    });
  }

  void _removeSelectedImage(XFile image) =>
      setState(() => _selectedImages.remove(image));

  Future<void> _getCurrentLocation() async {
    final position = await LocationService().getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text = 'Ubicación GPS establecida';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordenadas GPS obtenidas con éxito.')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron obtener las coordenadas GPS.'),
        ),
      );
    }
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
      final allImages = <String>[..._existingImages, ...uploadedImages];
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
        latitude: _latitude,
        longitude: _longitude,
      );

      if (existingProduct == null) {
        await ref.read(productsProvider.notifier).addProduct(product);
      } else {
        await ref.read(productsProvider.notifier).updateProduct(product);
      }
      persistenceCompleted = true;

      for (final url in _removedImages) {
        try {
          await ref.read(productsProvider.notifier).deleteProductImage(url);
        } catch (_) {}
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!persistenceCompleted) {
        for (final url in uploadedImages) {
          await ref.read(productsProvider.notifier).deleteProductImage(url);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el anuncio: $error')),
        );
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Ubicación (Ciudad o Zona)',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                          tooltip: 'Usar GPS actual',
                        ),
                      ],
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
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _condition,
                      decoration: const InputDecoration(
                        labelText: 'Estado del producto',
                      ),
                      items: _conditions
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _condition = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TradeType>(
                      initialValue: _tradeType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de intercambio',
                      ),
                      items: TradeType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t == TradeType.trade
                                    ? 'Trueque'
                                    : t == TradeType.sale
                                    ? 'Venta'
                                    : 'Trueque + €',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _tradeType = v);
                      },
                    ),
                    if (_tradeType != TradeType.trade) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio (€)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _wantedController,
                      decoration: const InputDecoration(
                        labelText: '¿Qué buscas a cambio? (Opcional)',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Imágenes del artículo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add_a_photo, size: 32),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ..._existingImages.map(
                            (url) => _ImagePreview(
                              image: NetworkImage(url),
                              onRemove: () => _removeExistingImage(url),
                            ),
                          ),
                          ..._selectedImages.map(
                            (file) => _ImagePreview(
                              image: FileImage(File(file.path)),
                              onRemove: () => _removeSelectedImage(file),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _publish,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.product == null
                            ? 'Publicar anuncio'
                            : 'Guardar cambios',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

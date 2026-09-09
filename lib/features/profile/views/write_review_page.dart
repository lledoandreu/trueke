import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reviews_provider.dart';

class WriteReviewPage extends ConsumerStatefulWidget {
  const WriteReviewPage({super.key, required this.receiverId});
  final String receiverId;

  @override
  ConsumerState<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends ConsumerState<WriteReviewPage> {
  final _commentController = TextEditingController();
  int _selectedRating = 5;
  bool _isSaving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Escribe un comentario.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .createReview(
            receiverId: widget.receiverId,
            rating: _selectedRating.toDouble(),
            comment: comment,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Valoración enviada con éxito!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar valoración: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dejar Valoración')),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '¿Cómo valorarías tu experiencia de trueque?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 1; i <= 5; i++)
                      IconButton(
                        icon: Icon(
                          i <= _selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 36,
                          color: Colors.amber,
                        ),
                        onPressed: () => setState(() => _selectedRating = i),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Tu comentario u opinión',
                    border: OutlineInputBorder(),
                    hintText: 'Excelente trueker, rápido y fiable...',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitReview,
                  child: const Text('Enviar Valoración'),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Proveedor autónomo que escucha los mensajes en tiempo real filtrados por conversación
final chatMessagesStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      conversationId,
    ) {
      final supabase = Supabase.instance.client;

      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
    });

// Proveedor automático para la acción de enviar mensajes nuevos
final chatSendProvider = Provider<Future<void> Function(String, String)>((ref) {
  final supabase = Supabase.instance.client;

  return (String conversationId, String text) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw StateError('Debes iniciar sesión para enviar un mensaje.');
    }

    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return;
    }

    await supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'text': cleanText,
    });
  };
});

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/storage_service.dart';
import '../../models/profile.dart';
import '../auth/auth_service.dart';
import 'providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, required this.profile});

  final Profile profile;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;

  File? _avatarFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.profile.displayName ?? '',
    );

    _usernameController = TextEditingController(
      text: widget.profile.username ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() {
      _avatarFile = File(image.path);
    });
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
    });

    try {
      String? avatarUrl = widget.profile.avatarUrl;

      if (_avatarFile != null) {
        final storage = StorageService(AuthService.supabase);

        avatarUrl = await storage.uploadAvatar(
          file: _avatarFile!,
          userId: widget.profile.id,
        );
      }

      final updated = widget.profile.copyWith(
        displayName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      await ref.read(profileRepositoryProvider).updateProfile(updated);

      ref.invalidate(profileProvider);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _avatarFile != null
                  ? FileImage(_avatarFile!)
                  : widget.profile.avatarUrl != null
                  ? NetworkImage(widget.profile.avatarUrl!)
                  : null,
              child: _avatarFile == null && widget.profile.avatarUrl == null
                  ? const Icon(Icons.camera_alt, size: 32)
                  : null,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre visible'),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Usuario'),
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserProfile profile) {
    if (!_isEditing) {
      _displayNameController.text = profile.displayName;
      _bioController.text = profile.bio ?? '';
    }
  }

  Future<void> _saveProfile(UserProfile currentProfile) async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = currentProfile.copyWith(
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final mutationNotifier = ref.read(profileMutationProvider.notifier);

    await mutationNotifier.updateProfile(profile: updatedProfile);

    if (mounted) {
      final state = ref.read(profileMutationProvider);
      if (!state.hasError) {
        setState(() => _isEditing = false);
        ref.invalidate(userProfileProvider(widget.userId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${state.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider(widget.userId));
    final mutationState = ref.watch(profileMutationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          profileAsync.when(
            data: (profile) => IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              tooltip: _isEditing ? 'Cancelar edición' : 'Editar perfil',
              onPressed: mutationState.isLoading
                  ? null
                  : () {
                      if (_isEditing) {
                        _initializeControllers(profile);
                      }
                      setState(() => _isEditing = !_isEditing);
                    },
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                    '¿Estás seguro de que quieres salir de Trueke?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authServiceProvider).signOut();
              }
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          _initializeControllers(profile);

          final avatarUrl = profile.avatarUrl;
          final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                    child: hasAvatar
                        ? null
                        : const Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.averageRating.toStringAsFixed(1)} (${profile.totalRatings} valoraciones)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(),
                    ),
                    enabled: _isEditing && !mutationState.isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre de usuario no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Biografía',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: _isEditing && !mutationState.isLoading,
                  ),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: mutationState.isLoading
                            ? null
                            : () => _saveProfile(profile),
                        child: mutationState.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Guardar Cambios'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error al cargar el perfil: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

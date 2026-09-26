import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/offers/presentation/screens/trade_offers_screen.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:trueke/features/transactions/presentation/screens/user_transactions_screen.dart';

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
    _displayNameController.text = profile.displayName;
    _bioController.text = profile.bio ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider(widget.userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: profileAsync.when(
        data: (profile) {
          _initializeControllers(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.swap_horizontal_circle,
                            color: Colors.teal,
                          ),
                          title: const Text('Mis Ofertas de Trueke'),
                          subtitle: const Text(
                            'Gestionar intercambios propuestos y recibidos',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TradeOffersScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.receipt_long,
                            color: Colors.blue,
                          ),
                          title: const Text('Historial de Transacciones'),
                          subtitle: const Text('Depósitos en Escrow'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserTransactionsScreen(
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('Error')),
      ),
    );
  }
}

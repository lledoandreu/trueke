import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return const AuthForm();
  }
}

class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key});

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      var signedInAfterSignUp = false;
      final authService = ref.read(authServiceProvider);

      if (_isLogin) {
        await authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        signedInAfterSignUp = await authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }

      if (!_isLogin && !signedInAfterSignUp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cuenta creada. Revisa tu correo para confirmar la cuenta.',
            ),
          ),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ha ocurrido un error. Inténtalo de nuevo.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Iniciar sesión' : 'Crear cuenta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.swap_horiz_rounded, size: 72),
              const SizedBox(height: 16),
              Text(
                'Trueke',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Entra en tu cuenta para continuar'
                    : 'Crea tu cuenta para empezar a usar Trueke',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce tu correo electrónico.';
                  }

                  if (!value.contains('@')) {
                    return 'Introduce un correo válido.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce una contraseña.';
                  }

                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isLogin ? 'Iniciar sesión' : 'Crear cuenta'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                child: Text(
                  _isLogin
                      ? '¿No tienes cuenta? Crear una'
                      : '¿Ya tienes cuenta? Iniciar sesión',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

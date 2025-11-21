import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/core/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/brand_logo.dart';
import 'package:verzus/widgets/verzus_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showForgotPasswordDialog() async {
    final controller =
        TextEditingController(text: _emailController.text.trim());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = controller.text.trim();
              if (email.isEmpty) return;
              try {
                // Note: Password reset is not in the repository,
                // as it's a direct auth action.
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Password reset link sent. Check your email.'),
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(FirebaseService.mapAuthError(e)),
                      backgroundColor: VerzusColors.dangerRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FirebaseService.mapAuthError(e)),
            backgroundColor: VerzusColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final cardWidth = maxWidth > 600 ? 500.0 : double.infinity;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Logo and Title
                        const Center(
                            child: SizedBox(
                                height: 40,
                                child: FittedBox(
                                    child: BrandTextLogo(height: 28)))),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back to the arena',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Email Field
                        VerzusTextField(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        VerzusTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                _isLoading ? null : _showForgotPasswordDialog,
                            child: Text(
                              'Forgot Password?',
                              style:
                                  TextStyle(color: VerzusColors.primaryPurple),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        VerzusButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          isLoading: _isLoading,
                          child: const Text('Sign In'),
                        ),

                        const SizedBox(height: 16),

                        // Sign Up Link (wrap to avoid overflow on tiny screens)
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () => context.go('/auth/signup'),
                              child: Text(
                                'Join the Arena',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: VerzusColors.primaryPurple,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Demo Mode Notice
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                VerzusColors.accentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: VerzusColors.accentGreen
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                color: VerzusColors.accentGreen,
                                size: 20,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Demo mode available - practice without real money!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: VerzusColors.accentGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

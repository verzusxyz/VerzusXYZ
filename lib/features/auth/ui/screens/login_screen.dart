import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/utils/responsive.dart';
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

  Future<void> _showForgotPasswordDialog(Responsive responsive) async {
    final controller = TextEditingController(text: _emailController.text.trim());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: VerzusTextField(
          controller: controller,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          VerzusButton.text(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          VerzusButton.primary(
            onPressed: () async {
              final email = controller.text.trim();
              if (email.isEmpty) return;
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent. Check your email.'),
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(FirebaseService.mapAuthError(e)),
                      backgroundColor: Theme.of(context).colorScheme.error,
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
            backgroundColor: Theme.of(context).colorScheme.error,
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
    final responsive = Responsive(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 500.0 : double.infinity),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.05)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: responsive.heightPercent(0.05)),

                        // Logo and Title
                        SizedBox(
                            height: responsive.diagonalPercent(0.05),
                            child: const FittedBox(child: BrandTextLogo(height: 28))),
                        SizedBox(height: responsive.heightPercent(0.01)),
                        Text(
                          'Welcome back to the arena',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: responsive.diagonalPercent(0.018),
                              ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: responsive.heightPercent(0.05)),

                        // Email Field
                        VerzusTextField(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your email';
                            if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: responsive.heightPercent(0.025)),

                        // Password Field
                        VerzusTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your password';
                            return null;
                          },
                        ),

                        SizedBox(height: responsive.heightPercent(0.015)),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: VerzusButton.text(
                            onPressed: _isLoading ? null : () => _showForgotPasswordDialog(responsive),
                            child: const Text('Forgot Password?'),
                          ),
                        ),

                        SizedBox(height: responsive.heightPercent(0.03)),

                        // Login Button
                        VerzusButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          isLoading: _isLoading,
                          child: const Text('Sign In'),
                        ),

                        SizedBox(height: responsive.heightPercent(0.02)),

                        // Sign Up Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: responsive.widthPercent(0.01),
                          children: [
                            Text(
                              "Don't have an account?",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: responsive.diagonalPercent(0.017),
                                  ),
                            ),
                            GestureDetector(
                              onTap: _isLoading ? null : () => context.go('/auth/signup'),
                              child: Text(
                                'Join the Arena',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsive.diagonalPercent(0.017),
                                    ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: responsive.heightPercent(0.03)),

                        // Demo Mode Notice
                        Container(
                          padding: EdgeInsets.all(responsive.diagonalPercent(0.02)),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                color: Theme.of(context).colorScheme.secondary,
                                size: responsive.diagonalPercent(0.025),
                              ),
                              SizedBox(height: responsive.heightPercent(0.01)),
                              Text(
                                'Demo mode available - practice without real money!',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: responsive.diagonalPercent(0.016),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.heightPercent(0.02)),
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

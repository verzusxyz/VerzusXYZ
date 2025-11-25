import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/core/constants/countries.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/brand_logo.dart';
import 'package:verzus/widgets/verzus_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _referralCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedCountry = 'US';
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms of Service'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);

      final userCredential = await authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        await authRepository.createUserProfile(
          uid: userCredential.user!.uid,
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          displayName: _displayNameController.text.trim(),
          country: _selectedCountry,
          referredBy: _referralCodeController.text.trim(),
        );
      }

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
                  'Enter the ultimate skill arena',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: responsive.diagonalPercent(0.018),
                      ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: responsive.heightPercent(0.05)),

                // Display Name
                VerzusTextField(
                  controller: _displayNameController,
                  label: 'Display Name',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your display name';
                    if (value.length < 2) return 'Display name must be at least 2 characters';
                    return null;
                  },
                ),
                SizedBox(height: responsive.heightPercent(0.02)),

                // Username
                VerzusTextField(
                  controller: _usernameController,
                  label: 'Username',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a username';
                    if (value.length < 3) return 'Username must be at least 3 characters';
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),
                SizedBox(height: responsive.heightPercent(0.02)),

                // Email
                VerzusTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: responsive.heightPercent(0.02)),

                // Country Selection
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  items: countries.map((country) {
                    return DropdownMenuItem(value: country['code'], child: Text(country['name']!));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedCountry = value);
                  },
                ),
                SizedBox(height: responsive.heightPercent(0.02)),

                // Password
                VerzusTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: colorScheme.onSurfaceVariant),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a password';
                    if (value.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                SizedBox(height: responsive.heightPercent(0.02)),

                // Confirm Password
                VerzusTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: colorScheme.onSurfaceVariant),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: responsive.heightPercent(0.02)),

                // Referral Code (Optional)
                VerzusTextField(
                  controller: _referralCodeController,
                  label: 'Referral Code (Optional)',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSignUp(),
                ),

                SizedBox(height: responsive.heightPercent(0.025)),

                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                      activeColor: colorScheme.primary,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: responsive.diagonalPercent(0.015),
                              ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: responsive.heightPercent(0.04)),

                // Sign Up Button
                VerzusButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  isLoading: _isLoading,
                  child: const Text('Create Account'),
                ),

                SizedBox(height: responsive.heightPercent(0.025)),

                // Login Link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: responsive.widthPercent(0.01),
                  children: [
                    Text(
                      'Already have an account?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: responsive.diagonalPercent(0.017),
                          ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () => context.go('/auth/login'),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: responsive.diagonalPercent(0.017),
                            ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: responsive.heightPercent(0.05)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

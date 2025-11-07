import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/theme.dart';
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

  final List<Map<String, String>> _countries = [
    {'code': 'AF', 'name': 'Afghanistan'},
    {'code': 'AL', 'name': 'Albania'},
    {'code': 'DZ', 'name': 'Algeria'},
    {'code': 'AS', 'name': 'American Samoa'},
    {'code': 'AD', 'name': 'Andorra'},
    {'code': 'AO', 'name': 'Angola'},
    {'code': 'AI', 'name': 'Anguilla'},
    {'code': 'AG', 'name': 'Antigua and Barbuda'},
    {'code': 'AR', 'name': 'Argentina'},
    {'code': 'AM', 'name': 'Armenia'},
    {'code': 'AW', 'name': 'Aruba'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'AT', 'name': 'Austria'},
    {'code': 'AZ', 'name': 'Azerbaijan'},
    {'code': 'BS', 'name': 'Bahamas'},
    {'code': 'BH', 'name': 'Bahrain'},
    {'code': 'BD', 'name': 'Bangladesh'},
    {'code': 'BB', 'name': 'Barbados'},
    {'code': 'BY', 'name': 'Belarus'},
    {'code': 'BE', 'name': 'Belgium'},
    {'code': 'BZ', 'name': 'Belize'},
    {'code': 'BJ', 'name': 'Benin'},
    {'code': 'BM', 'name': 'Bermuda'},
    {'code': 'BT', 'name': 'Bhutan'},
    {'code': 'BO', 'name': 'Bolivia'},
    {'code': 'BA', 'name': 'Bosnia and Herzegovina'},
    {'code': 'BW', 'name': 'Botswana'},
    {'code': 'BR', 'name': 'Brazil'},
    {'code': 'VG', 'name': 'British Virgin Islands'},
    {'code': 'BN', 'name': 'Brunei Darussalam'},
    {'code': 'BG', 'name': 'Bulgaria'},
    {'code': 'BF', 'name': 'Burkina Faso'},
    {'code': 'BI', 'name': 'Burundi'},
    {'code': 'KH', 'name': 'Cambodia'},
    {'code': 'CM', 'name': 'Cameroon'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'CV', 'name': 'Cape Verde'},
    {'code': 'KY', 'name': 'Cayman Islands'},
    {'code': 'CF', 'name': 'Central African Republic'},
    {'code': 'TD', 'name': 'Chad'},
    {'code': 'CL', 'name': 'Chile'},
    {'code': 'CN', 'name': 'China'},
    {'code': 'CO', 'name': 'Colombia'},
    {'code': 'KM', 'name': 'Comoros'},
    {'code': 'CG', 'name': 'Congo'},
    {'code': 'CD', 'name': 'Congo, Democratic Republic'},
    {'code': 'CR', 'name': 'Costa Rica'},
    {'code': 'CI', 'name': "Côte d'Ivoire"},
    {'code': 'HR', 'name': 'Croatia'},
    {'code': 'CU', 'name': 'Cuba'},
    {'code': 'CY', 'name': 'Cyprus'},
    {'code': 'CZ', 'name': 'Czechia'},
    {'code': 'DK', 'name': 'Denmark'},
    {'code': 'DJ', 'name': 'Djibouti'},
    {'code': 'DM', 'name': 'Dominica'},
    {'code': 'DO', 'name': 'Dominican Republic'},
    {'code': 'EC', 'name': 'Ecuador'},
    {'code': 'EG', 'name': 'Egypt'},
    {'code': 'SV', 'name': 'El Salvador'},
    {'code': 'GQ', 'name': 'Equatorial Guinea'},
    {'code': 'ER', 'name': 'Eritrea'},
    {'code': 'EE', 'name': 'Estonia'},
    {'code': 'SZ', 'name': 'Eswatini'},
    {'code': 'ET', 'name': 'Ethiopia'},
    {'code': 'FO', 'name': 'Faroe Islands'},
    {'code': 'FJ', 'name': 'Fiji'},
    {'code': 'FI', 'name': 'Finland'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'GF', 'name': 'French Guiana'},
    {'code': 'PF', 'name': 'French Polynesia'},
    {'code': 'GA', 'name': 'Gabon'},
    {'code': 'GM', 'name': 'Gambia'},
    {'code': 'GE', 'name': 'Georgia'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'GH', 'name': 'Ghana'},
    {'code': 'GI', 'name': 'Gibraltar'},
    {'code': 'GR', 'name': 'Greece'},
    {'code': 'GL', 'name': 'Greenland'},
    {'code': 'GD', 'name': 'Grenada'},
    {'code': 'GP', 'name': 'Guadeloupe'},
    {'code': 'GU', 'name': 'Guam'},
    {'code': 'GT', 'name': 'Guatemala'},
    {'code': 'GG', 'name': 'Guernsey'},
    {'code': 'GN', 'name': 'Guinea'},
    {'code': 'GW', 'name': 'Guinea-Bissau'},
    {'code': 'GY', 'name': 'Guyana'},
    {'code': 'HT', 'name': 'Haiti'},
    {'code': 'HN', 'name': 'Honduras'},
    {'code': 'HK', 'name': 'Hong Kong'},
    {'code': 'HU', 'name': 'Hungary'},
    {'code': 'IS', 'name': 'Iceland'},
    {'code': 'IN', 'name': 'India'},
    {'code': 'ID', 'name': 'Indonesia'},
    {'code': 'IR', 'name': 'Iran'},
    {'code': 'IQ', 'name': 'Iraq'},
    {'code': 'IE', 'name': 'Ireland'},
    {'code': 'IM', 'name': 'Isle of Man'},
    {'code': 'IL', 'name': 'Israel'},
    {'code': 'IT', 'name': 'Italy'},
    {'code': 'JM', 'name': 'Jamaica'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'JE', 'name': 'Jersey'},
    {'code': 'JO', 'name': 'Jordan'},
    {'code': 'KZ', 'name': 'Kazakhstan'},
    {'code': 'KE', 'name': 'Kenya'},
    {'code': 'KI', 'name': 'Kiribati'},
    {'code': 'KW', 'name': 'Kuwait'},
    {'code': 'KG', 'name': 'Kyrgyzstan'},
    {'code': 'LA', 'name': "Lao People's Democratic Republic"},
    {'code': 'LV', 'name': 'Latvia'},
    {'code': 'LB', 'name': 'Lebanon'},
    {'code': 'LS', 'name': 'Lesotho'},
    {'code': 'LR', 'name': 'Liberia'},
    {'code': 'LY', 'name': 'Libya'},
    {'code': 'LI', 'name': 'Liechtenstein'},
    {'code': 'LT', 'name': 'Lithuania'},
    {'code': 'LU', 'name': 'Luxembourg'},
    {'code': 'MO', 'name': 'Macao'},
    {'code': 'MG', 'name': 'Madagascar'},
    {'code': 'MW', 'name': 'Malawi'},
    {'code': 'MY', 'name': 'Malaysia'},
    {'code': 'MV', 'name': 'Maldives'},
    {'code': 'ML', 'name': 'Mali'},
    {'code': 'MT', 'name': 'Malta'},
    {'code': 'MH', 'name': 'Marshall Islands'},
    {'code': 'MQ', 'name': 'Martinique'},
    {'code': 'MR', 'name': 'Mauritania'},
    {'code': 'MU', 'name': 'Mauritius'},
    {'code': 'YT', 'name': 'Mayotte'},
    {'code': 'MX', 'name': 'Mexico'},
    {'code': 'FM', 'name': 'Micronesia, Federated States'},
    {'code': 'MD', 'name': 'Moldova'},
    {'code': 'MC', 'name': 'Monaco'},
    {'code': 'MN', 'name': 'Mongolia'},
    {'code': 'ME', 'name': 'Montenegro'},
    {'code': 'MS', 'name': 'Montserrat'},
    {'code': 'MA', 'name': 'Morocco'},
    {'code': 'MZ', 'name': 'Mozambique'},
    {'code': 'MM', 'name': 'Myanmar'},
    {'code': 'NA', 'name': 'Namibia'},
    {'code': 'NR', 'name': 'Nauru'},
    {'code': 'NP', 'name': 'Nepal'},
    {'code': 'NL', 'name': 'Netherlands'},
    {'code': 'NC', 'name': 'New Caledonia'},
    {'code': 'NZ', 'name': 'New Zealand'},
    {'code': 'NI', 'name': 'Nicaragua'},
    {'code': 'NE', 'name': 'Niger'},
    {'code': 'NG', 'name': 'Nigeria'},
    {'code': 'MP', 'name': 'Northern Mariana Islands'},
    {'code': 'NO', 'name': 'Norway'},
    {'code': 'OM', 'name': 'Oman'},
    {'code': 'PK', 'name': 'Pakistan'},
    {'code': 'PW', 'name': 'Palau'},
    {'code': 'PS', 'name': 'Palestine, State of'},
    {'code': 'PA', 'name': 'Panama'},
    {'code': 'PG', 'name': 'Papua New Guinea'},
    {'code': 'PY', 'name': 'Paraguay'},
    {'code': 'PE', 'name': 'Peru'},
    {'code': 'PH', 'name': 'Philippines'},
    {'code': 'PL', 'name': 'Poland'},
    {'code': 'PT', 'name': 'Portugal'},
    {'code': 'PR', 'name': 'Puerto Rico'},
    {'code': 'QA', 'name': 'Qatar'},
    {'code': 'RE', 'name': 'Réunion'},
    {'code': 'RO', 'name': 'Romania'},
    {'code': 'RU', 'name': 'Russian Federation'},
    {'code': 'RW', 'name': 'Rwanda'},
    {'code': 'KN', 'name': 'Saint Kitts and Nevis'},
    {'code': 'LC', 'name': 'Saint Lucia'},
    {'code': 'VC', 'name': 'Saint Vincent and the Grenadines'},
    {'code': 'WS', 'name': 'Samoa'},
    {'code': 'SM', 'name': 'San Marino'},
    {'code': 'ST', 'name': 'Sao Tome and Principe'},
    {'code': 'SA', 'name': 'Saudi Arabia'},
    {'code': 'SN', 'name': 'Senegal'},
    {'code': 'RS', 'name': 'Serbia'},
    {'code': 'SC', 'name': 'Seychelles'},
    {'code': 'SL', 'name': 'Sierra Leone'},
    {'code': 'SG', 'name': 'Singapore'},
    {'code': 'SX', 'name': 'Sint Maarten'},
    {'code': 'SK', 'name': 'Slovakia'},
    {'code': 'SI', 'name': 'Slovenia'},
    {'code': 'SB', 'name': 'Solomon Islands'},
    {'code': 'SO', 'name': 'Somalia'},
    {'code': 'ZA', 'name': 'South Africa'},
    {'code': 'KR', 'name': 'South Korea'},
    {'code': 'SS', 'name': 'South Sudan'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'LK', 'name': 'Sri Lanka'},
    {'code': 'SD', 'name': 'Sudan'},
    {'code': 'SR', 'name': 'Suriname'},
    {'code': 'SE', 'name': 'Sweden'},
    {'code': 'CH', 'name': 'Switzerland'},
    {'code': 'SY', 'name': 'Syrian Arab Republic'},
    {'code': 'TW', 'name': 'Taiwan'},
    {'code': 'TJ', 'name': 'Tajikistan'},
    {'code': 'TZ', 'name': 'Tanzania, United Republic of'},
    {'code': 'TH', 'name': 'Thailand'},
    {'code': 'TL', 'name': 'Timor-Leste'},
    {'code': 'TG', 'name': 'Togo'},
    {'code': 'TO', 'name': 'Tonga'},
    {'code': 'TT', 'name': 'Trinidad and Tobago'},
    {'code': 'TN', 'name': 'Tunisia'},
    {'code': 'TR', 'name': 'Türkiye'},
    {'code': 'TM', 'name': 'Turkmenistan'},
    {'code': 'TC', 'name': 'Turks and Caicos Islands'},
    {'code': 'TV', 'name': 'Tuvalu'},
    {'code': 'UG', 'name': 'Uganda'},
    {'code': 'UA', 'name': 'Ukraine'},
    {'code': 'AE', 'name': 'United Arab Emirates'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'UY', 'name': 'Uruguay'},
    {'code': 'UZ', 'name': 'Uzbekistan'},
    {'code': 'VU', 'name': 'Vanuatu'},
    {'code': 'VE', 'name': 'Venezuela'},
    {'code': 'VN', 'name': 'Viet Nam'},
    {'code': 'VI', 'name': 'Virgin Islands, U.S.'},
    {'code': 'YE', 'name': 'Yemen'},
    {'code': 'ZM', 'name': 'Zambia'},
    {'code': 'ZW', 'name': 'Zimbabwe'},
  ];

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
        const SnackBar(
          content: Text('Please accept the Terms of Service'),
          backgroundColor: VerzusColors.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      
      await authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
        username: _usernameController.text.trim(),
        country: _selectedCountry,
        referredBy: _referralCodeController.text.trim().isNotEmpty 
          ? _referralCodeController.text.trim()
          : null,
      );
      
      if (mounted) {
        context.go('/');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo and Title
                const Center(child: SizedBox(height: 40, child: FittedBox(child: BrandTextLogo(height: 28)))),
                const SizedBox(height: 8),
                Text(
                  'Enter the ultimate skill arena',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Display Name
                VerzusTextField(
                  controller: _displayNameController,
                  label: 'Display Name',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your display name';
                    }
                    if (value.length < 2) {
                      return 'Display name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Username
                VerzusTextField(
                  controller: _usernameController,
                  label: 'Username',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email
                VerzusTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Country Selection
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: VerzusColors.primaryPurple, width: 2),
                    ),
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country['code'],
                      child: Text(country['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCountry = value);
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password
                VerzusTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password
                VerzusTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Referral Code (Optional)
                VerzusTextField(
                  controller: _referralCodeController,
                  label: 'Referral Code (Optional)',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSignUp(),
                ),
                
                const SizedBox(height: 20),
                
                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() => _acceptedTerms = value ?? false);
                      },
                      activeColor: VerzusColors.primaryPurple,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: VerzusColors.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: VerzusColors.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign Up Button
                VerzusButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  isLoading: _isLoading,
                  child: const Text('Create Account'),
                ),
                
                const SizedBox(height: 20),
                
                // Login Link (wrap to avoid overflow on tiny screens)
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      'Already have an account?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () => context.go('/auth/login'),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: VerzusColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
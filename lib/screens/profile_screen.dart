import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/account_integration_service.dart';

/// Profile screen for viewing and editing account information
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isChangingPassword = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authState = ref.read(authStateProvider);
    authState.whenData((user) {
      if (user != null) {
        _displayNameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      }
    });
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final integrationService = ref.read(accountIntegrationServiceProvider);
      await integrationService.updateProfile(
        displayName:
            _displayNameController.text.trim().isEmpty
                ? null
                : _displayNameController.text.trim(),
      );

      setState(() {
        _isEditing = false;
        _successMessage = 'Profile updated successfully';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();

    if (newEmail.isEmpty || !newEmail.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final integrationService = ref.read(accountIntegrationServiceProvider);
      await integrationService.updateEmail(newEmail);

      setState(() {
        _isEditing = false;
        _successMessage =
            'Email updated successfully. Please verify your new email.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your current password';
      });
      return;
    }

    if (_newPasswordController.text.length < 8) {
      setState(() {
        _errorMessage = 'New password must be at least 8 characters';
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final integrationService = ref.read(accountIntegrationServiceProvider);
      await integrationService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      setState(() {
        _isChangingPassword = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _successMessage = 'Password changed successfully';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone and will delete all your data.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Account'),
              ),
            ],
          ),
    );

    if (!mounted) return;
    if (confirmed != true) return;

    // Ask for password confirmation
    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        final passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your password to confirm account deletion:'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, passwordController.text),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (password == null || password.isEmpty) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final integrationService = ref.read(accountIntegrationServiceProvider);
      await integrationService.deleteAccount(password);

      // User will be automatically logged out and redirected by auth state change
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing && !_isChangingPassword)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _errorMessage = null;
                  _successMessage = null;
                });
              },
            ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile photo
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.primary,
                        backgroundImage:
                            user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                        child:
                            user.photoURL == null
                                ? Text(
                                  (user.displayName ?? user.email ?? 'U')[0]
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 48,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                                : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: theme.colorScheme.secondary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 20),
                              onPressed: () {
                                // TODO: Implement photo upload
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Photo upload coming soon!'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Success/Error messages
                if (_successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Account Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        // Display Name
                        TextField(
                          controller: _displayNameController,
                          enabled: _isEditing && !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                            enabled: _isEditing,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextField(
                          controller: _emailController,
                          enabled: _isEditing && !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: const OutlineInputBorder(),
                            enabled: _isEditing,
                            helperText:
                                _isEditing
                                    ? 'Changing email requires re-verification'
                                    : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // User ID (read-only)
                        TextField(
                          controller: TextEditingController(text: user.uid),
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            prefixIcon: Icon(Icons.fingerprint),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Provider info
                        Wrap(
                          spacing: 8,
                          children:
                              user.providerData.map((info) {
                                IconData icon;
                                String label;
                                switch (info.providerId) {
                                  case 'google.com':
                                    icon = Icons.g_mobiledata;
                                    label = 'Google';
                                    break;
                                  case 'password':
                                    icon = Icons.lock;
                                    label = 'Email/Password';
                                    break;
                                  default:
                                    icon = Icons.account_circle;
                                    label = info.providerId;
                                }
                                return Chip(
                                  avatar: Icon(icon, size: 16),
                                  label: Text(label),
                                );
                              }).toList(),
                        ),

                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () {
                                            setState(() {
                                              _isEditing = false;
                                              _loadUserData();
                                              _errorMessage = null;
                                            });
                                          },
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () async {
                                            await _updateProfile();
                                            if (_emailController.text.trim() !=
                                                user.email) {
                                              await _updateEmail();
                                            }
                                          },
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Change Password Section (only for email/password users)
                if (user.providerData.any((p) => p.providerId == 'password'))
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          if (!_isChangingPassword)
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isChangingPassword = true;
                                  _errorMessage = null;
                                  _successMessage = null;
                                });
                              },
                              icon: const Icon(Icons.lock_reset),
                              label: const Text('Change Password'),
                            )
                          else ...[
                            TextField(
                              controller: _currentPasswordController,
                              obscureText: true,
                              enabled: !_isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Current Password',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _newPasswordController,
                              obscureText: true,
                              enabled: !_isLoading,
                              decoration: const InputDecoration(
                                labelText: 'New Password',
                                border: OutlineInputBorder(),
                                helperText: 'At least 8 characters',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              enabled: !_isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Confirm New Password',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () {
                                              setState(() {
                                                _isChangingPassword = false;
                                                _currentPasswordController
                                                    .clear();
                                                _newPasswordController.clear();
                                                _confirmPasswordController
                                                    .clear();
                                                _errorMessage = null;
                                              });
                                            },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _changePassword,
                                    child:
                                        _isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text('Update Password'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Danger Zone
                Card(
                  color: Colors.red.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Danger Zone',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Once you delete your account, there is no going back. Please be certain.',
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _deleteAccount,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Delete Account'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';
import '../models/account.dart';
import '../services/account_integration_service.dart';
import 'profile/profile_screen.dart';
import 'export_screen.dart';
import 'auth/login_screen.dart';

/// Static test account ID for persistence testing
const kTestAccountId = 'dev-test-account-001';
const kTestAccountEmail = 'test@ashtrail.dev';
const kTestAccountName = 'Test User';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('\n═══════════════════════════════════════════════════');
    debugPrint('🔵 [AccountsScreen] BUILD START at ${DateTime.now()}');
    debugPrint('═══════════════════════════════════════════════════\n');

    final accountsAsync = ref.watch(allAccountsProvider);
    final activeAccountAsync = ref.watch(activeAccountProvider);
    final loggedInAccountsAsync = ref.watch(loggedInAccountsProvider);

    debugPrint(
      '🔍 [AccountsScreen] accountsAsync state: ${accountsAsync.runtimeType}',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            tooltip: 'Import / Export',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ExportScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          // Sign out all accounts
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'sign_out_all') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Sign Out All Accounts'),
                        content: const Text(
                          'This will sign out all accounts. Your data will be preserved.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sign Out All'),
                          ),
                        ],
                      ),
                );

                if (confirmed == true && context.mounted) {
                  try {
                    final integrationService = ref.read(
                      accountIntegrationServiceProvider,
                    );
                    await integrationService.signOut();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $e')),
                      );
                    }
                  }
                }
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'sign_out_all',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Sign Out All'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (List<Account> accounts) {
          debugPrint('\n📋 [AccountsScreen.body] Rendering DATA state');
          debugPrint('   📊 Total accounts: ${accounts.length}');

          final activeAccount = activeAccountAsync.maybeWhen(
            data: (account) => account,
            orElse: () => null,
          );

          final loggedInAccounts = loggedInAccountsAsync.maybeWhen(
            data: (accounts) => accounts,
            orElse: () => <Account>[],
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Logged-in accounts section
              if (loggedInAccounts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Logged In (${loggedInAccounts.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                ...loggedInAccounts.map((account) {
                  final isActive = account.userId == activeAccount?.userId;
                  return _buildAccountCard(
                    context,
                    ref,
                    account,
                    isActive,
                    true,
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Other accounts section (logged out but data preserved)
              ...() {
                final otherAccounts =
                    accounts
                        .where((a) => !a.isLoggedIn && !a.isAnonymous)
                        .toList();
                if (otherAccounts.isEmpty) return <Widget>[];
                return [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Other Accounts',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  ...otherAccounts.map((account) {
                    return _buildAccountCard(
                      context,
                      ref,
                      account,
                      false,
                      false,
                    );
                  }),
                  const SizedBox(height: 16),
                ];
              }(),

              // Add account button
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_add,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('Add Another Account'),
                  subtitle: const Text('Sign in to add another profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ),

              if (accounts.isEmpty) _buildEmptyState(context, ref),
            ],
          );
        },
        loading: () {
          debugPrint('\n⏳ [AccountsScreen.body] Rendering LOADING state');
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          debugPrint('\n❌ [AccountsScreen.body] Rendering ERROR state');
          debugPrint('   Error: $error');
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    Account account,
    bool isActive,
    bool isLoggedIn,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isActive
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            isActive
                ? null
                : isLoggedIn
                ? () async {
                  // Switch to this account
                  await ref
                      .read(accountSwitcherProvider.notifier)
                      .switchAccount(account.userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Switched to ${account.displayName ?? account.email}',
                        ),
                      ),
                    );
                  }
                }
                : () {
                  // Re-sign in to this account
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                    backgroundImage:
                        account.photoUrl != null
                            ? NetworkImage(account.photoUrl!)
                            : null,
                    child:
                        account.photoUrl == null
                            ? Text(
                              (account.displayName ?? account.email)[0]
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isActive
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                            : null,
                  ),
                  if (isLoggedIn)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Account info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName ?? account.email,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive
                          ? 'Active • ${account.email}'
                          : isLoggedIn
                          ? 'Tap to switch • ${account.email}'
                          : 'Tap to sign in • ${account.email}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    if (account.authProvider.name != 'anonymous')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              _getProviderIcon(account.authProvider),
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getProviderName(account.authProvider),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Actions
              if (isActive)
                Icon(Icons.check_circle, color: theme.colorScheme.primary)
              else if (isLoggedIn)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onSelected: (value) async {
                    if (value == 'sign_out') {
                      await _signOutSingleAccount(context, ref, account);
                    } else if (value == 'delete') {
                      await _deleteAccount(context, ref, account);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'sign_out',
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text('Sign Out'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProviderIcon(authProvider) {
    switch (authProvider.toString()) {
      case 'AuthProvider.gmail':
        return Icons.g_mobiledata;
      case 'AuthProvider.apple':
        return Icons.apple;
      case 'AuthProvider.email':
        return Icons.email;
      default:
        return Icons.person;
    }
  }

  String _getProviderName(authProvider) {
    switch (authProvider.toString()) {
      case 'AuthProvider.gmail':
        return 'Google';
      case 'AuthProvider.apple':
        return 'Apple';
      case 'AuthProvider.email':
        return 'Email';
      case 'AuthProvider.anonymous':
        return 'Anonymous';
      default:
        return 'Unknown';
    }
  }

  Future<void> _signOutSingleAccount(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: Text(
              'Sign out of ${account.displayName ?? account.email}?\n\n'
              'Your data will be preserved and you can sign back in anytime.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(accountSwitcherProvider.notifier)
            .signOutAccount(account.userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Signed out of ${account.displayName ?? account.email}',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
        }
      }
    }
  }

  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: Text(
              'Delete ${account.displayName ?? account.email}?\n\n'
              'This will permanently delete all data associated with this account. '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(accountSwitcherProvider.notifier)
            .deleteAccount(account.userId);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Account deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
        }
      }
    }
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text('No Accounts', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Sign in to start tracking',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add Account'),
          ),
        ],
      ),
    );
  }
}

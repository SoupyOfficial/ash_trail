import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../models/account.dart';
import 'profile/profile_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(allAccountsProvider);
    final activeAccountAsync = ref.watch(activeAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
              );

              if (confirmed == true && context.mounted) {
                try {
                  final authService = ref.read(authServiceProvider);
                  await authService.signOut();
                  // Navigation handled automatically by auth state change
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error logging out: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return _buildEmptyState(context);
          }

          return activeAccountAsync.when(
            data:
                (activeAccount) => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    final isActive = account.userId == activeAccount?.userId;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                          child: Text(
                            (account.displayName ?? account.email)[0]
                                .toUpperCase(),
                            style: TextStyle(
                              color:
                                  isActive
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        title: Text(account.displayName ?? account.email),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.email),
                            if (isActive)
                              Text(
                                'Active',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing:
                            isActive
                                ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                                : IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    _showAccountOptions(context, ref, account);
                                  },
                                ),
                        onTap:
                            isActive
                                ? null
                                : () async {
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
                                },
                      ),
                    );
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text('No Accounts', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Your account will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountOptions(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Set as Active'),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref
                        .read(accountSwitcherProvider.notifier)
                        .switchAccount(account.userId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Account'),
                  textColor: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Delete Account'),
                            content: Text(
                              'Are you sure you want to delete ${account.displayName ?? account.email}? '
                              'This will also delete all associated log entries.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      await ref
                          .read(accountSwitcherProvider.notifier)
                          .deleteAccount(account.userId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account deleted')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }
}

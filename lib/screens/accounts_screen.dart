import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../models/account.dart';
import '../models/enums.dart';
import '../services/log_record_service.dart';
import 'profile/profile_screen.dart';
import 'export_screen.dart';

/// Static test account ID for persistence testing
const kTestAccountId = 'dev-test-account-001';
const kTestAccountEmail = 'test@ashtrail.dev';
const kTestAccountName = 'Test User';

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
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () async {
              final activeAccount = await ref.read(
                activeAccountProvider.future,
              );
              final isAnonymous = activeAccount?.isAnonymous ?? false;

              if (!context.mounted) return;

              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: Text(
                        isAnonymous
                            ? 'Logging out will delete your anonymous account and all data. This cannot be undone.'
                            : 'Are you sure you want to log out?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style:
                              isAnonymous
                                  ? FilledButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  )
                                  : null,
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
              );

              if (confirmed == true && context.mounted) {
                try {
                  if (isAnonymous && activeAccount != null) {
                    // For anonymous users, delete the account
                    await ref
                        .read(accountSwitcherProvider.notifier)
                        .deleteAccount(activeAccount.userId);
                  } else {
                    // For authenticated users, sign out from Firebase
                    final authService = ref.read(authServiceProvider);
                    await authService.signOut();
                  }
                  // Navigation handled automatically by auth/account state change
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
            return _buildEmptyState(context, ref);
          }

          // Read active account synchronously to avoid nested loading states
          final activeAccount = activeAccountAsync.maybeWhen(
            data: (account) => account,
            orElse: () => null,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                                  ).colorScheme.surfaceContainerHighest,
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
              ),
              // Developer tools section
              _buildDevToolsSection(context, ref),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDevToolsSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.developer_mode,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Developer Tools',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _createTestAccount(context, ref),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Create Test Account'),
              ),
              OutlinedButton.icon(
                onPressed: () => _createSampleLogs(context, ref),
                icon: const Icon(Icons.add_chart, size: 18),
                label: const Text('Add Sample Logs'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createTestAccount(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(accountServiceProvider);

      // Check if test account already exists
      final existing = await service.getAccountByUserId(kTestAccountId);
      if (existing != null) {
        // Just switch to it
        await ref
            .read(accountSwitcherProvider.notifier)
            .switchAccount(kTestAccountId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Switched to existing test account'),
              backgroundColor: Colors.blue,
            ),
          );
        }
        return;
      }

      // Create new test account with static ID for persistence testing
      final testAccount = Account.create(
        userId: kTestAccountId,
        email: kTestAccountEmail,
        displayName: kTestAccountName,
        authProvider: AuthProvider.devStatic,
        isActive: true,
      );

      await service.saveAccount(testAccount);
      await service.setActiveAccount(kTestAccountId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test account created and activated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating test account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSampleLogs(BuildContext context, WidgetRef ref) async {
    try {
      final activeAccount = await ref.read(activeAccountProvider.future);
      if (activeAccount == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active account - create one first'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Create log record service
      final logService = LogRecordService();

      // Create sample logs for the past 7 days
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: i));
        // 2-4 logs per day
        final logsPerDay = 2 + (i % 3);
        for (int j = 0; j < logsPerDay; j++) {
          await logService.createLogRecord(
            accountId: activeAccount.userId,
            eventType: EventType.vape,
            eventAt: day.subtract(Duration(hours: j * 4 + 8)),
            duration: 20 + (j * 10).toDouble(),
            unit: Unit.seconds,
            moodRating: 5 + (j % 4).toDouble(),
            physicalRating: 6 + (j % 3).toDouble(),
          );
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Created sample logs for past 7 days'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating sample logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            'Your account will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _createTestAccount(context, ref),
            icon: const Icon(Icons.person_add),
            label: const Text('Create Test Account'),
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

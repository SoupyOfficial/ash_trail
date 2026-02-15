import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/log_record.dart';
import '../providers/account_provider.dart';
import '../providers/log_record_provider.dart';

/// Dialog for transferring a log record to another logged-in account.
///
/// If only one other account is logged in, skips the picker and goes
/// straight to confirmation. Otherwise shows a list of accounts to choose.
class TransferLogDialog extends ConsumerStatefulWidget {
  final LogRecord record;

  const TransferLogDialog({super.key, required this.record});

  @override
  ConsumerState<TransferLogDialog> createState() => _TransferLogDialogState();
}

class _TransferLogDialogState extends ConsumerState<TransferLogDialog> {
  Account? _selectedAccount;
  bool _isTransferring = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loggedInAccounts = ref.watch(loggedInAccountsProvider);

    return loggedInAccounts.when(
      data: (accounts) {
        // Filter out the current account
        final otherAccounts =
            accounts.where((a) => a.userId != widget.record.accountId).toList();

        if (otherAccounts.isEmpty) {
          return AlertDialog(
            title: const Text('Transfer Log'),
            content: const Text(
              'No other accounts are logged in. '
              'Log in to another account first to transfer this log.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }

        // If only one other account, skip the picker
        if (otherAccounts.length == 1 && _selectedAccount == null) {
          _selectedAccount = otherAccounts.first;
        }

        return AlertDialog(
          title: const Text('Transfer Log'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (otherAccounts.length > 1) ...[
                  Text(
                    'Select the account to transfer this log to:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ...otherAccounts.map(
                    (account) => _AccountTile(
                      account: account,
                      isSelected: _selectedAccount?.userId == account.userId,
                      onTap: () {
                        setState(() {
                          _selectedAccount = account;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_selectedAccount != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer this log to ${_selectedAccount!.displayName ?? _selectedAccount!.email}?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The log will be moved from your history to theirs. '
                          'Its date and time (${DateFormat('MMM d, y h:mm a').format(widget.record.eventAt)}) '
                          'will be preserved and will appear in their analytics for that date.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isTransferring ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  _selectedAccount != null && !_isTransferring
                      ? _performTransfer
                      : null,
              child:
                  _isTransferring
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Transfer'),
            ),
          ],
        );
      },
      loading:
          () => const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load accounts: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _performTransfer() async {
    if (_selectedAccount == null || _isTransferring) return;

    setState(() => _isTransferring = true);

    try {
      final newRecord = await ref
          .read(logRecordNotifierProvider.notifier)
          .transferLogRecord(widget.record, _selectedAccount!.userId);

      if (!mounted) return;

      // Pop the transfer dialog
      Navigator.pop(context, true);

      if (newRecord != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Log transferred to ${_selectedAccount!.displayName ?? _selectedAccount!.email}',
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                await ref
                    .read(logRecordNotifierProvider.notifier)
                    .undoTransfer(newRecord);
                ref.invalidate(activeAccountLogRecordsProvider);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isTransferring = false);
      }
    }
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color:
          isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              account.photoUrl != null ? NetworkImage(account.photoUrl!) : null,
          child:
              account.photoUrl == null
                  ? Text(
                    (account.displayName ?? account.email)
                        .substring(0, 1)
                        .toUpperCase(),
                  )
                  : null,
        ),
        title: Text(account.displayName ?? account.email),
        subtitle: account.displayName != null ? Text(account.email) : null,
        trailing:
            isSelected
                ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                : null,
        onTap: onTap,
      ),
    );
  }
}

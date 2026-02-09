import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';
import '../providers/account_provider.dart';
import '../services/token_service.dart';

/// A diagnostics screen for TestFlight builds that surfaces the full
/// multi-account state: logged-in accounts, custom token validity,
/// Firebase Auth state, and cloud function connectivity.
///
/// Access this from the Accounts screen overflow menu or via a deep-link.
class MultiAccountDiagnosticsScreen extends ConsumerStatefulWidget {
  const MultiAccountDiagnosticsScreen({super.key});

  @override
  ConsumerState<MultiAccountDiagnosticsScreen> createState() =>
      _MultiAccountDiagnosticsScreenState();
}

class _MultiAccountDiagnosticsScreenState
    extends ConsumerState<MultiAccountDiagnosticsScreen> {
  static final _log = AppLogger.logger('Diagnostics');

  Map<String, dynamic>? _diagnostics;
  bool _isLoading = true;
  bool _isCheckingEndpoint = false;
  bool? _endpointReachable;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessionManager = ref.read(accountSessionManagerProvider);
      final diagnostics = await sessionManager.getDiagnosticSummary();

      // Add Firebase Auth info
      final firebaseUser = FirebaseAuth.instance.currentUser;
      diagnostics['firebaseAuth'] = {
        'uid': firebaseUser?.uid,
        'email': firebaseUser?.email,
        'displayName': firebaseUser?.displayName,
        'isAnonymous': firebaseUser?.isAnonymous,
        'providers':
            firebaseUser?.providerData.map((p) => p.providerId).toList(),
        'emailVerified': firebaseUser?.emailVerified,
        'creationTime': firebaseUser?.metadata.creationTime?.toIso8601String(),
        'lastSignInTime':
            firebaseUser?.metadata.lastSignInTime?.toIso8601String(),
      };

      setState(() {
        _diagnostics = diagnostics;
        _isLoading = false;
      });

      _log.w(
        '[DIAGNOSTICS_SCREEN] Loaded diagnostics: '
        'firebaseUid=${firebaseUser?.uid}, '
        'loggedIn=${diagnostics['loggedInCount']}',
      );
    } catch (e) {
      _log.e('[DIAGNOSTICS_SCREEN] Error loading diagnostics', error: e);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkEndpoint() async {
    setState(() => _isCheckingEndpoint = true);
    try {
      final tokenService = ref.read(tokenServiceProvider);
      final reachable = await tokenService.isEndpointReachable();
      setState(() {
        _endpointReachable = reachable;
        _isCheckingEndpoint = false;
      });
      _log.w('[DIAGNOSTICS_SCREEN] Cloud Function reachable: $reachable');
    } catch (e) {
      setState(() {
        _endpointReachable = false;
        _isCheckingEndpoint = false;
      });
    }
  }

  String _formatDiagnostics() {
    if (_diagnostics == null) return 'No diagnostics available';
    final buffer = StringBuffer();
    buffer.writeln('=== Multi-Account Diagnostics ===');
    buffer.writeln('Time: ${_diagnostics!['timestamp']}');
    buffer.writeln('');

    // Firebase Auth
    final fb = _diagnostics!['firebaseAuth'] as Map<String, dynamic>?;
    if (fb != null) {
      buffer.writeln('--- Firebase Auth ---');
      buffer.writeln('UID: ${fb['uid']}');
      buffer.writeln('Email: ${fb['email']}');
      buffer.writeln('DisplayName: ${fb['displayName']}');
      buffer.writeln('Providers: ${fb['providers']}');
      buffer.writeln('Last Sign-In: ${fb['lastSignInTime']}');
      buffer.writeln('');
    }

    // Accounts
    buffer.writeln(
      '--- Logged-In Accounts (${_diagnostics!['loggedInCount']}) ---',
    );
    buffer.writeln('Active User: ${_diagnostics!['activeUserId']}');
    final accounts = _diagnostics!['loggedInAccounts'] as List?;
    if (accounts != null) {
      for (final a in accounts) {
        buffer.writeln('  ${a['email']} (${a['provider']}) uid=${a['userId']}');
      }
    }
    buffer.writeln('');

    // Token Status
    final tokens = _diagnostics!['tokenStatus'] as Map<String, dynamic>?;
    if (tokens != null && tokens.isNotEmpty) {
      buffer.writeln('--- Token Status ---');
      for (final entry in tokens.entries) {
        final t = entry.value as Map<String, dynamic>;
        buffer.writeln('  ${t['email']}:');
        buffer.writeln('    Valid: ${t['hasValidToken']}');
        buffer.writeln('    Age: ${t['tokenAgeHours']}h');
        buffer.writeln('    Remaining: ${t['tokenRemainingHours']}h');
        buffer.writeln('    Provider: ${t['authProvider']}');
        buffer.writeln('    Active: ${t['isActive']}');
      }
    }
    buffer.writeln('');

    // Logging config
    final logging = _diagnostics!['logging'] as Map<String, dynamic>?;
    if (logging != null) {
      buffer.writeln('--- Logging ---');
      buffer.writeln('Verbose: ${logging['verboseLogging']}');
      buffer.writeln('Debug Mode: ${logging['kDebugMode']}');
      buffer.writeln('Level: ${logging['loggerLevel']}');
      buffer.writeln('Active Loggers: ${logging['activeLoggers']}');
    }

    if (_endpointReachable != null) {
      buffer.writeln('');
      buffer.writeln('--- Cloud Function ---');
      buffer.writeln('Reachable: $_endpointReachable');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Account Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy to clipboard',
            onPressed: () {
              final text = _formatDiagnostics();
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diagnostics copied to clipboard'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiagnostics,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Firebase Auth Section
                  _buildSection(
                    context,
                    'Firebase Auth',
                    Icons.security,
                    _buildFirebaseAuthInfo(theme),
                  ),
                  const SizedBox(height: 12),

                  // Logged-In Accounts Section
                  _buildSection(
                    context,
                    'Logged-In Accounts (${_diagnostics!['loggedInCount']})',
                    Icons.people,
                    _buildAccountsList(theme),
                  ),
                  const SizedBox(height: 12),

                  // Token Status Section
                  _buildSection(
                    context,
                    'Custom Token Status',
                    Icons.vpn_key,
                    _buildTokenStatus(theme),
                  ),
                  const SizedBox(height: 12),

                  // Cloud Function Health
                  _buildSection(
                    context,
                    'Cloud Function Health',
                    Icons.cloud,
                    _buildCloudFunctionHealth(theme),
                  ),
                  const SizedBox(height: 12),

                  // Logging Config
                  _buildSection(
                    context,
                    'Logging Configuration',
                    Icons.bug_report,
                    _buildLoggingInfo(theme),
                  ),
                ],
              ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseAuthInfo(ThemeData theme) {
    final fb = _diagnostics!['firebaseAuth'] as Map<String, dynamic>?;
    if (fb == null) return const Text('No Firebase Auth data');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('UID', fb['uid']?.toString() ?? 'null'),
        _infoRow('Email', fb['email']?.toString() ?? 'null'),
        _infoRow('Display Name', fb['displayName']?.toString() ?? 'null'),
        _infoRow('Providers', fb['providers']?.toString() ?? 'null'),
        _infoRow('Email Verified', fb['emailVerified']?.toString() ?? 'null'),
        _infoRow('Last Sign-In', fb['lastSignInTime']?.toString() ?? 'null'),
      ],
    );
  }

  Widget _buildAccountsList(ThemeData theme) {
    final accounts = _diagnostics!['loggedInAccounts'] as List?;
    if (accounts == null || accounts.isEmpty) {
      return Text(
        'No accounts logged in',
        style: TextStyle(color: theme.colorScheme.error),
      );
    }

    final activeUserId = _diagnostics!['activeUserId'];

    return Column(
      children:
          accounts.map<Widget>((a) {
            final isActive = a['userId'] == activeUserId;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isActive ? Colors.green : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          a['email'] ?? 'unknown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${a['provider']} · ${a['userId']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTokenStatus(ThemeData theme) {
    final tokens = _diagnostics!['tokenStatus'] as Map<String, dynamic>?;
    if (tokens == null || tokens.isEmpty) {
      return Text(
        'No token data',
        style: TextStyle(color: theme.colorScheme.error),
      );
    }

    return Column(
      children:
          tokens.entries.map<Widget>((entry) {
            final t = entry.value as Map<String, dynamic>;
            final valid = t['hasValidToken'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    valid
                        ? Colors.green.withValues(alpha: 0.05)
                        : Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      valid
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        valid ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: valid ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t['email'] ?? entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _infoRow('Valid', valid.toString()),
                  if (t['tokenAgeHours'] != null)
                    _infoRow('Age', '${t['tokenAgeHours']}h'),
                  if (t['tokenRemainingHours'] != null)
                    _infoRow('Remaining', '${t['tokenRemainingHours']}h'),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCloudFunctionHealth(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Token generation endpoint (Cloud Function)',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (_isCheckingEndpoint)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_endpointReachable != null)
              Icon(
                _endpointReachable! ? Icons.check_circle : Icons.error,
                color: _endpointReachable! ? Colors.green : Colors.red,
                size: 16,
              ),
            const SizedBox(width: 8),
            Text(
              _endpointReachable == null
                  ? 'Not checked'
                  : _endpointReachable!
                  ? 'REACHABLE'
                  : 'UNREACHABLE',
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: _isCheckingEndpoint ? null : _checkEndpoint,
              child: const Text('Test'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoggingInfo(ThemeData theme) {
    final logging = _diagnostics!['logging'] as Map<String, dynamic>?;
    if (logging == null) return const Text('No logging data');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          'Verbose Logging',
          logging['verboseLogging']?.toString() ?? 'unknown',
        ),
        _infoRow('Debug Mode', logging['kDebugMode']?.toString() ?? 'unknown'),
        _infoRow('Log Level', logging['loggerLevel']?.toString() ?? 'unknown'),
        _infoRow(
          'Active Loggers',
          (logging['activeLoggers'] as List?)?.length.toString() ?? '0',
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

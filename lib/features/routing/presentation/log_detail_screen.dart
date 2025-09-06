import 'package:flutter/material.dart';

class LogDetailScreen extends StatelessWidget {
  const LogDetailScreen({super.key, required this.logId});
  final String logId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log $logId')),
      body: Center(
        child: Text('Details for log id: $logId'),
      ),
    );
  }
}

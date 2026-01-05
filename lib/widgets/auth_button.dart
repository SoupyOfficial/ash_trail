import 'package:flutter/material.dart';

/// Industry-standard authentication button widget
/// Supports different button styles (Google, Apple, Email)
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AuthButtonType type;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.type,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side:
                type == AuthButtonType.email
                    ? BorderSide(color: Colors.grey.shade300)
                    : BorderSide.none,
          ),
          elevation: type == AuthButtonType.email ? 0 : 2,
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getForegroundColor(),
                    ),
                  ),
                )
                : Row(
                  children: [
                    if (type != AuthButtonType.email) ...[
                      _getIcon(),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AuthButtonType.google:
        return Colors.white;
      case AuthButtonType.apple:
        return Colors.black;
      case AuthButtonType.email:
        return Colors.white;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case AuthButtonType.google:
        return Colors.black87;
      case AuthButtonType.apple:
        return Colors.white;
      case AuthButtonType.email:
        return Colors.black87;
    }
  }

  Widget _getIcon() {
    switch (type) {
      case AuthButtonType.google:
        return SizedBox(
          width: 24,
          height: 24,
          child: Image.asset(
            'assets/google_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to Google "G" text if image fails to load
              return const Text(
                'G',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              );
            },
          ),
        );
      case AuthButtonType.apple:
        return const Icon(Icons.apple, size: 24);
      case AuthButtonType.email:
        return const Icon(Icons.email_outlined, size: 24);
    }
  }
}

enum AuthButtonType { google, apple, email }

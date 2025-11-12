import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error loading image: $error',
      liveRegion: true,
      container: true,
      child: Container(
        key: const ValueKey('error_container'),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../style/app_layout.dart';

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
          borderRadius: BorderRadius.circular(AppLayout.spacingMedium(context)),
        ),
        child: Center(
          child: Padding(
            padding: AppLayout.contentPadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    size: AppLayout.materialButtonHeight,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                SizedBox(height: AppLayout.spacingMedium(context)),
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

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDisplay extends StatelessWidget {
  final String message;

  const LoadingDisplay(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      liveRegion: true,
      container: true,
      child: Container(
        key: const ValueKey('loading_container'),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: SpinKitWaveSpinner(
                  key: const ValueKey('wave_spinner'),
                  color: Theme.of(context).colorScheme.primary,
                  size: 50.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

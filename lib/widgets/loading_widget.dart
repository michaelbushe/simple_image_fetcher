import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../style/app_layout.dart';

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
          borderRadius: BorderRadius.circular(AppLayout.spacingMedium(context)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: SpinKitWaveSpinner(
                  key: const ValueKey('wave_spinner'),
                  color: Theme.of(context).colorScheme.primary,
                  size: AppLayout.materialButtonHeight,
                ),
              ),
              SizedBox(height: AppLayout.spacingMedium(context)),
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

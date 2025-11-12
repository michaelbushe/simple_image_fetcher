import 'package:button_m3e/button_m3e.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import '../state/image_state.dart';

/// Button to fetch another image
///
/// This widget reacts to the ImageState and disables itself
/// when an image is being loaded.
class AnotherImageButton extends StatelessWidget {
  static const String buttonText = 'Another';

  const AnotherImageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ImageState imageState = context.read<ImageState>();
    final bool isIOSStyle = Theme.of(context).platform == TargetPlatform.iOS;

    return Watch((context) {
      final isLoading = imageState.isLoading.value;
      final semanticLabel = isLoading
          ? 'Loading new image, please wait'
          : 'Get another random image';

      return Semantics(
        button: true,
        enabled: !isLoading,
        label: semanticLabel,
        hint: isLoading ? null : 'Double tap to fetch a new random image',
        excludeSemantics: true,
        child: isIOSStyle
            ? CupertinoButton.filled(
                key: const ValueKey('another_button_ios'),
                onPressed: isLoading ? null : () => imageState.fetchNextImage(),
                child: const Text(buttonText),
              )
            : ButtonM3E(
                key: const ValueKey('another_button_android'),
                label: const Text(buttonText),
                //requirements just say "Another" not icon
                // icon: const Icon(Icons.navigate_next),
                size: ButtonM3ESize.md,
                shape: ButtonM3EShape.round,
                onPressed: isLoading ? null : () => imageState.fetchNextImage(),
              ),
      );
    });
  }
}

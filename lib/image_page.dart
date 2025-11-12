import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import 'state/image_state.dart';
import 'widgets/image_display.dart';
import 'widgets/another_image_button.dart';
import 'widgets/settings_panel.dart';

/// Page that shows a centered image and a button to fetch another image
///
/// This is the main page that coordinates the layout and animations.
/// Presentation of individual components is performed by respective widgets.
/// Business logic and state management are in ImageState.
class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<StatefulWidget> createState() => ImagePageState();
}

class ImagePageState extends State<ImagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;
  bool _isInitialized = false;
  VoidCallback? _disposeEffect;

  @override
  void initState() {
    super.initState();
    // Initialize color animation controller with faster timing
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    ImageState imageState = context.read<ImageState>();

    _colorAnimation =
        ColorTween(
          begin: imageState.lastBackgroundColor.value,
          end: imageState.backgroundColor.value,
        ).animate(
          CurvedAnimation(
            parent: _colorAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // Listen to background color changes to trigger animation
    _disposeEffect = effect(() {
      final newColor = imageState.backgroundColor.value;
      final oldColor = imageState.lastBackgroundColor.value;

      if (newColor != oldColor) {
        debugPrint('Background color changed, triggering animation');

        final adjustedNewColor = imageState.getAdjustedBackgroundColor(
          context,
          newColor,
        );
        final adjustedOldColor = imageState.getAdjustedBackgroundColor(
          context,
          oldColor,
        );

        _animateBackgroundColor(
          oldBackgroundColor: adjustedOldColor,
          newBackgroundColor: adjustedNewColor,
        );
      }
    });
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _disposeEffect?.call();
    super.dispose();
  }

  /// Animate the background color when a new image loads
  void _animateBackgroundColor({
    required Color oldBackgroundColor,
    required Color newBackgroundColor,
  }) {
    if (!mounted) {
      return;
    }

    // Only animate if the color actually changed
    if (newBackgroundColor == oldBackgroundColor) {
      debugPrint('No change in background color, skipping animation');
      return;
    }

    debugPrint('Animating background color change');

    // Animate to the new color
    setState(() {
      _colorAnimation =
          ColorTween(
            begin: _colorAnimation.value ?? oldBackgroundColor,
            end: newBackgroundColor,
          ).animate(
            CurvedAnimation(
              parent: _colorAnimationController,
              curve: Curves.easeInOut,
            ),
          );
    });

    _colorAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    final ImageState imageState = context.read<ImageState>();

    return Watch((context) {
      final currentBackgroundColor = imageState.backgroundColor.value;
      final adjustedColor = imageState.getAdjustedBackgroundColor(
        context,
        currentBackgroundColor,
      );

      return AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: _colorAnimation.value ?? adjustedColor,
            body: Semantics(
              label: 'Image Fetcher App',
              container: true,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate available space for the image
                    final buttonHeight = isLandscape ? 56.0 : 60.0;
                    final verticalPadding = isLandscape ? 16.0 : 32.0;
                    final horizontalPadding = isLandscape ? 48.0 : 32.0;

                    final availableHeight =
                        constraints.maxHeight - buttonHeight - verticalPadding;
                    final availableWidth =
                        constraints.maxWidth - horizontalPadding;

                    // Calculate the square size that fits within available space
                    final imageSize = math.min(
                      math.min(availableWidth, availableHeight),
                      isLandscape
                          ? constraints.maxHeight * 0.7
                          : constraints.maxHeight * 0.6,
                    );

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding / 2,
                            vertical: verticalPadding / 2,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Image container - ImageDisplay handles its own fade
                              Semantics(
                                label: 'Image display area',
                                child: SizedBox(
                                  width: imageSize,
                                  height: imageSize,
                                  child: ImageDisplay(
                                    key: const ValueKey('image_display'),
                                    size: imageSize,
                                  ),
                                ),
                              ),
                              SizedBox(height: isLandscape ? 16 : 24),
                              // Button
                              const AnotherImageButton(
                                key: ValueKey('another_button'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showSettingsPanel(context),
              tooltip: 'Settings',
              child: const Icon(Icons.settings),
            ),
          );
        },
      );
    });
  }

  /// Show the settings panel as a modal bottom sheet
  void _showSettingsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsPanel(),
    );
  }
}

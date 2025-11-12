import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:random_image/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import '../state/image_state.dart';
import 'error_widget.dart';

/// Widget that displays an image with loading and error states
///
/// This is a presentational component that reacts to the ImageState
/// and displays the appropriate UI based on the current state.
class ImageDisplay extends StatelessWidget {
  final double size;

  const ImageDisplay({required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    final ImageState imageState = context.read<ImageState>();
    return Watch((context) {
      final error = imageState.error.value;
      final currentImageUrl = imageState.currentImageUrl.value;
      final isLoading = imageState.isLoading.value;
      final loadingMessage = imageState.loadingMessage.value;

      // Show error state
      if (error != null) {
        return ErrorDisplay(error: error);
      }

      if (isLoading) {
        return LoadingDisplay(loadingMessage ?? 'Loading image...');
      }

      // Show the image - CachedNetworkImage handles its own fade when loaded
      if (currentImageUrl == null) {
        // Fallback loading state, shouldn't get here.
        return LoadingDisplay(loadingMessage ?? 'No image.');
      } else {
        return Semantics(
          image: true,
          label: 'Random image from Unsplash',
          liveRegion: true,
          child: ClipRRect(
            key: ValueKey('image_$currentImageUrl'),
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: currentImageUrl,
              fit: BoxFit.cover,
              maxHeightDiskCache: 1000,
              maxWidthDiskCache: 1000,
              memCacheHeight: 1000,
              memCacheWidth: 1000,
              // Smooth fade when image actually loads from network/cache
              fadeInDuration: const Duration(milliseconds: 400),
              fadeOutDuration: const Duration(milliseconds: 200),
              errorWidget: (context, url, error) {
                debugPrint('Image load error for $url: $error');
                return Semantics(
                  label: 'Failed to load image from network',
                  child: Container(
                    key: const ValueKey('image_error_container'),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExcludeSemantics(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        ;
      }
    });
  }
}

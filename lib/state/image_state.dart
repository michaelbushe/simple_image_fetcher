import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:signals/signals_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../service/image_service.dart';
import '../style/style_constants.dart';

/// State management for image fetching and display, uses Signals
/// The key here is the backgroundColor is computed after image load
/// so when the backgroundColor changes, then the image and color
/// animations can be trigger simultaneously.
class ImageState {
  static const minLoadingMS = 250;

  final ImageUrlService _imageUrlService = ImageUrlService();
  final bool useSemanticAnnouncements;

  final currentImageUrl = signal<String?>(null);
  final currentImageProvider = signal<CachedNetworkImageProvider?>(null);
  final isLoading = signal<bool>(false);
  final error = signal<String?>(null);
  final backgroundColor = signal<Color>(appColor);
  final lastBackgroundColor = signal<Color>(appColor);

  /// Computed signal, returns loading message when loading, null otherwise
  late final loadingMessage = computed(() {
    if (!isLoading.value) {
      return null;
    }

    if (_hasImageUrl()) {
      return 'Loading next image...';
    } else {
      // First load message doesn't have 'next'
      return 'Loading image...';
    }
  });

  bool _hasImageUrl() => currentImageUrl.value != null;

  /// Create the ImageState.
  /// useSemanticAnnouncements - true if platform support spoken announcements
  ImageState({required this.useSemanticAnnouncements}) {
    fetchNextImage();
  }

  /// Fetch the next image from the service
  Future<void> fetchNextImage() async {
    if (isLoading.value) {
      return;
    }

    error.value = null;
    isLoading.value = true;

    final startTime = DateTime.now();

    try {
      final nextUrl = await _imageUrlService.nextUrl();

      if (nextUrl == null) {
        error.value =
            'Unable to load image. Please check your internet connection and try again.';
        isLoading.value = false;
        _semanticAnnounce('Failed to load image');
        return;
      } else {
        debugPrint('nextUrl: $nextUrl');
      }
      final imageProvider = CachedNetworkImageProvider(nextUrl);

      final ui.Image? loadedImage = await _loadImage(imageProvider);

      if (loadedImage == null) {
        debugPrint('[ERROR] Failed to load image');
        error.value = 'Failed to load image. Please try again.';
        isLoading.value = false;
        _semanticAnnounce('Failed to load image');
        return;
      }

      final Color? extractedColor = await _extractColors(loadedImage);
      loadedImage.dispose();

      if (extractedColor != null) {
        updateBackgroundColor(extractedColor);
      }

      // Ensure minimum loading time for better UX (prevents 'loading' flashing)
      if (startTime.millisecond < minLoadingMS) {
        await Future.delayed(
          Duration(milliseconds: minLoadingMS - startTime.millisecond),
        );
      }

      currentImageUrl.value = nextUrl;
      currentImageProvider.value = imageProvider;
      error.value = null;
      isLoading.value = false;

      _semanticAnnounce('New image loaded');
    } on Exception catch (e) {
      debugPrint('[ERROR] Error fetching image: $e');
      error.value =
          'Failed to load image. Please try again or check your network connection.';
      _semanticAnnounce('Failed to load image');
      isLoading.value = false;
    } catch (e) {
      debugPrint('[ERROR] Unexpected error fetching image: $e');
      error.value = 'An unexpected error occurred. Please try again.';
      SemanticsService.announce('Error occurred', TextDirection.ltr);
      isLoading.value = false;
    }
  }

  /// Load the image from the provider
  /// Returns the ui.Image or null if loading fails
  Future<ui.Image?> _loadImage(CachedNetworkImageProvider imageProvider) async {
    try {
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      final completer = Completer<ui.Image>();
      late ImageStreamListener listener;

      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
          imageStream.removeListener(listener);
        },
        onError: (exception, stackTrace) {
          completer.completeError(exception, stackTrace);
          imageStream.removeListener(listener);
        },
      );

      imageStream.addListener(listener);
      final ui.Image image = await completer.future;

      return image;
    } catch (e) {
      debugPrint('[ERROR] Error loading image: $e');
      return null;
    }
  }

  /// Sample image pixels in an X pattern to get representative colors
  /// from all regions - center, edges, and corners
  Future<Color?> _extractColors(ui.Image image) async {
    try {
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        debugPrint('[ERROR] Failed to get pixel data from image');
        return null;
      }

      final int width = image.width;
      final int height = image.height;

      int totalRed = 0;
      int totalGreen = 0;
      int totalBlue = 0;
      int sampleCount = 0;

      // Sample points along both diagonals (X pattern)
      // This ensures we cover all regions: corners, edges, and center
      final int samplesPerDiagonal = 10;

      // First diagonal: top-left to bottom-right
      for (int i = 0; i < samplesPerDiagonal; i++) {
        final double t = i / (samplesPerDiagonal - 1);
        final int x = (t * width).toInt().clamp(0, width - 1);
        final int y = (t * height).toInt().clamp(0, height - 1);

        final int offset = (y * width + x) * 4;
        totalRed += byteData.getUint8(offset);
        totalGreen += byteData.getUint8(offset + 1);
        totalBlue += byteData.getUint8(offset + 2);
        sampleCount++;
      }

      // Second diagonal: top-right to bottom-left
      for (int i = 0; i < samplesPerDiagonal; i++) {
        final double t = i / (samplesPerDiagonal - 1);
        final int x = ((1.0 - t) * width).toInt().clamp(0, width - 1);
        final int y = (t * height).toInt().clamp(0, height - 1);

        final int offset = (y * width + x) * 4;
        totalRed += byteData.getUint8(offset);
        totalGreen += byteData.getUint8(offset + 1);
        totalBlue += byteData.getUint8(offset + 2);
        sampleCount++;
      }

      // Calculate average color
      final int avgRed = totalRed ~/ sampleCount;
      final int avgGreen = totalGreen ~/ sampleCount;
      final int avgBlue = totalBlue ~/ sampleCount;

      final Color extractedColor = Color.fromARGB(
        255,
        avgRed,
        avgGreen,
        avgBlue,
      );

      debugPrint('[COLOR] Sampled ${sampleCount} points in X pattern');
      debugPrint('[COLOR] Extracted color: $extractedColor');

      return extractedColor;
    } catch (e) {
      debugPrint('[ERROR] Error extracting colors: $e');
      return null;
    }
  }

  /// Get the background color adjusted for theme brightness
  Color getAdjustedBackgroundColor(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adjustedColor = isDark
        ? Color.alphaBlend(color.withValues(alpha: 0.5), Colors.black)
        : Color.alphaBlend(color.withValues(alpha: 0.4), Colors.white);

    return adjustedColor;
  }

  /// Update the background color after extracting from image
  void updateBackgroundColor(Color color) {
    lastBackgroundColor.value = backgroundColor.value;
    backgroundColor.value = color;
  }

  // whether to use Semantic announce to screen readers - deprecated on android
  // app uses MediaQuery to pass the value down to reduce checking.
  bool _useSemanticAnnounce() {
    // Don't use on Android (deprecated) or web (not supported consistently)
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) return false;
    return useSemanticAnnouncements;
  }

  void _semanticAnnounce(String message) {
    if (_useSemanticAnnounce()) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  /// Dispose resources
  void dispose() {
    currentImageUrl.dispose();
    currentImageProvider.dispose();
    isLoading.dispose();
    error.dispose();
    backgroundColor.dispose();
    lastBackgroundColor.dispose();
  }
}

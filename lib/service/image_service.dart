import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Fetches and image url using the GET /image endpoint described in Swagger:
/// https://november7-730026606190.europe-west1.run.app/docs#/default/get_random_image_image__get
//
// Example Response:
//
// {"url": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"}
class ImageUrlService {
  final dio = Dio();

  final String nextImageAPIUrl =
      'https://november7-730026606190.europe-west1.run.app/image/';

  // returns a url for the next random image, null on error
  Future<String?> nextUrl() async {
    try {
      final response = await dio.get(
        nextImageAPIUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final url = response.data['url'] as String?;

      if (url == null || url.isEmpty) {
        debugPrint('Invalid response: URL is null or empty');
        return null;
      }

      return url;
    } on DioException catch (e, s) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        debugPrint(
          'HTTP Error (${e.response?.statusCode}): ${e.response?.statusMessage}\n'
          'Response: ${e.response?.data}\n'
          'Headers: ${e.response?.headers}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        debugPrint('Request timeout: ${e.message}');
      } else if (e.type == DioExceptionType.connectionError) {
        debugPrint(
          'Connection error - network may be unavailable: ${e.message}',
        );
      } else {
        debugPrint(
          'Network error: ${e.message}\n'
          'Request options: ${e.requestOptions.uri}',
        );
      }
      debugPrintStack(stackTrace: s);
      return null;
    } catch (e, s) {
      debugPrint('Unexpected error in nextUrl: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }
}

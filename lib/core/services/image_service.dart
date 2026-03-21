import '../constants/api_constants.dart';

class ImageService {
  static String? toPublicUrl(String? path) {
    if (path == null) return null;

    final s = path.trim();
    if (s.isEmpty) return null;

    if (s.startsWith('http://') || s.startsWith('https://')) {
      return s;
    }

    if (s.startsWith('/')) {
      return '${ApiConstants.baseUrl}$s';
    }

    if (s.startsWith('uploads/')) {
      return '${ApiConstants.baseUrl}/$s';
    }

    return '${ApiConstants.baseUrl}/uploads/$s';
  }

  static String withFallback(
      String? path, {
        String fallback = '/imagesforapp/logo2.png',
      }) {
    return toPublicUrl(path) ?? '${ApiConstants.baseUrl}$fallback';
  }
}
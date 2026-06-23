import 'package:aquaponic/core/network/api_client.dart';

/// Handles authentication: login, session check, and logout.
class AuthService {
  /// Login with email & password.
  /// Returns the full response map on success.
  /// Throws [ApiException] on failure.
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final data = await ApiClient.post(
      '/auth/login',
      auth: false,
      body: {'email': email, 'password': password},
    );

    // Save tokens for subsequent requests
    await ApiClient.saveTokens(
      accessToken: data['token'],
      refreshToken: data['refresh_token'],
    );

    return Map<String, dynamic>.from(data);
  }

  /// Check currently authenticated user.
  /// Returns user profile map, or null if not authenticated.
  static Future<Map<String, dynamic>?> me() async {
    try {
      final data = await ApiClient.get('/auth/me');
      return Map<String, dynamic>.from(data);
    } on ApiException catch (e) {
      if (e.statusCode == 401) return null;
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// Logout the current session on the server side and clear local tokens.
  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout');
    } catch (_) {
      // Even if server logout fails, clear local tokens
    }
    await ApiClient.clearTokens();
  }

  /// Check if a token exists locally (quick check without network).
  static Future<bool> hasToken() async {
    final token = await ApiClient.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

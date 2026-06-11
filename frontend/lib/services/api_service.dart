// frontend/lib/services/api_service.dart
//
// Adicionados:
//   - fetchLibraryBooks(): chama /api/v1/books/library (L1/L4)
//   - fetchTopRatedMovies(): chama /api/v1/movies/top-rated (F3)
// Correções:
//   - kBaseUrl dinâmico para Web/Emulador
//   - _extractListSafe para lidar com JSONs aninhados do Google Books

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// Para dispositivo físico Android, defina a variável de ambiente BACKEND_URL
// com o IP da sua máquina (ex: http://192.168.1.100:8000) no arquivo .env
// ou altere a constante abaixo diretamente.
const String _kEnvBackendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');

String get kBaseUrl {
  if (_kEnvBackendUrl.isNotEmpty) return _kEnvBackendUrl;
  if (kIsWeb) return 'http://127.0.0.1:8000';
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000';
  return 'http://127.0.0.1:8000';
}

const Duration _kTimeout = Duration(seconds: 15);

class ApiService {
  static final _client = http.Client();

  // Sessão em memória
  static int? currentUserId;
  static int? currentProfileId;
  static String currentProfileName = '';
  static String currentProfileAvatar = '';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// Força HTTPS nas URLs de imagem
  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.replaceFirst('http://', 'https://');
  }

  /// Detecta domínio público por data (< 1928) ou palavras-chave
  static bool isPublicDomain(
      String? publishedDate, String? title, String? description) {
    if (publishedDate != null && publishedDate.length >= 4) {
      final year = int.tryParse(publishedDate.substring(0, 4));
      if (year != null && year < 1928) return true;
    }
    final combined = '${title ?? ''} ${description ?? ''}'.toLowerCase();
    return combined.contains('public domain') ||
        combined.contains('domínio público') ||
        combined.contains('dominio publico');
  }

  // -----------------------------------------------------------------------
  // Auth
  // -----------------------------------------------------------------------
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String passwordHash,
  }) async {
    final uri = Uri.parse('$kBaseUrl/api/v1/users/login');
    final response = await _client
        .post(uri,
            headers: _headers,
            body: jsonEncode({'email': email, 'password_hash': passwordHash}))
        .timeout(_kTimeout);
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createUser({
    required String username,
    required String email,
    required String passwordHash,
  }) async {
    final uri = Uri.parse('$kBaseUrl/api/v1/users');
    final response = await _client.post(uri,
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password_hash': passwordHash
        }));
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // -----------------------------------------------------------------------
  // Perfis
  // -----------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchProfiles(int userId) async {
    final uri = Uri.parse('$kBaseUrl/api/v1/users/$userId/profiles');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createProfile({
    required int userId,
    required String name,
    String? avatarUrl,
  }) async {
    final uri = Uri.parse('$kBaseUrl/api/v1/profiles');
    final response = await _client.post(uri,
        headers: _headers,
        body: jsonEncode(
            {'user_id': userId, 'name': name, 'avatar_url': avatarUrl}));
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // -----------------------------------------------------------------------
  // Filmes
  // -----------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchTrendingMovies() async {
    final uri = Uri.parse('$kBaseUrl/api/v1/movies/trending');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  /// F3: Prateleira "Mais Bem Avaliados"
  static Future<List<Map<String, dynamic>>> fetchTopRatedMovies() async {
    final uri = Uri.parse('$kBaseUrl/api/v1/movies/top-rated');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final uri = Uri.parse(
        '$kBaseUrl/api/v1/movies/search?query=${Uri.encodeQueryComponent(query)}');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchPublicDomainMovies(
      {String q = 'silent film classic'}) async {
    final uri = Uri.parse(
        '$kBaseUrl/api/v1/movies/public-domain?q=${Uri.encodeQueryComponent(q)}');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  // -----------------------------------------------------------------------
  // Séries
  // -----------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchTrendingSeries() async {
    final uri = Uri.parse('$kBaseUrl/api/v1/series/trending');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> searchSeries(String query) async {
    final uri = Uri.parse(
        '$kBaseUrl/api/v1/series/search?query=${Uri.encodeQueryComponent(query)}');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  // -----------------------------------------------------------------------
  // Livros
  // -----------------------------------------------------------------------

  // Função auxiliar para extrair a lista do JSON com segurança (Google Books e Fallbacks)
  static List<Map<String, dynamic>> _extractListSafe(dynamic decoded) {
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    } else if (decoded is Map) {
      final list =
          decoded['items'] ?? decoded['data'] ?? decoded['results'] ?? [];
      return (list as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> searchBooks(String query,
      {int maxResults = 20}) async {
    final uri = Uri.parse(
        '$kBaseUrl/api/v1/books/search?q=${Uri.encodeQueryComponent(query)}&max_results=$maxResults');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return _extractListSafe(jsonDecode(response.body));
  }

  /// L1/L4: Endpoint dedicado para "Toda a Biblioteca" com queries PT e fallback
  static Future<List<Map<String, dynamic>>> fetchLibraryBooks(
      {int maxResults = 20}) async {
    final uri =
        Uri.parse('$kBaseUrl/api/v1/books/library?max_results=$maxResults');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return _extractListSafe(jsonDecode(response.body));
  }

  static Future<List<Map<String, dynamic>>> fetchPublicDomainBooks(
      {String q = 'classic literature'}) async {
    final uri = Uri.parse(
        '$kBaseUrl/api/v1/books/public-domain?q=${Uri.encodeQueryComponent(q)}&max_results=20');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return _extractListSafe(jsonDecode(response.body));
  }

  static Future<Map<String, dynamic>> fetchBookDetail(String bookId) async {
    final uri =
        Uri.parse('$kBaseUrl/api/v1/books/${Uri.encodeQueryComponent(bookId)}');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Open Library — busca link de leitura gratuita
  static Future<String?> fetchOpenLibraryReadUrl(String title) async {
    try {
      final uri = Uri.parse(
          'https://openlibrary.org/search.json?title=${Uri.encodeQueryComponent(title)}&limit=1');
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      final docs = data['docs'] as List?;
      if (docs == null || docs.isEmpty) return null;
      final iaList = docs[0]['ia'] as List?;
      if (iaList != null && iaList.isNotEmpty) {
        return 'https://archive.org/details/${iaList[0]}';
      }
      final key = docs[0]['key'] as String?;
      if (key == null) return null;
      return 'https://openlibrary.org$key';
    } catch (_) {
      return null;
    }
  }

  // -----------------------------------------------------------------------
  // Favoritos
  // -----------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final profileId = currentProfileId;
    if (profileId == null) return [];
    final uri = Uri.parse('$kBaseUrl/api/v1/profiles/$profileId/favorites');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> addFavorite(
      {required String movieId, required String movieTitle}) async {
    final profileId = currentProfileId;
    if (profileId == null) return;
    final uri = Uri.parse('$kBaseUrl/api/v1/favorites');
    final response = await _client.post(uri,
        headers: _headers,
        body: jsonEncode({
          'profile_id': profileId,
          'movie_id': movieId,
          'movie_title': movieTitle
        }));
    _checkStatus(response);
  }

  static Future<void> removeFavorite(String movieId) async {
    final profileId = currentProfileId;
    if (profileId == null) return;
    final uri =
        Uri.parse('$kBaseUrl/api/v1/profiles/$profileId/favorites/$movieId');
    final response = await _client.delete(uri, headers: _headers);
    _checkStatus(response);
  }

  // -----------------------------------------------------------------------
  // Addons
  // -----------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchProfileAddons() async {
    final profileId = currentProfileId;
    if (profileId == null) return [];
    final uri = Uri.parse('$kBaseUrl/api/v1/profiles/$profileId/addons');
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> installAddon({
    required String addonName,
    required String addonUrl,
    required String manifestUrl,
  }) async {
    final profileId = currentProfileId;
    if (profileId == null) return;
    final uri = Uri.parse('$kBaseUrl/api/v1/addons/install');
    final response = await _client.post(uri,
        headers: _headers,
        body: jsonEncode({
          'profile_id': profileId,
          'addon_name': addonName,
          'addon_url': addonUrl,
          'manifest_url': manifestUrl
        }));
    _checkStatus(response);
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------
  static void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(
          statusCode: response.statusCode,
          message: _tryParseDetail(response.body));
    }
  }

  static String _tryParseDetail(String body) {
    try {
      return (jsonDecode(body) as Map<String, dynamic>)['detail']?.toString() ??
          body;
    } catch (_) {
      return body;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

// frontend/lib/services/downloads_manager.dart
//
// L2: Gerencia downloads de PDFs em memória (+ SharedPreferences para persistência).
// Registra itens baixados, expõe lista e notifica listeners.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DownloadItem {
  final String id;
  final String title;
  final String filePath;
  final int fileSizeBytes;
  final DateTime downloadedAt;

  DownloadItem({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileSizeBytes,
    required this.downloadedAt,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes} B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'fileSizeBytes': fileSizeBytes,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory DownloadItem.fromJson(Map<String, dynamic> j) => DownloadItem(
        id: j['id'] as String,
        title: j['title'] as String,
        filePath: j['filePath'] as String,
        fileSizeBytes: j['fileSizeBytes'] as int,
        downloadedAt: DateTime.parse(j['downloadedAt'] as String),
      );
}

class DownloadsManager extends ChangeNotifier {
  DownloadsManager._();
  static final DownloadsManager instance = DownloadsManager._();

  final List<DownloadItem> _items = [];
  List<DownloadItem> get items => List.unmodifiable(_items);

  static const _prefsKey = 'genesis_downloads';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        _items.clear();
        _items.addAll(list.map(DownloadItem.fromJson));
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _prefsKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  bool isDownloaded(String id) => _items.any((e) => e.id == id);

  /// L2: Faz download do PDF, salva localmente e registra no manager.
  /// Retorna o caminho do arquivo ou lança exceção com mensagem legível.
  Future<String> downloadPdf({
    required String id,
    required String title,
    required String url,
    ValueChanged<double>? onProgress,
  }) async {
    // Evita duplicata
    if (isDownloaded(id)) {
      final existing = _items.firstWhere((e) => e.id == id);
      return existing.filePath;
    }

    final dir = kIsWeb
        ? null
        : await getApplicationDocumentsDirectory();

    if (dir == null) throw Exception('Download de arquivos não suportado nesta plataforma.');

    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim().replaceAll(' ', '_');
    final filePath = '${dir.path}/$safeTitle.pdf';

    final dio = Dio();
    try {
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
    } on DioException catch (e) {
      throw Exception('Falha no download: ${e.message}');
    }

    final file = File(filePath);
    final size = await file.length();

    final item = DownloadItem(
      id: id,
      title: title,
      filePath: filePath,
      fileSizeBytes: size,
      downloadedAt: DateTime.now(),
    );
    _items.insert(0, item);
    await _save();
    notifyListeners();
    return filePath;
  }

  Future<void> remove(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final item = _items[idx];
    try {
      final file = File(item.filePath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    _items.removeAt(idx);
    await _save();
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

enum DownloadStatus { queued, running, paused, completed, failed, canceled }

/// Who performs the transfer.
enum DownloadEngine {
  /// Android DownloadManager: survives the app going to the background.
  system,

  /// In-app HTTP client, used when traffic must go through the proxy.
  app,

  /// Content that already exists in the page (data: and blob: URLs).
  inline,
}

@immutable
class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    this.mimeType,
    this.totalBytes = -1,
    this.receivedBytes = 0,
    required this.status,
    required this.engine,
    this.systemId,
    this.filePath,
    this.error,
    this.userAgent,
    this.referer,
    this.incognito = false,
    required this.createdAt,
    this.completedAt,
    this.bytesPerSecond = 0,
  });

  factory DownloadItem.fromRow(Map<String, Object?> r) => DownloadItem(
    id: r['id']! as int,
    url: r['url']! as String,
    fileName: r['file_name']! as String,
    mimeType: r['mime_type'] as String?,
    totalBytes: r['total_bytes'] as int? ?? -1,
    receivedBytes: r['received_bytes'] as int? ?? 0,
    status: DownloadStatus.values.firstWhere((s) => s.name == r['status'], orElse: () => DownloadStatus.failed),
    engine: DownloadEngine.values.firstWhere((e) => e.name == r['engine'], orElse: () => DownloadEngine.system),
    systemId: r['system_id'] as int?,
    filePath: r['file_path'] as String?,
    error: r['error'] as String?,
    userAgent: r['user_agent'] as String?,
    referer: r['referer'] as String?,
    incognito: r['incognito'] == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at']! as int),
    completedAt: r['completed_at'] == null ? null : DateTime.fromMillisecondsSinceEpoch(r['completed_at']! as int),
  );

  final int id;
  final String url;
  final String fileName;
  final String? mimeType;
  final int totalBytes;
  final int receivedBytes;
  final DownloadStatus status;
  final DownloadEngine engine;
  final int? systemId;
  final String? filePath;
  final String? error;
  final String? userAgent;
  final String? referer;
  final bool incognito;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Measured transfer rate (not persisted).
  final double bytesPerSecond;

  bool get isActive =>
      status == DownloadStatus.queued || status == DownloadStatus.running || status == DownloadStatus.paused;

  double? get fraction => totalBytes > 0 ? (receivedBytes / totalBytes).clamp(0.0, 1.0) : null;

  Map<String, Object?> toRow() => {
    'url': url,
    'file_name': fileName,
    'mime_type': mimeType,
    'total_bytes': totalBytes,
    'received_bytes': receivedBytes,
    'status': status.name,
    'engine': engine.name,
    'system_id': systemId,
    'file_path': filePath,
    'error': error,
    'user_agent': userAgent,
    'referer': referer,
    'incognito': incognito ? 1 : 0,
    'created_at': createdAt.millisecondsSinceEpoch,
    'completed_at': completedAt?.millisecondsSinceEpoch,
  };

  DownloadItem copyWith({
    int? id,
    String? fileName,
    int? totalBytes,
    int? receivedBytes,
    DownloadStatus? status,
    int? systemId,
    String? filePath,
    String? error,
    bool clearError = false,
    DateTime? completedAt,
    double? bytesPerSecond,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      url: url,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      status: status ?? this.status,
      engine: engine,
      systemId: systemId ?? this.systemId,
      filePath: filePath ?? this.filePath,
      error: clearError ? null : (error ?? this.error),
      userAgent: userAgent,
      referer: referer,
      incognito: incognito,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      bytesPerSecond: bytesPerSecond ?? this.bytesPerSecond,
    );
  }
}

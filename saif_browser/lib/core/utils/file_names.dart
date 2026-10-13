/// File name helpers for downloads.
abstract final class FileNames {
  static const _mimeExtensions = {
    'application/pdf': 'pdf',
    'application/zip': 'zip',
    'application/x-zip-compressed': 'zip',
    'application/json': 'json',
    'application/msword': 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
    'application/vnd.ms-excel': 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
    'application/vnd.ms-powerpoint': 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'pptx',
    'application/vnd.android.package-archive': 'apk',
    'application/epub+zip': 'epub',
    'application/x-7z-compressed': '7z',
    'application/x-rar-compressed': 'rar',
    'application/gzip': 'gz',
    'text/plain': 'txt',
    'text/html': 'html',
    'text/csv': 'csv',
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/gif': 'gif',
    'image/webp': 'webp',
    'image/svg+xml': 'svg',
    'image/avif': 'avif',
    'audio/mpeg': 'mp3',
    'audio/ogg': 'ogg',
    'audio/wav': 'wav',
    'video/mp4': 'mp4',
    'video/webm': 'webm',
    'video/quicktime': 'mov',
  };

  static String? extensionForMime(String? mime) {
    if (mime == null) return null;
    return _mimeExtensions[mime.split(';').first.trim().toLowerCase()];
  }

  static String? mimeForName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return null;
    final ext = name.substring(dot + 1).toLowerCase();
    for (final entry in _mimeExtensions.entries) {
      if (entry.value == ext) return entry.key;
    }
    if (ext == 'jpeg') return 'image/jpeg';
    return null;
  }

  /// Picks a file name from Content-Disposition, the URL path and the MIME type.
  static String guess(String url, String? contentDisposition, String? mimeType) {
    var name = _fromContentDisposition(contentDisposition);
    if (name == null || name.isEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty) name = segments.last;
      }
    }
    name = sanitize(name ?? '');
    if (name.isEmpty) name = 'download';
    final ext = extensionForMime(mimeType);
    if (!name.contains('.') && ext != null) {
      name = '$name.$ext';
    } else if (name.contains('.') && ext != null) {
      final current = name.substring(name.lastIndexOf('.') + 1).toLowerCase();
      if (mimeForName(name) == null && current.length > 5) name = '$name.$ext';
    }
    return name;
  }

  static String? _fromContentDisposition(String? header) {
    if (header == null || header.isEmpty) return null;
    final star = RegExp(r"""filename\*\s*=\s*([^']*)'[^']*'([^;]+)""", caseSensitive: false).firstMatch(header);
    if (star != null) {
      try {
        return Uri.decodeComponent(star.group(2)!.trim().replaceAll('"', ''));
      } on ArgumentError {
        // fall through to the plain parameter
      }
    }
    final plain = RegExp(r'''filename\s*=\s*("([^"]*)"|[^;]+)''', caseSensitive: false).firstMatch(header);
    if (plain == null) return null;
    final value = plain.group(2) ?? plain.group(1)!;
    return value.trim();
  }

  /// Removes path separators and characters Android file systems reject.
  static String sanitize(String name) {
    var result = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').replaceAll(RegExp(r'^\.+'), '').trim();
    if (result.length > 120) {
      final dot = result.lastIndexOf('.');
      if (dot > 0 && result.length - dot <= 10) {
        result = result.substring(0, 120 - (result.length - dot)) + result.substring(dot);
      } else {
        result = result.substring(0, 120);
      }
    }
    return result;
  }

  /// Returns [name] or `name (n).ext` so it does not clash with [taken].
  static String unique(String name, Set<String> taken) {
    if (!taken.contains(name)) return name;
    final dot = name.lastIndexOf('.');
    final base = dot > 0 ? name.substring(0, dot) : name;
    final ext = dot > 0 ? name.substring(dot) : '';
    for (var i = 1; ; i++) {
      final candidate = '$base ($i)$ext';
      if (!taken.contains(candidate)) return candidate;
    }
  }
}

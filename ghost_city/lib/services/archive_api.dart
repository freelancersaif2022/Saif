import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Mapillary client token. A `MAPILLARY_TOKEN` passed with --dart-define overrides it.
/// Client tokens are read-only and meant to ship inside apps.
const _envMapillaryToken = String.fromEnvironment('MAPILLARY_TOKEN');
const _defaultMapillaryToken = 'MLY|39872778375640678|d2dbe29b55198065c83b6ceb0c5a97b5';
String get mapillaryToken => _envMapillaryToken.isNotEmpty ? _envMapillaryToken : _defaultMapillaryToken;

const _userAgent = 'GhostCity/1.0 (https://github.com/freelancersaif2022/Saif)';
const _timeout = Duration(seconds: 20);

enum PhotoSource { mapillary, wikimedia }

extension PhotoSourceLabel on PhotoSource {
  String get label => switch (this) {
        PhotoSource.mapillary => 'Mapillary',
        PhotoSource.wikimedia => 'Wikimedia Commons',
      };
}

/// A dated photo of a real place, from an open archive.
class PastPhoto {
  PastPhoto({
    required this.id,
    required this.source,
    required this.imageUrl,
    required this.thumbUrl,
    required this.date,
    required this.dateIsUpload,
    required this.point,
    required this.distanceMeters,
    required this.credit,
    this.title,
    this.license,
    this.pageUrl,
    this.compassAngle,
  });

  final String id;
  final PhotoSource source;
  final String imageUrl;
  final String thumbUrl;
  final DateTime date;

  /// True when the archive only knows the upload date, not when the photo was taken.
  final bool dateIsUpload;
  final LatLng point;
  final double distanceMeters;
  final String credit;
  final String? title;
  final String? license;
  final String? pageUrl;
  final double? compassAngle;

  int get year => date.year;
  int get yearsAgo => math.max(0, DateTime.now().year - date.year);
}

class Release {
  Release(this.date, this.urlTemplate);
  final DateTime date;

  /// flutter_map style template with {z}/{y}/{x}.
  final String urlTemplate;
}

class PlaceResult {
  PlaceResult(this.name, this.detail, this.point);
  final String name;
  final String detail;
  final LatLng point;
}

enum ApiFailure { offline, timeout, server, auth }

class ApiException implements Exception {
  ApiException(this.failure, [this.detail]);
  final ApiFailure failure;
  final String? detail;

  String get message => switch (failure) {
        ApiFailure.offline => 'No internet connection.',
        ApiFailure.timeout => 'The archive is taking too long to answer. Try again.',
        ApiFailure.auth => 'The street photo service rejected the app key.',
        ApiFailure.server => 'The archive could not be reached right now. Try again shortly.',
      };

  @override
  String toString() => 'ApiException($failure, $detail)';
}

class ArchiveApi {
  ArchiveApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<dynamic> _getJson(Uri uri, {Map<String, String>? headers}) async {
    try {
      final res = await _client
          .get(uri, headers: {'User-Agent': _userAgent, 'Accept': 'application/json', ...?headers})
          .timeout(_timeout);
      if (res.statusCode == 401 || res.statusCode == 403) throw ApiException(ApiFailure.auth, res.body);
      if (res.statusCode != 200) throw ApiException(ApiFailure.server, 'HTTP ${res.statusCode}');
      return jsonDecode(utf8.decode(res.bodyBytes));
    } on SocketException catch (e) {
      throw ApiException(ApiFailure.offline, e.message);
    } on http.ClientException catch (e) {
      throw ApiException(ApiFailure.offline, e.message);
    } on HandshakeException catch (e) {
      throw ApiException(ApiFailure.offline, e.message);
    } on TimeoutException {
      throw ApiException(ApiFailure.timeout);
    } on FormatException catch (e) {
      throw ApiException(ApiFailure.server, e.message);
    }
  }

  // ---------------------------------------------------------------- Mapillary

  /// Street-level photos around [center] taken at least [minYearsAgo] years ago.
  /// Searches a small box first and widens it when nothing older is found.
  Future<List<PastPhoto>> mapillary(LatLng center, {int minYearsAgo = 5, int maxYearsAgo = 25}) async {
    final now = DateTime.now().toUtc();
    final end = DateTime.utc(now.year - minYearsAgo, now.month, now.day);
    final start = DateTime.utc(now.year - maxYearsAgo, 1, 1);
    final found = <String, PastPhoto>{};
    for (final radius in const [250.0, 700.0, 1500.0]) {
      final box = _bbox(center, radius);
      final uri = Uri.https('graph.mapillary.com', '/images', {
        'access_token': mapillaryToken,
        'fields': 'id,captured_at,compass_angle,computed_geometry,geometry,thumb_256_url,thumb_1024_url,thumb_2048_url,creator,is_pano',
        'bbox': box.map((v) => v.toStringAsFixed(6)).join(','),
        'start_captured_at': _isoSeconds(start),
        'end_captured_at': _isoSeconds(end),
        'limit': '400',
      });
      final json = await _getJson(uri);
      for (final p in parseMapillary(json, center)) {
        found[p.id] = p;
      }
      if (found.length >= 12) break;
    }
    return _spreadByYear(found.values.toList(), perYear: 6);
  }

  static List<PastPhoto> parseMapillary(dynamic json, LatLng center) {
    final out = <PastPhoto>[];
    final data = json is Map ? json['data'] : null;
    if (data is! List) return out;
    for (final item in data) {
      if (item is! Map) continue;
      if (item['is_pano'] == true) continue;
      final captured = item['captured_at'];
      final ms = captured is num ? captured.toInt() : int.tryParse('$captured');
      final url = (item['thumb_2048_url'] ?? item['thumb_1024_url']) as String?;
      final thumb = (item['thumb_1024_url'] ?? item['thumb_256_url'] ?? url) as String?;
      final geo = (item['computed_geometry'] ?? item['geometry']) as Map?;
      final coords = geo?['coordinates'];
      if (ms == null || url == null || thumb == null || coords is! List || coords.length < 2) continue;
      final point = LatLng((coords[1] as num).toDouble(), (coords[0] as num).toDouble());
      final creator = item['creator'] is Map ? (item['creator']['username'] as String?) : null;
      out.add(PastPhoto(
        id: 'mly-${item['id']}',
        source: PhotoSource.mapillary,
        imageUrl: url,
        thumbUrl: thumb,
        date: DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
        dateIsUpload: false,
        point: point,
        distanceMeters: _distance(center, point),
        credit: creator == null || creator.isEmpty ? 'Mapillary contributor' : '$creator on Mapillary',
        license: 'CC BY-SA 4.0',
        pageUrl: 'https://www.mapillary.com/app/?pKey=${item['id']}',
        compassAngle: (item['compass_angle'] as num?)?.toDouble(),
      ));
    }
    return out;
  }

  // ---------------------------------------------------------------- Wikimedia

  /// Photos on Wikimedia Commons taken near [center], at least [minYearsAgo] years ago.
  Future<List<PastPhoto>> wikimedia(LatLng center, {int minYearsAgo = 5, int maxYearsAgo = 25}) async {
    final found = <String, PastPhoto>{};
    for (final radius in const [1000, 4000, 10000]) {
      final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
        'action': 'query',
        'format': 'json',
        'formatversion': '2',
        'generator': 'geosearch',
        'ggscoord': '${center.latitude}|${center.longitude}',
        'ggsradius': '$radius',
        'ggslimit': '200',
        'ggsnamespace': '6',
        'prop': 'imageinfo|coordinates',
        'iiprop': 'url|extmetadata|timestamp|mime',
        'iiurlwidth': '1600',
        'iiextmetadatafilter': 'DateTimeOriginal|DateTime|Artist|LicenseShortName|ObjectName',
        'colimit': '200',
        'origin': '*',
      });
      final json = await _getJson(uri);
      final now = DateTime.now().year;
      for (final p in parseWikimedia(json, center)) {
        final age = now - p.year;
        if (age >= minYearsAgo && age <= maxYearsAgo) found[p.id] = p;
      }
      if (found.length >= 12) break;
    }
    final list = found.values.toList()..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return _spreadByYear(list, perYear: 8);
  }

  static List<PastPhoto> parseWikimedia(dynamic json, LatLng center) {
    final out = <PastPhoto>[];
    final query = json is Map ? json['query'] : null;
    var pages = query is Map ? query['pages'] : null;
    if (pages is Map) pages = pages.values.toList();
    if (pages is! List) return out;
    for (final page in pages) {
      if (page is! Map) continue;
      final infos = page['imageinfo'];
      if (infos is! List || infos.isEmpty || infos.first is! Map) continue;
      final info = infos.first as Map;
      final mime = (info['mime'] as String?) ?? '';
      if (!(mime == 'image/jpeg' || mime == 'image/png' || mime == 'image/webp')) continue;
      final url = (info['thumburl'] ?? info['url']) as String?;
      if (url == null) continue;
      final coordsList = page['coordinates'];
      LatLng? point;
      if (coordsList is List && coordsList.isNotEmpty && coordsList.first is Map) {
        final c = coordsList.first as Map;
        final lat = (c['lat'] as num?)?.toDouble();
        final lon = (c['lon'] as num?)?.toDouble();
        if (lat != null && lon != null) point = LatLng(lat, lon);
      }
      if (point == null) continue;

      final meta = info['extmetadata'] is Map ? info['extmetadata'] as Map : const {};
      String? metaValue(String key) {
        final v = meta[key];
        return v is Map ? stripHtml('${v['value'] ?? ''}').trim() : null;
      }

      var dateIsUpload = false;
      var date = parseLooseDate(metaValue('DateTimeOriginal'));
      if (date == null) {
        dateIsUpload = true;
        date = parseLooseDate(info['timestamp'] as String?) ?? parseLooseDate(metaValue('DateTime'));
      }
      if (date == null) continue;

      final title = (page['title'] as String? ?? '').replaceFirst('File:', '');
      final niceTitle = metaValue('ObjectName')?.isNotEmpty == true
          ? metaValue('ObjectName')!
          : title.replaceAll(RegExp(r'\.(jpe?g|png|webp)$', caseSensitive: false), '').replaceAll('_', ' ');
      final artist = metaValue('Artist');
      out.add(PastPhoto(
        id: 'wm-${page['pageid'] ?? title}',
        source: PhotoSource.wikimedia,
        imageUrl: url,
        thumbUrl: url,
        date: date,
        dateIsUpload: dateIsUpload,
        point: point,
        distanceMeters: _distance(center, point),
        credit: artist == null || artist.isEmpty ? 'Wikimedia Commons' : '$artist · Wikimedia Commons',
        title: niceTitle,
        license: metaValue('LicenseShortName'),
        pageUrl: (info['descriptionurl'] as String?) ?? 'https://commons.wikimedia.org/wiki/${Uri.encodeComponent(page['title'] as String? ?? '')}',
      ));
    }
    return out;
  }

  // ---------------------------------------------------------------- Satellite

  /// Esri World Imagery Wayback: one archived satellite mosaic per year, oldest first.
  Future<List<Release>> waybackReleases() async {
    final json = await _getJson(Uri.parse('https://s3-us-west-2.amazonaws.com/config.maptiles.arcgis.com/waybackconfig.json'));
    return parseWayback(json);
  }

  static List<Release> parseWayback(dynamic json) {
    final all = <Release>[];
    if (json is! Map) return all;
    for (final v in json.values) {
      if (v is! Map) continue;
      final title = v['itemTitle'] as String? ?? '';
      final url = v['itemURL'] as String?;
      final m = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(title);
      if (url == null || m == null) continue;
      final date = DateTime.utc(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
      final template = url.replaceAll('{level}', '{z}').replaceAll('{row}', '{y}').replaceAll('{col}', '{x}');
      all.add(Release(date, template));
    }
    all.sort((a, b) => a.date.compareTo(b.date));
    // Keep the latest release of each year.
    final byYear = <int, Release>{};
    for (final r in all) {
      byYear[r.date.year] = r;
    }
    return byYear.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // ---------------------------------------------------------------- Places

  Future<List<PlaceResult>> searchPlaces(String query) async {
    final json = await _getJson(Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '8',
      'addressdetails': '0',
    }));
    if (json is! List) return const [];
    return [
      for (final r in json)
        if (r is Map && r['lat'] != null && r['lon'] != null)
          PlaceResult(
            (r['name'] as String?)?.isNotEmpty == true ? r['name'] as String : (r['display_name'] as String).split(',').first,
            r['display_name'] as String? ?? '',
            LatLng(double.parse('${r['lat']}'), double.parse('${r['lon']}')),
          ),
    ];
  }

  /// A short human name for a coordinate ("Mall Road, Lahore").
  Future<String?> placeName(LatLng p) async {
    final json = await _getJson(Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': '${p.latitude}',
      'lon': '${p.longitude}',
      'format': 'jsonv2',
      'zoom': '17',
    }));
    if (json is! Map) return null;
    final a = json['address'];
    if (a is Map) {
      final street = a['road'] ?? a['pedestrian'] ?? a['neighbourhood'] ?? a['suburb'];
      final city = a['city'] ?? a['town'] ?? a['village'] ?? a['county'] ?? a['state'];
      final parts = [street, city].whereType<String>().toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }
    final name = json['name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    return (json['display_name'] as String?)?.split(',').take(2).join(',');
  }
}

// ---------------------------------------------------------------- helpers

List<double> _bbox(LatLng c, double meters) {
  final dLat = meters / 111320.0;
  final dLon = meters / (111320.0 * math.cos(c.latitude * math.pi / 180).abs().clamp(0.01, 1.0));
  return [c.longitude - dLon, c.latitude - dLat, c.longitude + dLon, c.latitude + dLat];
}

String _isoSeconds(DateTime d) => '${d.toIso8601String().split('.').first.replaceAll('Z', '')}Z';

double _distance(LatLng a, LatLng b) => const Distance().as(LengthUnit.Meter, a, b);

/// Keeps the list varied: at most [perYear] photos per year, nearest first, oldest years first.
List<PastPhoto> _spreadByYear(List<PastPhoto> photos, {required int perYear}) {
  final byYear = <int, List<PastPhoto>>{};
  for (final p in photos) {
    byYear.putIfAbsent(p.year, () => []).add(p);
  }
  final years = byYear.keys.toList()..sort();
  final out = <PastPhoto>[];
  for (final y in years) {
    final list = byYear[y]!..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    out.addAll(list.take(perYear));
  }
  return out;
}

String stripHtml(String s) => s
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#039;', "'")
    .replaceAll('&nbsp;', ' ')
    .replaceAll(RegExp(r'\s+'), ' ');

/// Reads dates like "2009-05-03 12:00:00", "2009:05:03", "May 2009", "2009" or ISO strings.
DateTime? parseLooseDate(String? s) {
  if (s == null || s.trim().isEmpty) return null;
  final iso = DateTime.tryParse(s.trim());
  if (iso != null && iso.year > 1800) return iso;
  final full = RegExp(r'\b(1[89]\d{2}|20\d{2})[-:/.](\d{1,2})[-:/.](\d{1,2})\b').firstMatch(s);
  if (full != null) {
    final y = int.parse(full[1]!), m = int.parse(full[2]!), d = int.parse(full[3]!);
    if (m >= 1 && m <= 12 && d >= 1 && d <= 31) return DateTime.utc(y, m, d);
  }
  final year = RegExp(r'\b(1[89]\d{2}|20\d{2})\b').firstMatch(s);
  if (year != null) {
    final y = int.parse(year[1]!);
    if (y <= DateTime.now().year) return DateTime.utc(y, 7, 1);
  }
  return null;
}

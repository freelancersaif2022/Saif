// Calls the live archives for a few well-known places and prints what comes
// back. Run in CI with: dart run tool/api_smoke.dart
import 'dart:io';

import 'package:ghost_city/services/archive_api.dart';
import 'package:latlong2/latlong.dart';

Future<void> main() async {
  final api = ArchiveApi();
  final spots = {
    'Lahore, Mall Road': const LatLng(31.5580, 74.3120),
    'Paris, Moulin Rouge': const LatLng(48.8841, 2.3322),
    'New York, Times Square': const LatLng(40.7580, -73.9855),
  };
  var failures = 0;
  for (final e in spots.entries) {
    for (final source in ['mapillary', 'wikimedia']) {
      try {
        final photos = source == 'mapillary' ? await api.mapillary(e.value) : await api.wikimedia(e.value);
        final years = photos.map((p) => p.year).toSet().toList()..sort();
        stdout.writeln('${e.key} · $source: ${photos.length} photos, years $years');
        if (photos.isNotEmpty) stdout.writeln('   e.g. ${photos.first.imageUrl.substring(0, 60)}… by ${photos.first.credit}');
      } catch (err) {
        failures++;
        stdout.writeln('${e.key} · $source: FAILED $err');
      }
    }
  }
  try {
    final r = await api.waybackReleases();
    stdout.writeln('Wayback: ${r.length} years, ${r.first.date.year}–${r.last.date.year}');
  } catch (err) {
    failures++;
    stdout.writeln('Wayback: FAILED $err');
  }
  try {
    final name = await api.placeName(spots.values.first);
    final search = await api.searchPlaces('Anarkali Bazaar Lahore');
    stdout.writeln('Nominatim: reverse "$name", search ${search.length} results');
  } catch (err) {
    failures++;
    stdout.writeln('Nominatim: FAILED $err');
  }
  exit(failures == 0 ? 0 : 1);
}

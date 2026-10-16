import 'package:flutter_test/flutter_test.dart';
import 'package:ghost_city/services/archive_api.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const center = LatLng(31.5580, 74.3120);

  test('parses Mapillary images and skips panoramas and incomplete rows', () {
    final json = {
      'data': [
        {
          'id': '111',
          'captured_at': DateTime.utc(2014, 6, 2).millisecondsSinceEpoch,
          'computed_geometry': {'type': 'Point', 'coordinates': [74.3125, 31.5582]},
          'thumb_1024_url': 'https://img/1024.jpg',
          'thumb_2048_url': 'https://img/2048.jpg',
          'creator': {'username': 'ali', 'id': '9'},
          'compass_angle': 120.5,
          'is_pano': false,
        },
        {'id': '222', 'captured_at': 1400000000000, 'is_pano': true, 'thumb_1024_url': 'x', 'geometry': {'coordinates': [74, 31]}},
        {'id': '333', 'captured_at': 1400000000000},
      ],
    };
    final out = ArchiveApi.parseMapillary(json, center);
    expect(out, hasLength(1));
    expect(out.first.year, 2014);
    expect(out.first.imageUrl, 'https://img/2048.jpg');
    expect(out.first.credit, 'ali on Mapillary');
    expect(out.first.distanceMeters, lessThan(100));
  });

  test('parses Wikimedia geosearch pages (formatversion 2)', () {
    final json = {
      'query': {
        'pages': [
          {
            'pageid': 5,
            'title': 'File:Mall_Road_Lahore.jpg',
            'coordinates': [
              {'lat': 31.559, 'lon': 74.313, 'primary': true, 'globe': 'earth'},
            ],
            'imageinfo': [
              {
                'timestamp': '2016-03-01T10:00:00Z',
                'url': 'https://upload/full.jpg',
                'thumburl': 'https://upload/1600.jpg',
                'descriptionurl': 'https://commons.wikimedia.org/wiki/File:Mall_Road_Lahore.jpg',
                'mime': 'image/jpeg',
                'extmetadata': {
                  'DateTimeOriginal': {'value': '2009-05-03 12:00:00'},
                  'Artist': {'value': '<a href="//x">Saad</a>'},
                  'LicenseShortName': {'value': 'CC BY-SA 3.0'},
                },
              },
            ],
          },
          {
            'pageid': 6,
            'title': 'File:Map.svg',
            'coordinates': [
              {'lat': 31.559, 'lon': 74.313},
            ],
            'imageinfo': [
              {'url': 'https://upload/map.svg', 'mime': 'image/svg+xml', 'timestamp': '2015-01-01T00:00:00Z'},
            ],
          },
        ],
      },
    };
    final out = ArchiveApi.parseWikimedia(json, center);
    expect(out, hasLength(1));
    final p = out.first;
    expect(p.year, 2009);
    expect(p.dateIsUpload, isFalse);
    expect(p.imageUrl, 'https://upload/1600.jpg');
    expect(p.credit, 'Saad · Wikimedia Commons');
    expect(p.title, 'Mall Road Lahore');
  });

  test('falls back to upload date when the original date is missing', () {
    final json = {
      'query': {
        'pages': {
          '7': {
            'pageid': 7,
            'title': 'File:Street.jpg',
            'coordinates': [
              {'lat': 31.56, 'lon': 74.31},
            ],
            'imageinfo': [
              {'url': 'https://u/s.jpg', 'mime': 'image/jpeg', 'timestamp': '2012-08-09T00:00:00Z', 'extmetadata': {}},
            ],
          },
        },
      },
    };
    final out = ArchiveApi.parseWikimedia(json, center);
    expect(out.single.year, 2012);
    expect(out.single.dateIsUpload, isTrue);
  });

  test('keeps the latest Wayback release of each year and rewrites the tile template', () {
    final json = {
      '10': {
        'itemTitle': 'World Imagery (Wayback 2014-02-20)',
        'itemURL': 'https://wayback/tile/10/{level}/{row}/{col}',
      },
      '11': {
        'itemTitle': 'World Imagery (Wayback 2014-06-11)',
        'itemURL': 'https://wayback/tile/11/{level}/{row}/{col}',
      },
      '64001': {
        'itemTitle': 'World Imagery (Wayback 2026-02-26)',
        'itemURL': 'https://wayback/tile/64001/{level}/{row}/{col}',
      },
    };
    final out = ArchiveApi.parseWayback(json);
    expect(out.map((r) => r.date.year), [2014, 2026]);
    expect(out.first.urlTemplate, 'https://wayback/tile/11/{z}/{y}/{x}');
  });

  test('reads loose dates', () {
    expect(parseLooseDate('2009:05:03 10:00:00')!.year, 2009);
    expect(parseLooseDate('May 2011')!.year, 2011);
    expect(parseLooseDate('circa 2008')!.year, 2008);
    expect(parseLooseDate('unknown'), isNull);
  });

  test('parses Wikipedia places and drops non-places', () {
    final json = {
      'query': {
        'pages': [
          {
            'pageid': 1,
            'title': 'Lahore Museum',
            'description': 'museum in Lahore, Pakistan',
            'extract': 'The Lahore Museum is a museum located in Lahore.',
            'coordinates': [
              {'lat': 31.5685, 'lon': 74.3082},
            ],
            'thumbnail': {'source': 'https://upload/museum.jpg'},
          },
          {
            'pageid': 2,
            'title': 'NA-123 (Lahore-VII)',
            'description': 'constituency of the National Assembly of Pakistan',
            'coordinates': [
              {'lat': 31.56, 'lon': 74.31},
            ],
          },
        ],
      },
    };
    final out = ArchiveApi.parseWikipedia(json, center);
    expect(out.single.title, 'Lahore Museum');
    expect(out.single.imageUrl, 'https://upload/museum.jpg');
    expect(out.single.distanceMeters, greaterThan(500));
  });

  test('skips Wikimedia photos taken from space', () {
    final json = {
      'query': {
        'pages': [
          {
            'pageid': 9,
            'title': 'File:Lahore from the ISS.jpg',
            'coordinates': [
              {'lat': 31.56, 'lon': 74.31},
            ],
            'imageinfo': [
              {
                'url': 'https://u/iss.jpg',
                'mime': 'image/jpeg',
                'timestamp': '2012-08-09T00:00:00Z',
                'extmetadata': {
                  'DateTimeOriginal': {'value': '2012-01-01'},
                },
              },
            ],
          },
        ],
      },
    };
    expect(ArchiveApi.parseWikimedia(json, center), isEmpty);
  });
}

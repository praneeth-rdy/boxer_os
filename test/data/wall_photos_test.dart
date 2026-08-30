import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/wall_photos.dart';

void main() {
  group('wallPhotos', () {
    test('holds exactly 14 entries', () {
      expect(wallPhotos.length, 14);
    });

    test('every entry has a unique, non-empty id', () {
      final ids = wallPhotos.map((photo) => photo.id).toSet();

      expect(ids.length, wallPhotos.length);
      expect(wallPhotos.every((photo) => photo.id.isNotEmpty), isTrue);
    });

    test('every entry has a line, caption and asset', () {
      for (final photo in wallPhotos) {
        expect(photo.line, isNotEmpty, reason: photo.id);
        expect(photo.caption, isNotEmpty, reason: photo.id);
        expect(photo.asset, 'assets/wall/${photo.id}.jpg', reason: photo.id);
      }
    });

    test('every entry has an author, license and source', () {
      for (final photo in wallPhotos) {
        expect(photo.credit.author, isNotEmpty, reason: photo.id);
        expect(photo.credit.license, isNotEmpty, reason: photo.id);
        expect(photo.credit.source, startsWith('https://'), reason: photo.id);
      }
    });

    test('every asset file exists on disk', () {
      for (final photo in wallPhotos) {
        expect(File(photo.asset).existsSync(), isTrue, reason: photo.asset);
      }
    });
  });
}

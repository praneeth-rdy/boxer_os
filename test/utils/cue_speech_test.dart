import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/utils/cue_speech.dart';

void main() {
  group('cueToSpeech', () {
    test('turns a combination and footwork notation into speech', () {
      expect(
        cueToSpeech('1-2, slip, pivot, exit'),
        'jab, cross, slip, pivot, exit',
      );
    });

    test('a body-shot suffix appends "to the body"', () {
      expect(cueToSpeech('3b'), 'lead hook to the body');
    });

    test('every punch digit maps to its name', () {
      expect(cueToSpeech('1'), 'jab');
      expect(cueToSpeech('2'), 'cross');
      expect(cueToSpeech('3'), 'lead hook');
      expect(cueToSpeech('4'), 'rear hook');
      expect(cueToSpeech('5'), 'lead uppercut');
      expect(cueToSpeech('6'), 'rear uppercut');
    });

    test('a body-shot suffix works for every punch digit', () {
      expect(cueToSpeech('2b'), 'cross to the body');
      expect(cueToSpeech('4b'), 'rear hook to the body');
    });

    test('unknown tokens pass through unchanged', () {
      expect(cueToSpeech('slip'), 'slip');
      expect(cueToSpeech('reset'), 'reset');
    });

    test('a hyphen chain of punches is spoken as separate punches', () {
      expect(cueToSpeech('1-2b-2'), 'jab, cross to the body, cross');
    });

    test('a hyphenated word that is not a punch chain is left alone', () {
      expect(cueToSpeech('push-ups'), 'push-ups');
      expect(cueToSpeech('rows or pull-ups'), 'rows or pull-ups');
      expect(cueToSpeech('med-ball slams'), 'med-ball slams');
    });

    test('collapses double spaces', () {
      expect(cueToSpeech('1  2'), 'jab cross');
    });

    test('empty input is empty output', () {
      expect(cueToSpeech(''), '');
    });
  });
}

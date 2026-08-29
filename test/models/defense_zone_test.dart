import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/defense_zone.dart';
import 'package:boxer_os/models/incoming_punch.dart';
import 'package:boxer_os/models/stance.dart';

void main() {
  group('defenseFor', () {
    test('orthodox jab is answered by slipping right', () {
      expect(
        defenseFor(IncomingPunch.jab, Stance.orthodox),
        DefenseZone.slipRight,
      );
    });

    test('orthodox cross is answered by slipping left', () {
      expect(
        defenseFor(IncomingPunch.cross, Stance.orthodox),
        DefenseZone.slipLeft,
      );
    });

    test('orthodox lead hook is answered by a roll', () {
      expect(
        defenseFor(IncomingPunch.leadHook, Stance.orthodox),
        DefenseZone.roll,
      );
    });

    test('orthodox rear hook is answered by a roll', () {
      expect(
        defenseFor(IncomingPunch.rearHook, Stance.orthodox),
        DefenseZone.roll,
      );
    });

    test('orthodox body shot is answered by a block', () {
      expect(
        defenseFor(IncomingPunch.body, Stance.orthodox),
        DefenseZone.block,
      );
    });

    test('southpaw jab is answered by slipping left', () {
      expect(
        defenseFor(IncomingPunch.jab, Stance.southpaw),
        DefenseZone.slipLeft,
      );
    });

    test('southpaw cross is answered by slipping right', () {
      expect(
        defenseFor(IncomingPunch.cross, Stance.southpaw),
        DefenseZone.slipRight,
      );
    });

    test('southpaw lead hook is answered by a roll', () {
      expect(
        defenseFor(IncomingPunch.leadHook, Stance.southpaw),
        DefenseZone.roll,
      );
    });

    test('southpaw rear hook is answered by a roll', () {
      expect(
        defenseFor(IncomingPunch.rearHook, Stance.southpaw),
        DefenseZone.roll,
      );
    });

    test('southpaw body shot is answered by a block', () {
      expect(
        defenseFor(IncomingPunch.body, Stance.southpaw),
        DefenseZone.block,
      );
    });
  });

  group('DefenseZone.label', () {
    test('labels are upper case defense names', () {
      expect(DefenseZone.slipLeft.label, 'SLIP LEFT');
      expect(DefenseZone.slipRight.label, 'SLIP RIGHT');
      expect(DefenseZone.roll.label, 'ROLL');
      expect(DefenseZone.block.label, 'BLOCK');
    });
  });

  group('IncomingPunch.label', () {
    test('labels are upper case punch names', () {
      expect(IncomingPunch.jab.label, 'JAB');
      expect(IncomingPunch.cross.label, 'CROSS');
      expect(IncomingPunch.leadHook.label, 'LEAD HOOK');
      expect(IncomingPunch.rearHook.label, 'REAR HOOK');
      expect(IncomingPunch.body.label, 'BODY');
    });
  });
}

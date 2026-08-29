import 'incoming_punch.dart';
import 'stance.dart';

/// The answer a defense-mode trial asks for.
enum DefenseZone {
  slipLeft,
  slipRight,
  roll,
  block;

  String get label => switch (this) {
    DefenseZone.slipLeft => 'SLIP LEFT',
    DefenseZone.slipRight => 'SLIP RIGHT',
    DefenseZone.roll => 'ROLL',
    DefenseZone.block => 'BLOCK',
  };
}

/// The defense that beats [punch] from [stance].
DefenseZone defenseFor(IncomingPunch punch, Stance stance) {
  final isOrthodox = stance == Stance.orthodox;
  return switch (punch) {
    // Slip outside the hand that throws, the conventional same-stance answer.
    IncomingPunch.jab =>
      isOrthodox ? DefenseZone.slipRight : DefenseZone.slipLeft,
    IncomingPunch.cross =>
      isOrthodox ? DefenseZone.slipLeft : DefenseZone.slipRight,
    IncomingPunch.leadHook => DefenseZone.roll,
    IncomingPunch.rearHook => DefenseZone.roll,
    IncomingPunch.body => DefenseZone.block,
  };
}

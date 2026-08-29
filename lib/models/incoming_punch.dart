/// The punch called in defense mode.
enum IncomingPunch {
  jab,
  cross,
  leadHook,
  rearHook,
  body;

  String get label => switch (this) {
    IncomingPunch.jab => 'JAB',
    IncomingPunch.cross => 'CROSS',
    IncomingPunch.leadHook => 'LEAD HOOK',
    IncomingPunch.rearHook => 'REAR HOOK',
    IncomingPunch.body => 'BODY',
  };
}

# Device testing

The owner's phone is the reference device: Vivo I2214, Android 16, 1080x2400, a text-only launcher. An emulator
cannot settle bells, haptics, TTS timing or wallpaper behaviour, so anything in those areas is
"assumed" until it has run on that phone.

Known about that device, from earlier rounds:

- Its launcher shows no home wallpaper, so Gym Wall can only be verified on the lock screen
  (`docs/decisions.md`, 2026-08-30 entries).
- Live wallpaper activation goes through the Vivo theme app, not a stock picker.
- During one screenshot run the proximity sensor read "covered" with the phone face down and the
  capture stalled; keep the phone face up.

Open device work: `docs/backlog.md` R-03 and `docs/review-log.md` R1-05.

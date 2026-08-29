const Map<String, String> _punches = {
  '1': 'jab',
  '2': 'cross',
  '3': 'lead hook',
  '4': 'rear hook',
  '5': 'lead uppercut',
  '6': 'rear uppercut',
};

final RegExp _doubleSpace = RegExp(r' {2,}');

/// Turns cue notation such as `1-2, slip` into speakable text.
String cueToSpeech(String cue) {
  final spoken = cue.split(' ').map(_wordToSpeech).join(' ');
  return spoken.replaceAll(_doubleSpace, ' ').trim();
}

/// A hyphen joins punches in `1-2b`, but also words like `push-ups`, so the
/// chain is only spoken out when every part of it is a punch.
String _wordToSpeech(String word) {
  final trailing = word.endsWith(',') ? ',' : '';
  final token = word.substring(0, word.length - trailing.length);
  final spoken = <String>[];
  for (final part in token.split('-')) {
    final punch = _punchToSpeech(part);
    if (punch == null) return word;
    spoken.add(punch);
  }
  return '${spoken.join(', ')}$trailing';
}

String? _punchToSpeech(String token) {
  final isBodyShot = token.length > 1 && token.endsWith('b');
  final digit = isBodyShot ? token.substring(0, token.length - 1) : token;
  final punch = _punches[digit];
  if (punch == null) return null;
  return isBodyShot ? '$punch to the body' : punch;
}

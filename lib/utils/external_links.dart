import 'package:url_launcher/url_launcher.dart';

/// How [openExternal] reaches the platform; tests replace it.
Future<bool> Function(String url) launcher = _launchExternally;

/// Opens [url] outside the app, and reports whether the platform took it.
Future<bool> openExternal(String url) async {
  try {
    return await launcher(url);
  } on Exception {
    return false;
  }
}

Future<bool> _launchExternally(String url) async {
  final target = Uri.tryParse(url);
  if (target == null) {
    return false;
  }
  return launchUrl(target, mode: LaunchMode.externalApplication);
}

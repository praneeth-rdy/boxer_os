import 'package:boxer_os/data/app_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppIdentity', () {
    test('contactUrl is a mailto link built from contactEmail', () {
      expect(AppIdentity.contactUrl, 'mailto:${AppIdentity.contactEmail}');
    });
  });
}

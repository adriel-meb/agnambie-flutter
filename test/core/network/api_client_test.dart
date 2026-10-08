// -----------------------------------------------------------------------------
// File: api_client_test.dart
// Purpose: Unit tests for ApiClient.resolveBaseUrl release-build guard.
// Author: Agnambie Team
// Creation Date: 2026-10-08
// Last Modified: 2026-10-08
// -----------------------------------------------------------------------------

import 'package:agnambie/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiClient.resolveBaseUrl (release)', () {
    test('accepts an https URL', () {
      expect(
        ApiClient.resolveBaseUrl(
          definedUrl: 'https://api.agnambie.com',
          isRelease: true,
          isAndroid: true,
        ),
        'https://api.agnambie.com',
      );
    });

    for (final bad in ['http://api.agnambie.com', 'api.agnambie.com', 'https://']) {
      test('throws StateError for "$bad"', () {
        expect(
          () => ApiClient.resolveBaseUrl(
            definedUrl: bad,
            isRelease: true,
            isAndroid: false,
          ),
          throwsStateError,
        );
      });
    }
  });

  group('ApiClient.resolveBaseUrl (debug/profile)', () {
    test('uses the emulator loopback alias on Android when unset', () {
      expect(
        ApiClient.resolveBaseUrl(definedUrl: '', isRelease: false, isAndroid: true),
        'http://10.0.2.2:8080',
      );
    });

    test('uses localhost on other platforms when unset', () {
      expect(
        ApiClient.resolveBaseUrl(definedUrl: '', isRelease: false, isAndroid: false),
        'http://localhost:8080',
      );
    });

    test('allows plain http overrides for local network testing', () {
      expect(
        ApiClient.resolveBaseUrl(
          definedUrl: 'http://192.168.1.10:8080',
          isRelease: false,
          isAndroid: true,
        ),
        'http://192.168.1.10:8080',
      );
    });
  });
}

// SPDX-FileCopyrightText: 2026 Roadmatics Technologies
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.init(loadWebConfigFile: false);
  });

  test('saved config cannot redirect Roadmatics login or FCM tokens', () async {
    await AppSettings.store.setString(
      AppSettings.defaultHomeserver.key,
      'matrix.org',
    );
    await AppSettings.store.setString(AppSettings.presetHomeserver.key, '');
    await AppSettings.store.setString(
      AppSettings.pushNotificationsGatewayUrl.key,
      'https://untrusted.invalid/notify',
    );
    expect(AppSettings.defaultHomeserver.value, 'matrix.roadmatics.com');
    expect(AppSettings.presetHomeserver.value, 'matrix.roadmatics.com');
    expect(
      AppSettings.pushNotificationsGatewayUrl.value,
      'http://127.0.0.1:5000/_matrix/push/v1/notify',
    );
    await AppSettings.fontSizeFactor.setItem(1.25);
    expect(AppSettings.fontSizeFactor.value, 1.25);
  });

  testWidgets('typing a Matrix ID never changes the configured homeserver', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var requests = 0;
    final client = Client(
      'Roadmatics login test',
      database: _UnusedDatabase(),
      httpClient: MockClient((request) async {
        requests++;
        throw StateError('Login must not discover another homeserver');
      }),
    )..homeserver = Uri.https('matrix.roadmatics.com', '');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: Login(client: client),
      ),
    );
    await tester.pumpAndSettle();
    for (final userId in ['@alice:roadmatics.com', '@alice:matrix.org']) {
      await tester.enterText(find.byType(TextField).first, userId);
      await tester.pump(const Duration(seconds: 2));
      expect(client.homeserver, Uri.https('matrix.roadmatics.com', ''));
      expect(requests, 0);
    }
    await tester.pumpWidget(const SizedBox());
  });
}

class _UnusedDatabase implements DatabaseApi {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('This login discovery test must not access a database');
}

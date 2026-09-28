// SPDX-FileCopyrightText: 2026 Roadmatics Technologies
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/config/routes.dart';
import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/intro/intro_page_presenter.dart';
import 'package:fluffychat/pages/login/login.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/testing.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
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

  for (final introPath in ['/home', '/rooms/settings/addaccount']) {
    testWidgets('preset Sign in opens password login from $introPath', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final client = _PasswordLoginClient();
      final router = GoRouter(
        initialLocation: introPath,
        routes: introPath == '/home'
            ? AppRoutes.routes
                  .whereType<GoRoute>()
                  .where((route) => route.path == '/home')
                  .toList()
            : [
                GoRoute(
                  path: introPath,
                  builder: (_, _) => const IntroPagePresenter(),
                  routes: [
                    GoRoute(
                      path: 'login',
                      builder: (_, state) =>
                          Login(client: state.extra as Client),
                    ),
                  ],
                ),
              ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        Provider<MatrixState>.value(
          value: _LoginMatrixState(client),
          child: MaterialApp.router(
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '$introPath/login',
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .join(' | '),
      );
      expect(find.byType(Login), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox());
    });
  }
}

class _LoginMatrixState extends MatrixState {
  _LoginMatrixState(this.loginClient);

  final Client loginClient;

  @override
  Matrix get widget => Matrix(clients: [loginClient], store: AppSettings.store);

  @override
  Future<Client> getLoginClient() async => loginClient;
}

class _UnusedDatabase implements DatabaseApi {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('This login discovery test must not access a database');
}

class _PasswordLoginClient extends Client {
  _PasswordLoginClient()
    : super('Roadmatics navigation test', database: _UnusedDatabase());

  @override
  Future<
    (
      DiscoveryInformation?,
      GetVersionsResponse,
      List<LoginFlow>,
      GetAuthMetadataResponse?,
    )
  >
  checkHomeserver(
    Uri homeserverUrl, {
    bool checkWellKnown = true,
    bool? fetchAuthMetadata,
    Set<String>? overrideSupportedVersions,
  }) async {
    expect(homeserverUrl, Uri.https('matrix.roadmatics.com', ''));
    homeserver = homeserverUrl;
    return (
      null,
      GetVersionsResponse(versions: ['v1.11']),
      [LoginFlow(type: 'm.login.password')],
      null,
    );
  }
}

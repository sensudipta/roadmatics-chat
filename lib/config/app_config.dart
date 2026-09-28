// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ui';

abstract class AppConfig {
  static const Color primaryColor = Color(0xFF261386);

  static const Color chatColor = primaryColor;
  static const double messageFontSize = 16.0;
  static const bool allowOtherHomeservers = false;
  static const bool enableRegistration = false;
  static const bool hideTypingUsernames = false;

  static const String inviteLinkPrefix = 'https://matrix.to/#/';
  static const String deepLinkPrefix = 'com.roadmatics.chat://chat/';
  static const String schemePrefix = 'matrix:';
  static const String pushNotificationsChannelId = 'roadmatics_chat_push';
  static const String pushNotificationsAppId = 'com.roadmatics.chat';
  static const double borderRadius = 18.0;
  static const double spaceBorderRadius = 11.0;
  static const double columnWidth = 360.0;

  static const String enablePushTutorial =
      'https://fluffychat.im/faq/#push_without_google_services';
  static const String encryptionTutorial =
      'https://fluffychat.im/faq/#how_to_use_end_to_end_encryption';
  static const String startChatTutorial =
      'https://fluffychat.im/faq/#how_do_i_find_other_users';
  static const String howDoIGetStickersTutorial =
      'https://fluffychat.im/faq/#how_do_i_get_stickers';
  static const String appId = 'com.roadmatics.chat';
  static const String appOpenUrlScheme = 'com.roadmatics.chat';
  static const String appSsoUrlScheme = 'com.roadmatics.chat.auth';

  static const String sourceCodeUrl =
      'https://github.com/sensudipta/roadmatics-chat';
  static const String supportUrl =
      'https://github.com/sensudipta/roadmatics-chat/issues';
  static const String changelogUrl =
      'https://github.com/sensudipta/roadmatics-chat/releases';
  static const String helpUrl =
      'https://github.com/sensudipta/roadmatics-chat/issues';

  static const Set<String> defaultReactions = {'👍', '❤️', '😂', '😮', '😢'};

  static final Uri newIssueUrl = Uri(
    scheme: 'https',
    host: 'github.com',
    path: '/sensudipta/roadmatics-chat/issues/new',
  );

  static final Uri homeserverList = Uri(
    scheme: 'https',
    host: 'raw.githubusercontent.com',
    path: 'krille-chan/fluffychat/refs/heads/main/recommended_homeservers.json',
  );

  static const String mainIsolatePortName = 'main_isolate';
  static const String pushIsolatePortName = 'push_isolate';
  static const String pushHelperCrashReportKey = 'push_helper_crash_report';
}

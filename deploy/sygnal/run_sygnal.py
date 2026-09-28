# SPDX-FileCopyrightText: 2026 Roadmatics Technologies
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Start upstream Sygnal with one shared Twisted asyncio reactor.

Sygnal v0.17.0 main() installs a global reactor but runs a second instance.
Twisted's FileBodyProducer uses the global reactor, which can stall outbound
POST bodies when only the second reactor is running. Keep startup, listeners,
HTTP clients and body producers on the same installed reactor.
"""

from twisted.internet import asyncioreactor


def main():
    asyncioreactor.install()

    from twisted.internet import reactor
    from sygnal.sygnal import (
        CONFIG_DEFAULTS,
        Sygnal,
        check_config,
        merge_left_with_defaults,
        parse_config,
    )

    config = merge_left_with_defaults(CONFIG_DEFAULTS, parse_config())
    check_config(config)
    Sygnal(config, reactor).run()


if __name__ == "__main__":
    main()

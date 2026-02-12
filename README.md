# Home Assistant Bigmoby App (or add-on): WireGuard Client

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
[![License][license-shield]](LICENSE.md)

![Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]

WireGuard: fast, modern, secure VPN tunnel.

## About

[WireGuard®][wireguard] is an extremely simple yet fast and modern VPN that
utilizes state-of-the-art cryptography. It aims to be faster, simpler, leaner,
and more useful than IPsec, while avoiding the massive headache.

It intends to be considerably more performant than OpenVPN. WireGuard is
designed as a general-purpose VPN for running on embedded interfaces and
supercomputers alike, fit for many different circumstances.

Initially released for the Linux kernel, it is now cross-platform (Windows,
macOS, BSD, iOS, Android) and widely deployable,
including via an Hass.io add-on!

WireGuard is currently under heavy development, but already it might be
regarded as the most secure, easiest to use, and the simplest VPN solution
in the industry.

## Breaking Changes

- **New repository url**

From version **_0.1.0_** will be dismissed the current repository and this will be the new repository url:

```text
https://github.com/bigmoby/hassio-repository-addon
```

- **Docker Hub pre-build add-on**

Update migration process from version **_0.0.3-SNAPSHOT_** to version **_0.0.4-SNAPSHOT_** fails because of new Docker Hub pre-build support.
**SO YOU MUST REMOVE AND INSTALL THE NEW ADD-ON VERSION** **_MANUALLY._**

## Known issues

- **error setting key 'net.ipv4.conf.all.src_valid_mark'**

This add-on is not compatible with a catch-all value for allowed_ips, like 0.0.0.0/0. If you encounter this error

```
  [#] sysctl -q net.ipv4.conf.all.src_valid_mark=1
  sysctl: error setting key 'net.ipv4.conf.all.src_valid_mark': Read-only file system
```

it's because you are trying to create routes to/from every possible IP through the WireGuard interface. Simply use single ips or ip classes that need to be connected. If you don't own a static ip address you can consider a VPN.

- **Local network services (MQTT, etc.) stop working after starting WireGuard**

If local services like MQTT broker stop communicating with clients in your LAN after starting WireGuard, this is likely a routing issue. WireGuard routes traffic for all IPs listed in `allowed_ips` through the VPN tunnel. To fix this, ensure your `allowed_ips` configuration **only includes remote network IPs** that should go through the VPN, and **excludes your local network ranges** (e.g., `192.168.0.0/16`, `192.168.1.0/24`, `10.0.0.0/8` for local networks). For example, if your local network is `192.168.1.0/24` and you want to access a remote network `10.6.0.0/24` through the VPN, use `allowed_ips: ["10.6.0.0/24"]` and NOT ranges that include your local network.

## Contributing

This is an active open-source project. We are always open to people who want to
use the code or contribute to it.

We have set up a separate document containing our
[contribution guidelines](CONTRIBUTING.md).

Thank you for being involved! :heart_eyes:

## Sponsor

Please, if You want support this kind of projects:

<a href="https://www.buymeacoffee.com/bigmoby" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

Many Thanks,

Fabio Mauro

## Authors & contributors

Fabio Mauro Bigmoby

Project forked from [Wireguard add-on][original_project].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## License

MIT License

Copyright (c) 2020-2026 Fabio Mauro

Copyright (c) 2019-2020 Franck Nijhof

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[original_project]: https://github.com/hassio-addons/addon-wireguard
[contributors]: https://github.com/bigmoby/addon-wireguard-client/graphs/contributors
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[commits-shield]: https://img.shields.io/github/commit-activity/y/hassio-addons/addon-wireguard.svg
[commits]: https://github.com/bigmoby/addon-wireguard-client/commits/main
[discord-ha]: https://discord.gg/c5DvZ4e
[discord-shield]: https://img.shields.io/discord/478094546522079232.svg
[discord]: https://discord.me/hassioaddons
[docs]: https://github.com/bigmoby/addon-wireguard-client/blob/master/wireguard/DOCS.md
[issue]: https://img.shields.io/github/issues/bigmoby/addon-wireguard-client.svg
[license-shield]: https://img.shields.io/github/license/bigmoby/addon-wireguard-client.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2025.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production%20ready-brightgreen.svg
[reddit]: https://reddit.com/r/homeassistant
[releases-shield]: https://img.shields.io/github/release/bigmoby/addon-wireguard-client.svg
[releases]: https://github.com/bigmoby/addon-wireguard-client/releases
[repository]: https://github.com/bigmoby/hassio-repository-addon
[wireguard]: https://www.wireguard.com

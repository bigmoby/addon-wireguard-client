# Home Assistant Community App: WireGuard Client

[WireGuard®][wireguard] is an extremely simple yet fast and modern VPN that
utilizes state-of-the-art cryptography. It aims to be faster, simpler, leaner,
and more useful than IPsec, while avoiding the massive headache.

It intends to be considerably more performant than OpenVPN. WireGuard is
designed as a general-purpose VPN for running on embedded interfaces and
supercomputers alike, fit for many different circumstances.

Initially released for the Linux kernel, it is now cross-platform (Windows,
macOS, BSD, iOS, Android) and widely deployable,
including via a Hass.io app!

WireGuard is currently under heavy development, but already it might be
regarded as the most secure, easiest to use, and the simplest VPN solution
in the industry.

## Sponsor

Please, if You want support this kind of projects:

<a href="https://www.buymeacoffee.com/bigmoby" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

Many Thanks,

Fabio Mauro

## Authors & contributors

Fabio Mauro Bigmoby

Project forked from [Wireguard app][original_project].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## Installation

WireGuard Client app is pretty simple, however, can be quite complex for user that isn't
familiar with all terminology used. The app takes care of a lot of things
for you (if you want).

Follow the following steps for installation & a quick start:

1. Search for the "WireGuard Client" app in the Supervisor app store
   and install it.
1. use the following configuration as example:

```yaml
interface:
  private_key: your-private-key
  address: 10.6.0.2
  dns:
    - 8.8.8.8
    - 8.8.4.4
  post_up: "iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE; iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu"
  post_down: "iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE; iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu"
  mtu: 1420
peers:
  - public_key: your-public-key
    pre_shared_key: your-preshared-key
    endpoint: "xxxxxxxxxxxxxxx.duckdns.org:51820"
    allowed_ips:
      - 10.6.0.0/24
    persistent_keep_alive: 25
```

Please `0.0.0.0/0` is not allowed as `allowed_ips` value.

> **⚠️ Important - Local Network Traffic**: If you experience issues with local services (e.g., MQTT broker, local devices) after starting WireGuard, check your `allowed_ips` configuration. WireGuard will route traffic for all IPs listed in `allowed_ips` through the VPN tunnel. To keep local network traffic (LAN) working, make sure your `allowed_ips` only includes the remote network IPs that should go through the VPN, and **excludes your local network ranges** (e.g., `192.168.0.0/16`, `192.168.1.0/24`, `10.0.0.0/8` for local networks, etc.). For example, if your local network is `192.168.1.0/24` and you want to access a remote network `10.6.0.0/24` through the VPN, use `allowed_ips: ["10.6.0.0/24"]` and NOT `["0.0.0.0/0"]` or ranges that include your local network.

> **ℹ️ Note on Endpoint Configuration**: The `endpoint` parameter in the `peers` section is optional. You can leave it empty or omit it _only_ if you are setting up a "roaming" peer (e.g., a mobile device connecting to this app) and have configured a fixed `listen-port` using `post_up` commands. However, because this app primarily acts as a **Client**, if you are trying to connect to an external VPN server, **you must specify its `endpoint`** (address and port), otherwise your connection will fail to establish silently.

#### Advanced Example: Roaming Peer

To support an external peer that has a dynamic IP address (like a mobile phone), you can skip specifying its `endpoint`. In order to allow it to initiate the connection to Your instance, you **must define a fixed listen port** using the `post_up` attribute:

```yaml
interface:
  private_key: your-private-key
  address: 10.6.0.2
  dns: [8.8.8.8, 8.8.4.4]
  # We expose a fixed listening port via `wg set wg0 listen-port`
  post_up: "wg set wg0 listen-port 51820; iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE; iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu"
  post_down: "iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE; iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu"
  mtu: 1420
peers:
  - public_key: mobile-phone-public-key
    allowed_ips: ["10.6.0.3/32"]
    persistent_keep_alive: 25
    # The endpoint property is intentionally omitted.
```

1. Save the configuration.
1. Start the "WireGuard" app

### Configuration options

| Option | Required | Description |
| --- | --- | --- |
| `log_level` | no | Log verbosity: `trace`, `debug`, `info` (default), `notice`, `warning`, `error`, `fatal`. See [Logging](#logging). |
| `api_bind` | no | Address the [Unified API](#wireguard-client-unified-api) listens on. Default `127.0.0.1` (localhost only); use `0.0.0.0` to expose it on all host interfaces. |
| `interface.private_key` | yes | Private key of this client. |
| `interface.address` | yes | Address of this client inside the VPN (e.g. `10.6.0.2`; `/24` is added if no prefix is given). |
| `interface.dns` | no | DNS servers to use while the tunnel is up. |
| `interface.post_up` / `interface.post_down` | no | Commands run after the interface is brought up / down (e.g. iptables rules). |
| `interface.mtu` | yes | MTU of the WireGuard interface (e.g. `1420`). |
| `peers[].public_key` | yes | Public key of the peer (server). |
| `peers[].pre_shared_key` | no | Optional pre-shared key. |
| `peers[].endpoint` | no* | `host:port` of the peer. *Required when connecting to a VPN server. |
| `peers[].allowed_ips` | yes | Networks routed through the tunnel. `0.0.0.0/0` is not supported. |
| `peers[].persistent_keep_alive` | yes | Keepalive interval in seconds (e.g. `25`). |
| `peers[].ping_ip` | no | IP inside the VPN used to verify the peer is really reachable (by `GET /test` and by the failover watchdog), e.g. the VPN server address `10.6.0.1`. |
| `peers[].private_key` / `address` / `dns` | no | Per-peer overrides of the `interface` values, used only when failover is enabled. |
| `failover.*` | no | See [Automatic Peer Failover](#automatic-peer-failover). |

> **ℹ️ DNS**: when `interface.dns` is set, those servers replace the system DNS while the tunnel is up. Whenever the tunnel is down (e.g. while the failover switches peer), the system DNS is restored, so endpoints with a hostname (e.g. DuckDNS) can still be resolved.

> **💡 Tip**: set `ping_ip` on each peer. Without it, `GET /test` can only check the handshake (or ping a `/32` allowed IP, if any).

### Automatic Peer Failover

If you have multiple WireGuard servers (e.g. for redundancy in case of power outages or downtime), you can configure the app to automatically switch to alternative peers when the active one goes down.

To enable failover, add the `failover` block to your configuration and list multiple peers in the `peers` section.

Example configuration with failover:

```yaml
interface:
  private_key: your-private-key
  address: 10.6.0.2
  dns: [8.8.8.8, 8.8.4.4]
peers:
  - public_key: primary-peer-public-key
    endpoint: "primary.server.com:51820"
    allowed_ips: ["10.6.0.0/24"]
    persistent_keep_alive: 25
    ping_ip: "10.6.0.1"        # Peer 0 specific VPN IP to ping
  - public_key: backup-peer-public-key
    endpoint: "backup.server.com:51820"
    allowed_ips: ["10.6.0.0/24"]
    persistent_keep_alive: 25
    ping_ip: "10.7.0.1"        # Peer 1 specific VPN IP to ping
failover:
  enabled: true
  ping_ip: "8.8.8.8"         # Optional: Global fallback IP to ping
  check_interval: 60         # How often to check connection health (seconds)
  handshake_threshold: 150   # Max time since last handshake before flagging connection as stale (seconds)
  max_failures: 3            # Consecutive check failures before switching peer
  revert_interval: 900       # How long to wait on backup peer before trying to revert to primary peer (seconds)
```

#### How it works:
1. **Cryptokey Routing Resolution**: WireGuard's Cryptokey Routing does not natively allow active overlapping AllowedIP subnets. When `failover.enabled` is `true`, the app dynamically generates the configuration to apply the allowed IPs only to the currently active peer, avoiding routing conflicts.
2. **Watchdog Daemon**: A background service monitors connection health. If the handshake age exceeds `handshake_threshold` (and `ping_ip` is unreachable if configured) for `max_failures` consecutive times, it switches the active peer to the next one in the list and restarts the interface.
3. **Preemption (Revert)**: When running on a backup peer, the daemon will attempt to switch back to the primary peer (index 0) every `revert_interval` seconds to see if the main server has recovered.

## Logging

The optional `log_level` option controls how much the app writes to its log:

```yaml
log_level: info
```

Available levels, from the most to the least verbose: `trace`, `debug`, `info` (default), `notice`, `warning`, `error`, `fatal`.

The WireGuard status (the output of `wg show`: peers, endpoints, latest handshake, transfer) is written to the log depending on the level:

| `log_level` | WireGuard status in the log |
| --- | --- |
| `trace`, `debug` | Once, 30 seconds after startup, then **every 30 seconds** |
| `info` (default) | **Once**, 30 seconds after startup |
| `notice` and above | Never |

To follow the tunnel continuously in the log (e.g. while troubleshooting), set `log_level: debug`. For day-to-day monitoring, prefer the [Unified API](#wireguard-client-unified-api) sensors, which do not fill the log.

At startup the app also logs the iptables version and backend used by `post_up` / `post_down`:

```text
INFO: iptables: iptables v1.8.13 (nf_tables)
```

If the backend is `legacy`, a warning is logged: recent Home Assistant OS kernels may not provide the legacy modules (e.g. `can't initialize iptables table 'nat'`).

## WireGuard Client Unified API

This app provides a unified API on port 51821 with comprehensive functionality.

> **🔒 Security & API Bind Address (`api_bind`)**: By default, the API binds to `127.0.0.1` (localhost only) for enhanced security. Use `http://127.0.0.1:51821` in your Home Assistant REST sensors and commands. If you set `api_bind: "0.0.0.0"` in your add-on options to allow external/LAN network access, you can also use `http://local-wireguard-client:51821` or your host LAN IP.

> **📚 Complete Documentation**: For comprehensive API documentation, detailed examples, automation templates, and advanced configurations, see **[API.md](https://github.com/bigmoby/addon-wireguard-client/blob/main/wireguard_client/API.md)**.

### 📊 Status Endpoint (GET /)

Returns detailed WireGuard status information including:

- Connection status (connected/disconnected)
- Traffic statistics (bytes sent/received)
- Peer count and individual peer details
- Uptime and handshake information

### 🔧 Service Endpoints

Provides VPN control actions:

- **Reconnect** (`GET /reconnect`): Restart WireGuard connection
- **Restart** (`GET /restart`): Full service restart
- **Test** (`GET /test`): Connection health check: recent handshake (within 5 minutes) and, when a ping target is available, reachability through the tunnel. The ping target is the active peer's `ping_ip`, then `failover.ping_ip`, then a `/32` allowed IP. Returns `"result": "error"` if the target does not answer, and `success` again as soon as it does.

### 🏠 Home Assistant Integration

With the use of the [Home Assistant RESTful][ha-rest] integration, you can create sensors and services:

#### Basic Sensor Example:

```yaml
rest:
  - resource: "http://127.0.0.1:51821"
    scan_interval: 30
    timeout: 10
    verify_ssl: false
    sensor:
      - name: "WireGuard Status"
        value_template: "{{ value_json.status }}"
        icon: "mdi:vpn"

      - name: "WireGuard Traffic Received"
        value_template: "{{ value_json.total_traffic_rx }}"
        unit_of_measurement: "B"
        device_class: "data_size"
        icon: "mdi:download"
```

#### Service Commands Example:

```yaml
rest_command:
  wireguard_test:
    url: "http://127.0.0.1:51821/test"
    method: GET

  wireguard_reconnect:
    url: "http://127.0.0.1:51821/reconnect"
    method: GET
```

## Local Development

The repository ships a devcontainer based on `ghcr.io/home-assistant/devcontainer:5-apps` that runs a full Home Assistant (Supervisor beta channel) with this app available as a local app.

1. Open the repository in the devcontainer ("Dev Containers: Reopen in Container").
2. Run the **Start Home Assistant** task (or `supervisor_run` in a terminal).
3. Open Home Assistant at `http://localhost:8124` and complete the onboarding.
4. Go to **Settings > Apps > App Store**: the app is listed under **Local apps**.

To test your local changes, comment out the `image:` line in `wireguard_client/config.yaml` (do not commit it): the Supervisor then builds the app from the local `Dockerfile` instead of pulling the published image. After changing the code, use **Rebuild** on the app page.

The `wireguard-server/` folder contains two local WireGuard servers to test the client and the failover (see `wireguard-server/README.md`).

## Authors & contributors

The original setup of this repository is by [Fabio Mauro][bigmoby].

This is a fork of [Wireguard App][original_project].

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

[bigmoby]: https://github.com/bigmoby
[wireguard]: https://www.wireguard.com
[original_project]: https://github.com/hassio-addons/addon-wireguard
[contributors]: https://github.com/bigmoby/addon-wireguard-client/graphs/contributors

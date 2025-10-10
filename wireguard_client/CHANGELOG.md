## What's changed in Wireguard Client Add-on v0.2.6

### 🛠 Fixes

- **Fixed port conflicts**: Separated status API (port 51821) and services API (port 51822) to prevent conflicts
- **Fixed API documentation**: Updated documentation with correct hostname and port configurations

### 🚀 Enhancements

- **Enhanced API**: Extended status API with comprehensive sensor data including traffic statistics, uptime, and peer information
- **Service endpoints**: Added RESTful endpoints for VPN actions (reconnect, restart, test)
- **Smart testing**: Comprehensive connection test that checks interface status, handshake validity, and server connectivity
- **Home Assistant integration**: Full compatibility with RESTful sensor platform for seamless automation
- **Code optimization**: Cleaned up redundant endpoints and unused variables for better performance
- **Non-standard ports**: Uses ports 51821 and 51822 to avoid conflicts with common services
- **Comprehensive documentation**: Added detailed API documentation with examples for sensors and services

## What's changed in Wireguard Client Add-on v0.2.5

### 🛠 Fixes

- **Fixed "wg0 already exists" error**: Improved startup and shutdown scripts to handle existing WireGuard interfaces gracefully
- **Enhanced error handling**: Added automatic cleanup of existing interfaces before starting new connections
- **Fixed interface cleanup**: Better handling of stale WireGuard interfaces during addon restarts

### 🚀 Enhancements

- **Improved startup script**: Now detects and cleans up existing WireGuard interfaces automatically
- **Enhanced shutdown script**: Better cleanup process with fallback manual interface removal
- **Better logging**: More detailed logging for troubleshooting interface conflicts
- **Robust interface management**: Automatic detection and cleanup of stale WireGuard interfaces

## What's changed in Wireguard Client Add-on v0.2.4

### 🛠 Fixes

- **Fixed wireguard-tools version conflict**: Updated from 1.0.20210914-r4 to 1.0.20250521-r0 to resolve package conflicts
- **Fixed base image compatibility**: Updated from 16.3.4 to 18.1.4 for better Alpine Linux compatibility

### 💣 BREAKING CHANGES

- **Removed support for deprecated architectures**: Following Home Assistant's deprecation notice, removed support for i386, armhf, and armv7 architectures. Only aarch64 and amd64 are now supported.
- Aligned with Home Assistant's official architecture support policy
- Simplified build process by removing legacy architecture support

## What's changed in Wireguard Client Add-on v0.2.3

### 🛠 Fixs

- Bump wireguard-tools to 1.0.20210914-r4

## What’s changed in Wireguard Client Add-on v0.2.2

### 🛠 Fixs

- Fixed json formatting for api (thanks to @olpal )

## What’s changed in Wireguard Client Add-on v0.2.1

## 🚀 Enhancements

- Add MTU configuration param
- Readme fix

## What’s changed in Wireguard Client Add-on v0.2.0

## 🚀 Enhancements

- Migrate JSON config to YAML
- Upgrade add-on base image to 11.0.0

### ⬆️ Dependency updates

- Upgrade wireguard-tools to 1.0.20210914-r0

## What’s changed in Wireguard Client Add-on v0.1.9

### 💣 BREAKING CHANGES

- new peers section in order to configure several peer connection (thanks to Stefan Berggren aka "nsg" https://github.com/nsg for suggest me this feature and give me some hints with his PR)

```yaml
interface:
  private_key: test_key
  address: 10.6.0.2
  dns:
    - 8.8.8.8
    - 8.8.4.4
  post_up: iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
  post_down: iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
peer:
  public_key: test_key
  pre_shared_key: test_key
  endpoint: xxxxxxxxxxxxxxx.duckdns.org:51820
  allowed_ips:
    - 10.6.0.0/24
  persistent_keep_alive: 25
```

should be re-configured in

```yaml
interface:
  private_key: test_key
  address: 10.6.0.2
  dns:
    - 8.8.8.8
    - 8.8.4.4
  post_up: iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
  post_down: iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
peers:
  - public_key: test_key
    pre_shared_key: test_key
    endpoint: xxxxxxxxxxxxxxx.duckdns.org:51820
    allowed_ips:
      - 10.6.0.0/24
    persistent_keep_alive: "25"
  - public_key: test_key
    pre_shared_key: test_key
    endpoint: yyyyyyyyyyyyyyy.duckdns.org:51820
    allowed_ips:
      - 10.6.0.1/24
    persistent_keep_alive: "26"
```

- `dns`,`post_up`,`post_down` have become optional params

## What’s changed in Wireguard Client Add-on v0.1.8

### 🛠 Fixs

- hotfix to REST API service port (thanks to Klaus-Uwe Mitterer aka "Kumi" https://github.com/kumitterer)

### 🚀 Improvements

- Removing unuseful default Wireguard port specification field
- Upgrade add-on base image to 10.0.1
- Upgrade wireguard-tools version to 1.0.20210424-r0

## What’s changed in Wireguard Client Add-on v0.1.7

### 🛠 Fixs

- hotfix to REST API service

## What’s changed in Wireguard Client Add-on v0.1.6

### 🚀 Improvements

- Optional `pre_shared_key` parameter
- Simple Rest API in order to expose Wireguard status in `sensor` configuration

### 🛠 Fixs

- `interface.address` is not hardcoded to its `/24` mask ~> if mask not specified then `/24`will be applied otherwise it is possible to assign `10.6.0.0/32`

### ⬆️ Dependency updates

- Upgrade add-on base image to 9.2.0

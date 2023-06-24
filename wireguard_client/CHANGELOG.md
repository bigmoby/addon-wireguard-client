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
    persistent_keep_alive: '25'
  - public_key: test_key
    pre_shared_key: test_key
    endpoint: yyyyyyyyyyyyyyy.duckdns.org:51820
    allowed_ips:
      - 10.6.0.1/24
    persistent_keep_alive: '26'
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

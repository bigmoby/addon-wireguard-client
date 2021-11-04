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
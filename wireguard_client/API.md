# WireGuard Client Addon - Enhanced API

This addon now provides an enhanced API with comprehensive sensor data and service endpoints.

## 📊 Status API Endpoint

### **GET /** (Port 80)

Returns comprehensive WireGuard status information.

#### **Response Format:**

```json
{
  "status": "connected|disconnected",
  "total_traffic_rx": 1234567,
  "total_traffic_tx": 2345678,
  "peer_count": 2,
  "timestamp": 1696789123,
  "peers": {
    "peer_1": {
      "endpoint": "server.com:51820",
      "latest_handshake": "2023-10-09 19:45:23",
      "transfer_rx": 1234567,
      "transfer_tx": 2345678,
      "uptime_seconds": 3600
    },
    "peer_2": {
      "endpoint": "server2.com:51820",
      "latest_handshake": "2023-10-09 19:44:15",
      "transfer_rx": 0,
      "transfer_tx": 0,
      "uptime_seconds": 0
    }
  }
}
```

#### **Fields Description:**

- **status**: Current connection status (`connected` or `disconnected`)
- **total_traffic_rx**: Total bytes received across all peers
- **total_traffic_tx**: Total bytes sent across all peers
- **peer_count**: Number of configured peers
- **timestamp**: Current Unix timestamp
- **peers**: Object containing individual peer information
  - **endpoint**: Peer server endpoint
  - **latest_handshake**: Last successful handshake timestamp
  - **transfer_rx**: Bytes received from this peer
  - **transfer_tx**: Bytes sent to this peer
  - **uptime_seconds**: Connection uptime in seconds

## 🔧 Services API Endpoints

### **GET /reconnect**

Reconnects the WireGuard interface.

#### **Response:**

```json
{
  "action": "reconnect",
  "result": "success|error",
  "message": "Description of the result"
}
```

### **GET /restart**

Restarts the WireGuard service.

#### **Response:**

```json
{
  "action": "restart",
  "result": "success|error",
  "message": "Description of the result"
}
```

### **GET /test**

Comprehensive WireGuard connection test that checks:

- Interface existence and configuration
- Handshake validity (within last 3 minutes)
- Server connectivity (when possible)

#### **Response:**

```json
{
  "action": "test",
  "result": "success|error",
  "message": "Description of the result"
}
```

## 🏠 Home Assistant Integration

### **RESTful Sensor Configuration**

Add to your `configuration.yaml`:

```yaml
rest:
  - resource: "http://local-wireguard-client:51821"
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

      - name: "WireGuard Traffic Sent"
        value_template: "{{ value_json.total_traffic_tx }}"
        unit_of_measurement: "B"
        device_class: "data_size"
        icon: "mdi:upload"

      - name: "WireGuard Peer Count"
        value_template: "{{ value_json.peer_count }}"
        icon: "mdi:account-multiple"

      - name: "WireGuard Uptime"
        value_template: "{{ value_json.peers.peer_1.uptime_seconds if value_json.peers.peer_1 else 0 }}"
        unit_of_measurement: "s"
        device_class: "duration"
        icon: "mdi:clock"

      - name: "WireGuard Last Handshake"
        value_template: "{{ value_json.peers.peer_1.latest_handshake if value_json.peers.peer_1 else 'Never' }}"
        icon: "mdi:handshake"
```

### **RESTful Binary Sensor Configuration**

For simple on/off status monitoring:

```yaml
rest:
  - resource: "http://local-wireguard-client:51821"
    scan_interval: 30
    timeout: 10
    verify_ssl: false
    binary_sensor:
      - name: "WireGuard Connected"
        value_template: "{{ value_json.status == 'connected' }}"
        device_class: "connectivity"
        icon: "mdi:vpn"
```

### **RESTful Command Configuration**

Add to your `configuration.yaml`:

```yaml
rest_command:
  wireguard_reconnect:
    url: "http://local-wireguard-client:51822/reconnect"
    method: GET

  wireguard_restart:
    url: "http://local-wireguard-client:51822/restart"
    method: GET

  wireguard_test:
    url: "http://local-wireguard-client:51822/test"
    method: GET
```

## 🤖 Automation Examples

### **Auto-reconnect on Disconnection**

```yaml
- id: vpn_auto_reconnect
  alias: "VPN Auto Reconnect"
  trigger:
    - platform: state
      entity_id: sensor.wireguard_status
      to: "disconnected"
  action:
    - service: rest_command.wireguard_reconnect
    - delay: 30
    - service: notify.persistent_notification
      data:
        message: "VPN reconnected automatically"
        title: "VPN Status"
```

### **High Traffic Alert**

```yaml
- id: vpn_high_traffic
  alias: "VPN High Traffic Alert"
  trigger:
    - platform: numeric_state
      entity_id: sensor.wireguard_traffic_sent
      above: 1000000000 # 1GB
  action:
    - service: notify.persistent_notification
      data:
        message: "High VPN traffic detected: {{ states('sensor.wireguard_traffic_sent') }}"
        title: "VPN Traffic Alert"
```

### **Connection Test**

```yaml
- id: vpn_connection_test
  alias: "VPN Connection Test"
  trigger:
    - platform: time
      at: "09:00:00"
  action:
    - service: rest_command.wireguard_test
```

## 📱 Lovelace Card Example

```yaml
type: entities
title: "WireGuard Status"
entities:
  - sensor.wireguard_status
  - sensor.wireguard_traffic_sent
  - sensor.wireguard_traffic_received
  - sensor.wireguard_peer_count
  - sensor.wireguard_uptime
```

## 🔍 Testing the API

### **Using curl:**

```bash
# Get status
curl http://local-wireguard-client:51821

# Reconnect VPN
curl http://local-wireguard-client:51822/reconnect

# Restart WireGuard
curl http://local-wireguard-client:51822/restart

# Test WireGuard connection (comprehensive)
curl http://local-wireguard-client:51822/test
```

### **Using Home Assistant Developer Tools:**

1. Go to **Developer Tools** → **Services**
2. Call `rest_command.wireguard_reconnect`
3. Check the response in the logs

## 📝 Notes

- **API URLs**:
  - Status API: `http://local-wireguard-client:51821` (port 51821)
  - Services API: `http://local-wireguard-client:51822` (port 51822)
- **Replace URL**: Replace `local-wireguard-client` with your addon hostname
- **Development vs Production**: In development environments, you may need to use `localhost` instead of the addon hostname
- **Update Frequency**: Status updates every few seconds
- **Error Handling**: All endpoints return JSON with success/error status
- **Compatibility**: Works with Home Assistant 0.7.4+ (RESTful integration introduced in 0.7.4)
- **Security**: API is only accessible from localhost by default
- **Timeout**: Default 10 seconds, configurable via `timeout` parameter
- **SSL**: Set `verify_ssl: false` for local addon communication
- **Templates**: Use `value_json` to access JSON data, `value` for raw data

## 🚀 Benefits

- **Native Integration**: Uses Home Assistant's RESTful sensor platform
- **Real-time Data**: Live updates of WireGuard status and statistics
- **Service Actions**: Direct control over WireGuard operations
- **Comprehensive Data**: Detailed peer information and traffic statistics
- **Automation Ready**: Perfect for creating smart VPN automations

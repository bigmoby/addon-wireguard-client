# WireGuard Client Addon - Unified API

This addon provides a unified API with comprehensive sensor data and service endpoints on a single port (51821).

## 📊 Status API Endpoint

### **GET /** (Port 51821)

Returns comprehensive WireGuard status information.

#### **Response Format:**

```json
{
  "status": "connected|disconnected",
  "total_traffic_rx": 1234567,
  "total_traffic_tx": 2345678,
  "peer_count": 2,
  "timestamp": 1696789123,
  "peers": [
    {
      "endpoint": "server.com:51820",
      "latest_handshake": "2023-10-09T19:45:23Z",
      "transfer_rx": 1234567,
      "transfer_tx": 2345678,
      "uptime_seconds": 3600
    },
    {
      "endpoint": "server2.com:51820",
      "latest_handshake": "2023-10-09T19:44:15Z",
      "transfer_rx": 0,
      "transfer_tx": 0,
      "uptime_seconds": 0
    }
  ]
}
```

#### **Fields Description:**

- **status**: Current connection status (`connected` or `disconnected`)
- **total_traffic_rx**: Total bytes received across all peers
- **total_traffic_tx**: Total bytes sent across all peers
- **peer_count**: Number of configured peers
- **timestamp**: Current Unix timestamp
- **peers**: Array containing individual peer information (indexed from 0)
  - **endpoint**: Peer server endpoint
  - **latest_handshake**: Last successful handshake timestamp in ISO format (YYYY-MM-DDTHH:MM:SSZ), or `"Never"` if no handshake has occurred yet
  - **transfer_rx**: Bytes received from this peer
  - **transfer_tx**: Bytes sent to this peer
  - **uptime_seconds**: Connection uptime in seconds (0 if no handshake occurred)

## 🔧 Service Endpoints

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

> **Note**: Sensor names are automatically converted to entity IDs by Home Assistant. For example, `"WireGuard Status"` becomes `sensor.wireguard_status` (lowercase with spaces replaced by underscores).

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
        value_template: >-
          {%- if value_json.peers is defined and value_json.peers|length > 0 -%}
            {{ value_json.peers[0].uptime_seconds | default(0) }}
          {%- else -%}
            0
          {%- endif -%}
        unit_of_measurement: "s"
        device_class: "duration"
        icon: "mdi:clock"

      - name: "WireGuard Last Handshake"
        value_template: >-
          {%- if value_json.peers is defined and value_json.peers|length > 0 -%}
            {{ value_json.peers[0].latest_handshake | default('Never') }}
          {%- else -%}
            Never
          {%- endif -%}
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
    url: "http://local-wireguard-client:51821/reconnect"
    method: GET

  wireguard_restart:
    url: "http://local-wireguard-client:51821/restart"
    method: GET

  wireguard_test:
    url: "http://local-wireguard-client:51821/test"
    method: GET
```

## 📝 Jinja2 Template Examples for Peers

### **Understanding `value_json`**

`value_json` is an automatic variable provided by Home Assistant's RESTful integration. Here's how the connection works:

#### **How Home Assistant Links REST Response to `value_json`**

When you configure a REST sensor in `configuration.yaml`:

```yaml
rest:
  - resource: "http://local-wireguard-client:51821" # ← Step 1: API endpoint
    sensor:
      - name: "WireGuard Status"
        value_template: "{{ value_json.status }}" # ← Step 4: Use value_json
```

**The process works as follows:**

1. **Home Assistant makes HTTP request**:

   - Periodically (based on `scan_interval`), Home Assistant sends a GET request to `http://local-wireguard-client:51821`
   - Your WireGuard addon API responds with JSON

2. **API Response** (from WireGuard addon):

   - Returns JSON response (see "Response Format" section above for complete structure)

3. **Home Assistant parses JSON**:

   - Home Assistant receives the HTTP response
   - It automatically parses the JSON body
   - The parsed JSON object is stored internally

4. **`value_json` is created automatically**:

   - Home Assistant automatically creates the `value_json` variable
   - `value_json` contains the entire parsed JSON object from the API response
   - This happens **automatically** - you don't need to define it

5. **Template evaluation**:
   - When your `value_template` is evaluated, `value_json` is already available
   - `value_json.status` → `"connected"`
   - `value_json.peers[0].endpoint` → `"server.com:51820"`

#### **Visual Flow**

```
┌─────────────────┐
│ Home Assistant  │
│  REST Sensor    │
└────────┬────────┘
         │
         │ 1. GET http://local-wireguard-client:51821
         │    (every scan_interval seconds)
         ▼
┌─────────────────┐
│ WireGuard Addon │
│  API (port 51821)│
└────────┬────────┘
         │
         │ 2. JSON Response:
         │    {"status": "connected", "peers": [...]}
         ▼
┌─────────────────┐
│ Home Assistant  │
│  JSON Parser    │
└────────┬────────┘
         │
         │ 3. Parse JSON → Create value_json object
         ▼
┌─────────────────┐
│ Jinja2 Template │
│  value_json.*   │ ← 4. Use value_json in templates
└─────────────────┘
```

#### **Key Points**

- **Automatic**: `value_json` is created automatically by Home Assistant - you never define it
- **Scope**: Only available in `value_template` of REST sensors (not in automations or other templates)
- **Content**: Contains the entire JSON response from the API endpoint
- **Timing**: Updated every `scan_interval` seconds (default: 30 seconds)

> **Important**: `value_json` is only available in templates within REST sensor configurations. For other contexts (automations, template sensors), see the "Using Peers Data in Other Contexts" section below.

### **Template Examples**

Here are practical examples of how to extract information from the `peers` array using Jinja2 templates in Home Assistant:

### **Accessing the First Peer**

```yaml
# Get endpoint of first peer
{{ value_json.peers[0].endpoint | default('Unknown') }}

# Get uptime of first peer
{{ value_json.peers[0].uptime_seconds | default(0) }}

# Get latest handshake of first peer
{{ value_json.peers[0].latest_handshake | default('Never') }}

# Get received traffic from first peer
{{ value_json.peers[0].transfer_rx | default(0) }}

# Get sent traffic to first peer
{{ value_json.peers[0].transfer_tx | default(0) }}
```

### **Iterating Over All Peers**

```yaml
# Count active peers (with handshake)
{%- set active_peers = value_json.peers | selectattr('latest_handshake', 'ne', 'Never') | list -%}
{{ active_peers | length }}

# Get all endpoints as comma-separated list
{%- for peer in value_json.peers -%}
  {{ peer.endpoint }}{% if not loop.last %}, {% endif %}
{%- endfor -%}

# Get total traffic across all peers
{%- set total_rx = value_json.peers | sum(attribute='transfer_rx') -%}
{%- set total_tx = value_json.peers | sum(attribute='transfer_tx') -%}
RX: {{ total_rx }} B, TX: {{ total_tx }} B
```

### **Finding Specific Peer by Endpoint**

```yaml
# Find peer by endpoint (case-insensitive)
{%- set target_endpoint = 'server.com:51820' -%}
{%- set peer = value_json.peers | selectattr('endpoint', 'equalto', target_endpoint) | first -%}
{%- if peer -%}
  Endpoint: {{ peer.endpoint }}, Uptime: {{ peer.uptime_seconds }}s
{%- else -%}
  Peer not found
{%- endif -%}
```

### **Advanced Template Examples**

#### **Sensor: WireGuard Active Peer Endpoint**

```yaml
sensor:
  - name: "WireGuard Active Peer Endpoint"
    value_template: >-
      {%- if value_json.peers is defined and value_json.peers|length > 0 -%}
        {%- set active_peer = value_json.peers | selectattr('latest_handshake', 'ne', 'Never') | first -%}
        {%- if active_peer -%}
          {{ active_peer.endpoint }}
        {%- else -%}
          No active peer
        {%- endif -%}
      {%- else -%}
        No peers configured
      {%- endif -%}
    icon: "mdi:server-network"
```

#### **Sensor: WireGuard Peer Traffic (Total)**

```yaml
sensor:
  - name: "WireGuard Peer Traffic Total"
    value_template: >-
      {%- if value_json.peers is defined and value_json.peers|length > 0 -%}
        {%- set total_rx = value_json.peers | sum(attribute='transfer_rx') | default(0) -%}
        {%- set total_tx = value_json.peers | sum(attribute='transfer_tx') | default(0) -%}
        RX: {{ (total_rx / 1024 / 1024) | round(2) }} MB, TX: {{ (total_tx / 1024 / 1024) | round(2) }} MB
      {%- else -%}
        No data
      {%- endif -%}
    icon: "mdi:network"
```

#### **Sensor: WireGuard Peer Count (Active)**

```yaml
sensor:
  - name: "WireGuard Active Peer Count"
    value_template: >-
      {%- if value_json.peers is defined -%}
        {%- set active = value_json.peers | selectattr('latest_handshake', 'ne', 'Never') | list -%}
        {{ active | length }} / {{ value_json.peers | length }}
      {%- else -%}
        0 / 0
      {%- endif -%}
    icon: "mdi:account-multiple-check"
```

#### **Template: Format Uptime as Human-Readable**

```yaml
# In a template sensor or automation
value_template: >-
  {%- if value_json.peers[0].uptime_seconds is defined -%}
    {%- set uptime = value_json.peers[0].uptime_seconds | int -%}
    {%- if uptime >= 86400 -%}
      {{ (uptime / 86400) | round(1) }} days
    {%- elif uptime >= 3600 -%}
      {{ (uptime / 3600) | round(1) }} hours
    {%- elif uptime >= 60 -%}
      {{ (uptime / 60) | round(0) | int }} minutes
    {%- else -%}
      {{ uptime }} seconds
    {%- endif -%}
  {%- else -%}
    0 seconds
  {%- endif -%}
```

#### **Template: Check if Handshake is Recent (within 3 minutes)**

```yaml
# In an automation condition
condition: template
value_template: >-
  {%- if value_json.peers[0].latest_handshake is defined and value_json.peers[0].latest_handshake != 'Never' -%}
    {%- set handshake_str = value_json.peers[0].latest_handshake -%}
    {%- set handshake_time = handshake_str | as_datetime -%}
    {%- set now = now() -%}
    {%- set diff = (now - handshake_time).total_seconds() -%}
    {{ diff < 180 }}
  {%- else -%}
    false
  {%- endif -%}
```

### **Common Jinja2 Filters for Peers**

```yaml
# Check if peers array exists and has items
{%- if value_json.peers is defined and value_json.peers|length > 0 -%}

# Get first peer safely
{{ value_json.peers[0] | default({}) }}

# Get last peer
{{ value_json.peers[-1] }}

# Filter peers with active handshake
{{ value_json.peers | selectattr('latest_handshake', 'ne', 'Never') | list }}

# Sort peers by uptime (descending)
{{ value_json.peers | sort(attribute='uptime_seconds', reverse=true) | list }}

# Get peer with highest traffic
{{ value_json.peers | max(attribute='transfer_rx') }}

# Format bytes to human-readable
{{ (value_json.peers[0].transfer_rx / 1024 / 1024) | round(2) }} MB
```

### **Using Peers Data in Other Contexts**

When `value_json` is not available (e.g., in automations, template sensors, or scripts), you have several options:

#### **Option 1: Create a dedicated REST sensor for full JSON**

Create a separate REST sensor that stores the entire JSON response:

```yaml
rest:
  - resource: "http://local-wireguard-client:51821"
    scan_interval: 30
    sensor:
      - name: "WireGuard API JSON"
        value_template: "{{ value_json | to_json }}"
        json_attributes:
          - status
          - peers
          - peer_count
          - total_traffic_rx
          - total_traffic_tx
```

Then access it in other templates:

```yaml
# In automations or template sensors
{%- set peers = state_attr('sensor.wireguard_api_json', 'peers') -%}
{{ peers[0].endpoint if peers else 'No peers' }}
```

#### **Option 2: Use individual REST sensors**

Access data from the individual REST sensors you've already configured:

```yaml
# Get status
{{ states('sensor.wireguard_status') }}

# Get peer count
{{ states('sensor.wireguard_peer_count') | int }}

# Get uptime
{{ states('sensor.wireguard_uptime') | int }}
```

#### **Option 3: Make a new HTTP request**

Use `rest_command` or make a direct HTTP request in your template/automation:

```yaml
# In a script or automation
rest_command:
  wireguard_get_status:
    url: "http://local-wireguard-client:51821"
    method: GET
```

> **Note**: REST sensors with `value_template` only store the extracted value (e.g., `"connected"`), not the full JSON. To access the complete JSON, you need a dedicated sensor (Option 1) or make a new request (Option 3).

### **Tips**

- **In REST sensor templates**: Use `value_json` directly (automatically available, see "Understanding `value_json`" section)
- **In other contexts**: Access data via `state_attr()` or parse from sensor states (see "Using Peers Data in Other Contexts" section)
- Always check if `peers` is defined and has items before accessing: `{%- if value_json.peers is defined and value_json.peers|length > 0 -%}`
- Use `| default()` to provide fallback values
- Use `| int` or `| float` to ensure numeric operations work correctly
- Use `selectattr()` and `rejectattr()` filters to filter arrays
- Use `| list` to convert generator results to lists when needed
- For date comparisons, use `| as_datetime` to parse ISO date strings

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
  - sensor.wireguard_last_handshake
```

## 🔍 Testing the API

### **Using curl:**

```bash
# Get status
curl http://local-wireguard-client:51821

# Reconnect VPN
curl http://local-wireguard-client:51821/reconnect

# Restart WireGuard
curl http://local-wireguard-client:51821/restart

# Test WireGuard connection (comprehensive)
curl http://local-wireguard-client:51821/test
```

### **Using Home Assistant Developer Tools:**

1. Go to **Developer Tools** → **Services**
2. Call `rest_command.wireguard_reconnect`
3. Check the response in the logs

## 📝 Notes

- **API URL**: `http://local-wireguard-client:51821` (port 51821)
- **Replace URL**: Replace `local-wireguard-client` with your addon hostname
- **Development vs Production**: In development environments, you may need to use `localhost` instead of the addon hostname
- **Update Frequency**: Status updates every few seconds
- **Error Handling**: All endpoints return JSON with success/error status
- **Compatibility**: Works with Home Assistant 0.7.4+ (RESTful integration introduced in 0.7.4)
- **Security**: API is only accessible from localhost by default
- **Timeout**: Default 10 seconds, configurable via `timeout` parameter
- **SSL**: Set `verify_ssl: false` for local addon communication
- **Templates**: Use `value_json` to access JSON data in REST sensor templates (see "Understanding `value_json`" section above for details)
- **Peers Array**: The `peers` field is a JSON array (not an object or string), use `peers[0]` to access the first peer (not `peers.peer_1`). See "Template Examples" section for detailed usage.
- **Empty Handshake**: When no handshake has occurred, the API returns `"Never"` in the `latest_handshake` field (as documented in the Fields Description above). After configuring sensors, restart Home Assistant or reload the REST integration to see changes
- **Troubleshooting**: If sensors show "Never" or are missing, verify that WireGuard is running and has peers configured. Check the API response with: `curl http://local-wireguard-client:51821 | jq '.peers'` to see if the peers array has data

## 🚀 Benefits

- **Native Integration**: Uses Home Assistant's RESTful sensor platform
- **Real-time Data**: Live updates of WireGuard status and statistics
- **Service Actions**: Direct control over WireGuard operations
- **Comprehensive Data**: Detailed peer information and traffic statistics
- **Automation Ready**: Perfect for creating smart VPN automations

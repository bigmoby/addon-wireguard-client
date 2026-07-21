# Test WireGuard Servers for Failover

This setup allows you to spin up **two separate WireGuard servers** locally to test and verify the automatic peer failover functionality of the Home Assistant client app.

- **Primary Server (wireguard-server-1)**: Running on UDP port `51820`, internal subnet `10.13.13.0/24`.
- **Backup Server (wireguard-server-2)**: Running on UDP port `51821`, internal subnet `10.14.14.0/24`.

---

## 🚀 Quick Start

### 1. Start the servers:

```bash
cd wireguard-server
./start-server.sh
```

This starts both containers (`wireguard-server-1` and `wireguard-server-2`) in the background.

### 2. Retrieve client configurations:

```bash
./get-configs.sh
```

This retrieves the keys and connection details from both directories (`config1` and `config2`) and displays them on the console. It also generates QR codes if `qrencode` is installed.

---

## 📋 Home Assistant App Configuration

To configure the failover feature, `./get-configs.sh` automatically parses the generated keys and generates the exact pre-filled YAML configuration block for you. 

Simply copy the generated ````yaml ... ```` block from the console output, paste it into your Home Assistant client configuration, and replace `YOUR_DOCKER_HOST_IP` with the IP of your machine.

The configuration leverages peer-specific overrides (`private_key`, `address`, and `dns`) to allow connecting to the two different test servers seamlessly without requiring key alignment:

```yaml
interface:
  private_key: "PRIMARY_SERVER_CLIENT_PRIVATE_KEY"
  address: "10.13.13.2"
  dns:
    - 10.13.13.1

peers:
  - public_key: "SERVER_1_PUBLIC_KEY"
    pre_shared_key: "SERVER_1_PRESHARED_KEY"
    endpoint: "YOUR_DOCKER_HOST_IP:51820"
    allowed_ips:
      - 10.13.13.0/24
    persistent_keep_alive: 25
  - public_key: "SERVER_2_PUBLIC_KEY"
    pre_shared_key: "SERVER_2_PRESHARED_KEY"
    endpoint: "YOUR_DOCKER_HOST_IP:51821"
    allowed_ips:
      - 10.14.14.0/24
    persistent_keep_alive: 25
    private_key: "BACKUP_SERVER_CLIENT_PRIVATE_KEY" # Peer-specific override
    address: "10.14.14.2"                            # Peer-specific override
    dns:
      - 10.14.14.1

failover:
  enabled: true
  ping_ip: "10.13.13.1"
  check_interval: 10
  handshake_threshold: 20
  max_failures: 2
  revert_interval: 60
```

---

## ⚡ How to Test Failover

1. **Verify primary connection**: 
   Ensure your Home Assistant app connects to Server 1. Check client logs and test connectivity by pinging the Server 1 gateway:
   ```bash
   ping 10.13.13.1
   ```

2. **Simulate a primary outage**:
   Stop the primary server container:
   ```bash
   docker-compose stop wireguard-server-1
   ```

3. **Monitor client logs**:
   After a brief period (determined by `check_interval` and `handshake_threshold`), you will see the client log consecutive failures and then trigger a failover to peer index 1 (Server 2):
   ```text
   [warning] Connection health check failed (consecutive failures: 1/2)
   [warning] Connection health check failed (consecutive failures: 2/2)
   [warning] Failover threshold reached. Attempting switch to peer index 1.
   [warning] Switching active peer index to 1...
   ```
   Verify that traffic is now routing to the backup server (ping `10.14.14.1`).

4. **Restore the primary server**:
   Start the primary container again to simulate the recovery of your main server:
   ```bash
   docker-compose start wireguard-server-1
   ```

5. **Observe automatic revert**:
   Once the `revert_interval` (e.g. 60 seconds) is reached, the watchdog will automatically attempt to reconnect to the primary peer:
   ```text
   [notice] Attempting to revert to primary peer (index 0) after 60s on backup...
   [warning] Switching active peer index to 0...
   [info] WireGuard tunnel restarted successfully.
   ```
   Connectivity should return to Server 1.

---

## 🛑 Clean Up

To stop both WireGuard servers and remove the containers, run:
```bash
docker-compose down
```
To also clean up the generated peer config files:
```bash
rm -rf config1 config2
```

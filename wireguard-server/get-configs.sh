#!/bin/bash

# Script to get WireGuard client configurations from both test servers

echo "📋 Available WireGuard client configurations for Failover testing:"
echo ""

# Helper function to parse INI/Conf values
get_val() {
    local file="${1}"
    local section="${2}"
    local key="${3}"
    local in_sec=false
    while read -r line || [ -n "$line" ]; do
        # Trim whitespace and carriage returns
        line=$(echo "$line" | tr -d '\r' | xargs)
        if [[ "$line" =~ ^\[(.*)\]$ ]]; then
            if [[ "${BASH_REMATCH[1]}" == "${section}" ]]; then
                in_sec=true
            else
                in_sec=false
            fi
        elif [[ "$in_sec" == true && "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local k=$(echo "${BASH_REMATCH[1]}" | xargs)
            local v=$(echo "${BASH_REMATCH[2]}" | xargs)
            if [[ "$k" == "$key" ]]; then
                echo "$v"
                return 0
            fi
        fi
    done < "${file}"
}

client_priv_1=""
client_addr_1=""
server_pub_1=""
server_psk_1=""

client_priv_2=""
client_addr_2=""
server_pub_2=""
server_psk_2=""

# Configuration for Server 1
if [ -f "config1/peer1/peer1.conf" ]; then
    echo "🔑 SERVER 1 (Primary - 10.13.13.1, Port 51820):"
    echo "============================================="
    cat config1/peer1/peer1.conf
    
    client_priv_1=$(get_val "config1/peer1/peer1.conf" "Interface" "PrivateKey")
    client_addr_1=$(get_val "config1/peer1/peer1.conf" "Interface" "Address")
    server_pub_1=$(get_val "config1/peer1/peer1.conf" "Peer" "PublicKey")
    server_psk_1=$(get_val "config1/peer1/peer1.conf" "Peer" "PresharedKey")

    echo ""
    echo "📱 Server 1 QR Code for mobile:"
    if command -v qrencode &> /dev/null; then
        qrencode -t ansiutf8 < config1/peer1/peer1.conf
    else
        echo "   [Install qrencode to view QR code: apt-get install qrencode]"
    fi
    echo ""
    echo "------------------------------------------------------------"
    echo ""
fi

# Configuration for Server 2
if [ -f "config2/peer1/peer1.conf" ]; then
    echo "🔑 SERVER 2 (Backup - 10.14.14.1, Port 51821):"
    echo "============================================="
    cat config2/peer1/peer1.conf
    
    client_priv_2=$(get_val "config2/peer1/peer1.conf" "Interface" "PrivateKey")
    client_addr_2=$(get_val "config2/peer1/peer1.conf" "Interface" "Address")
    server_pub_2=$(get_val "config2/peer1/peer1.conf" "Peer" "PublicKey")
    server_psk_2=$(get_val "config2/peer1/peer1.conf" "Peer" "PresharedKey")

    echo ""
    echo "📱 Server 2 QR Code for mobile:"
    if command -v qrencode &> /dev/null; then
        qrencode -t ansiutf8 < config2/peer1/peer1.conf
    else
        echo "   [Install qrencode to view QR code: apt-get install qrencode]"
    fi
    echo ""
    echo "------------------------------------------------------------"
    echo ""
fi

echo "💡 Failover Test Configuration in Home Assistant App:"
echo "   Copy and paste this configuration directly into your Home Assistant client options:"
echo "   (Replace YOUR_DOCKER_HOST_IP with the IP address of your machine)"
echo ""
echo "\`\`\`yaml"
echo "interface:"
echo "  private_key: \"${client_priv_1}\""
echo "  address: \"${client_addr_1}\""
echo "  dns:"
echo "    - 10.13.13.1"
echo ""
echo "peers:"
echo "  - public_key: \"${server_pub_1}\""
echo "    pre_shared_key: \"${server_psk_1}\""
echo "    endpoint: \"YOUR_DOCKER_HOST_IP:51820\""
echo "    allowed_ips:"
echo "      - 10.13.13.0/24"
echo "    persistent_keep_alive: 25"
echo "    ping_ip: \"10.13.13.1\""
echo "  - public_key: \"${server_pub_2}\""
echo "    pre_shared_key: \"${server_psk_2}\""
echo "    endpoint: \"YOUR_DOCKER_HOST_IP:51821\""
echo "    allowed_ips:"
echo "      - 10.14.14.0/24"
echo "    persistent_keep_alive: 25"
echo "    private_key: \"${client_priv_2}\"  # Peer-specific private key override"
echo "    address: \"${client_addr_2}\"        # Peer-specific address override"
echo "    dns:"
echo "      - 10.14.14.1"
echo "    ping_ip: \"10.14.14.1\"              # Peer-specific ping IP override"
echo ""
echo "failover:"
echo "  enabled: true"
echo "  check_interval: 10"
echo "  handshake_threshold: 60"
echo "  max_failures: 2"
echo "  revert_interval: 60"
echo "\`\`\`"
echo ""
echo "⚡ Simulation Commands:"
echo "   - Simulate primary down: docker-compose stop wireguard-server-1"
echo "   - Restore primary:       docker-compose start wireguard-server-1"
echo ""

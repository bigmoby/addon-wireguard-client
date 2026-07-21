#!/bin/bash

# Script to start the WireGuard servers and prepare client configurations

echo "🚀 Starting WireGuard servers..."

# Create configuration directories if they don't exist
mkdir -p config1 config2

# Start the servers
docker-compose up -d

echo "⏳ Waiting for the servers to fully start..."
sleep 10

# Check if the containers are running
server1_running=false
server2_running=false

if docker ps | grep -q wireguard-server-1; then
    server1_running=true
fi

if docker ps | grep -q wireguard-server-2; then
    server2_running=true
fi

if [ "$server1_running" = true ] && [ "$server2_running" = true ]; then
    echo "✅ Both WireGuard servers started successfully!"
    echo ""
    echo "📋 Server Information:"
    echo "   1. Primary Server (wireguard-server-1):"
    echo "      - Port: 51820"
    echo "      - Internal Network: 10.13.13.0/24"
    echo "      - Config: ./config1/peer1/peer1.conf"
    echo ""
    echo "   2. Backup Server (wireguard-server-2):"
    echo "      - Port: 51821"
    echo "      - Internal Network: 10.14.14.0/24"
    echo "      - Config: ./config2/peer1/peer1.conf"
    echo ""
    echo "📁 Client configurations are ready."
    echo "👉 Run ./get-configs.sh to retrieve the configuration blocks."
    echo ""
    echo "🛑 To stop the servers:"
    echo "   docker-compose down"
else
    echo "❌ Error starting WireGuard servers"
    echo "Primary running: $server1_running"
    echo "Backup running: $server2_running"
    echo "Check logs with: docker-compose logs"
fi

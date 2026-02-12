#!/bin/bash

# Script to start the WireGuard server and get client configurations

echo "🚀 Starting WireGuard server..."

# Create configuration directory if it doesn't exist
mkdir -p config

# Start the server
docker-compose up -d

echo "⏳ Waiting for the server to fully start..."
sleep 10

# Check if the container is running
if docker ps | grep -q wireguard-server; then
    echo "✅ WireGuard server started successfully!"
    echo ""
    echo "📋 Server Information:"
    echo "   - Port: 51820"
    echo "   - Internal Network: 10.13.13.0/24"
    echo "   - Configured Clients: 2"
    echo ""
    echo "📁 Client configurations are available in:"
    echo "   ./config/peer1/peer1.conf"
    echo "   ./config/peer2/peer2.conf"
    echo ""
    echo "🔍 To view configurations:"
    echo "   cat config/peer1/peer1.conf"
    echo "   cat config/peer2/peer2.conf"
    echo ""
    echo "🛑 To stop the server:"
    echo "   docker-compose down"
else
    echo "❌ Error starting WireGuard server"
    echo "Check logs with: docker-compose logs"
fi

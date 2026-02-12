#!/bin/bash

# Script to get WireGuard client configurations

echo "📋 Available WireGuard client configurations:"
echo ""

if [ -f "config/peer1/peer1.conf" ]; then
    echo "🔑 CLIENT 1 (peer1):"
    echo "===================="
    cat config/peer1/peer1.conf
    echo ""
    echo "📱 QR Code for mobile:"
    echo "======================"
    if command -v qrencode &> /dev/null; then
        qrencode -t ansiutf8 < config/peer1/peer1.conf
    else
        echo "Install qrencode to view QR code: apt-get install qrencode"
    fi
    echo ""
    echo "----------------------------------------"
    echo ""
fi

if [ -f "config/peer2/peer2.conf" ]; then
    echo "🔑 CLIENT 2 (peer2):"
    echo "===================="
    cat config/peer2/peer2.conf
    echo ""
    echo "📱 QR Code for mobile:"
    echo "======================"
    if command -v qrencode &> /dev/null; then
        qrencode -t ansiutf8 < config/peer2/peer2.conf
    else
        echo "Install qrencode to view QR code: apt-get install qrencode"
    fi
    echo ""
fi

echo "💡 Tips:"
echo "   - Use peer1 to test your Home Assistant addon"
echo "   - Use peer2 to test with another device"
echo "   - The server is reachable on port 51820"

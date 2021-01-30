#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Third Party Add-on: WireGuard Client
# Creates the interface configuration
# ==============================================================================
declare -a list
declare address
declare tmp_address
declare allowed_ips
declare config
declare dns
declare endpoint
declare interface
declare keep_alive
declare peer_public_key
declare post_down
declare post_up
declare pre_shared_key

if ! bashio::fs.directory_exists '/ssl/wireguard'; then
    mkdir -p /ssl/wireguard ||
        bashio::exit.nok "Could not create wireguard storage folder!"
fi

# Get interface and config file location
interface="wg0"

config="/etc/wireguard/${interface}.conf"

###########################
# Interface configuration #
###########################
# Start creation of configuration
echo "[Interface]" > "${config}"

# Check if at least 1 private key value and if true get the interface private key
if ! bashio::config.has_value 'interface.private_key'; then
    bashio::exit.nok 'You need a private_key configured for the interface client'
else
    interface_private_key=$(bashio::config 'interface.private_key')
     echo "PrivateKey = ${interface_private_key}" >> "${config}"
fi

# Check if at least 1 address value and if true get the interface address
if ! bashio::config.has_value 'interface.address'; then
    bashio::exit.nok 'You need a address configured for the interface client'
else
   tmp_address=$(bashio::config 'interface.address')
   address="${tmp_address}/24"
   echo "Address = ${address}" >> "${config}"
fi

# Add all server DNS addresses to the configuration
listDns=()
if bashio::config.has_value "interface.dns"; then
    # Use allowed IP's defined by the user.
    for address in $(bashio::config "interface.dns"); do
        listDns+=("${address}")
    done
else
    bashio::exit.nok 'You need a dns configured'
fi
dns=$(IFS=", "; echo "${listDns[*]}")
echo "DNS = ${dns}" >> "${config}"

# Post Up & Down defaults
post_up="iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE"
post_down="iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE"
if [[ $(</proc/sys/net/ipv4/ip_forward) -eq 0 ]]; then
    bashio::log.warning
    bashio::log.warning "IP forwarding is disabled on the host system!"
    bashio::log.warning "You can still use WireGuard Client to access Hass.io,"
    bashio::log.warning "however, you cannot access your home network or"
    bashio::log.warning "the internet via the VPN tunnel."
    bashio::log.warning
    bashio::log.warning "Please consult the add-on documentation on how"
    bashio::log.warning "to resolve this."
    bashio::log.warning
fi

# Post up & down
echo "PostUp = ${post_up}" >> "${config}"
echo "PostDown = ${post_down}" >> "${config}"

# Status API Storage
if ! bashio::fs.directory_exists '/var/lib/wireguard'; then
    mkdir -p /var/lib/wireguard \
        || bashio::exit.nok "Could not create status API storage folder"
fi

######################
# Peer configuration #
######################
# Check if public key value and if true get the peer public key
peer_public_key=""
if ! bashio::config.has_value 'peer.public_key'; then
    bashio::exit.nok 'You need a public_key configured for the peer'
else
    peer_public_key=$(bashio::config 'peer.public_key')
fi

# Check if pre_shared key value and if true get the peer pre_shared key
pre_shared_key=""
if ! bashio::config.has_value 'peer.pre_shared_key'; then
    bashio::exit.nok 'You need a pre_shared_key configured for the peer'
else
    pre_shared_key=$(bashio::config 'peer.pre_shared_key')
fi

# Check if endpoint value and if true get the peer endpoint
endpoint=""
if ! bashio::config.has_value 'peer.endpoint'; then
    bashio::exit.nok 'You need a endpoint configured for the peer'
else
    endpoint=$(bashio::config 'peer.endpoint')
fi

# Check if persistent_keep_alive value and if true get the peer persistent_keep_alive
keep_alive=""
if ! bashio::config.has_value 'peer.persistent_keep_alive'; then
    bashio::exit.nok 'You need a persistent_keep_alive configured for the peer'
else
    keep_alive=$(bashio::config 'peer.persistent_keep_alive')
fi

# Determine allowed IPs for server side config, by default use
# peer defined addresses.
list=()
if bashio::config.has_value "peer.allowed_ips"; then
    # Use allowed IP's defined by the user.
    for address in $(bashio::config "peer.allowed_ips"); do
        [[ "${address}" == *"/"* ]] || address="${address}/32"
        list+=("${address}")
    done
else
    bashio::exit.nok 'You need a allowed_ips configured for the peer'
fi
allowed_ips=$(IFS=", "; echo "${list[*]}")

# Start writing peer information in client config
{
    echo ""
    echo "[Peer]"
    echo "PublicKey = ${peer_public_key}"
    echo "PreSharedKey = ${pre_shared_key}"
    echo "Endpoint = ${endpoint}"
    echo "AllowedIPs = ${allowed_ips}"
    echo "PersistentKeepalive = ${keep_alive}"
    echo ""
} >> "${config}"

bashio::log.info "Ended to write Wireguard configuration into: [${config}]"
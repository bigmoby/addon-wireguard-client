#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Third Party Add-on: WireGuard Client
# Creates the interface configuration
# ==============================================================================
declare -a list
declare address
declare allowed_ips
declare config
declare dns
declare endpoint
declare interface
declare keep_alive
declare peer_public_key
declare post_down
declare post_up
declare mtu
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
    address=$(bashio::config 'interface.address')
    [[ "${address}" == *"/"* ]] || address="${address}/24"
   echo "Address = ${address}" >> "${config}"
fi

# Add all server DNS addresses to the configuration
if bashio::config.has_value "interface.dns"; then
    listDns=()
    # Use allowed IP's defined by the user.
    for address in $(bashio::config "interface.dns"); do
        listDns+=("${address}")
    done
    dns=$(IFS=", "; echo "${listDns[*]}")
    echo "DNS = ${dns}" >> "${config}"
fi

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

# Post Up & Down defaults
# Check if custom post_up value
if bashio::config.has_value 'interface.post_up'; then
    post_up=$(bashio::config 'interface.post_up')
    echo "PostUp = ${post_up}" >> "${config}"
fi

# Check if custom post_down value
if bashio::config.has_value 'interface.post_down'; then
    post_down=$(bashio::config 'interface.post_down')
    echo "PostDown = ${post_down}" >> "${config}"
fi

# Check if custom mtu value
if bashio::config.has_value 'interface.mtu'; then
    mtu=$(bashio::config 'interface.mtu')
    echo "MTU = ${mtu}" >> "${config}"
fi

# Status API Storage
if ! bashio::fs.directory_exists '/var/lib/wireguard'; then
    mkdir -p /var/lib/wireguard \
        || bashio::exit.nok "Could not create status API storage folder"
fi

if ! bashio::config.has_value 'peers'; then
    bashio::exit.nok 'Missing required list: peers'
fi

######################
# Peer configuration #
######################
# Fetch all the peers
for peer in $(bashio::config 'peers|keys'); do

    # Check if public key value and if true get the peer public key
    peer_public_key=$(bashio::config "peers[${peer}].public_key")

    # Check if pre_shared key value and if true get the peer pre_shared key
    pre_shared_key=""
    if  bashio::config.has_value "peers[${peer}].pre_shared_key"; then
        pre_shared_key=$(bashio::config "peers[${peer}].pre_shared_key")
    fi

    # Check if endpoint value and if true get the peer endpoint
    endpoint=""
    if ! bashio::config.has_value "peers[${peer}].endpoint"; then
        bashio::exit.nok 'You need a endpoint configured for the peer'
    else
        endpoint=$(bashio::config "peers[${peer}].endpoint")
    fi

    # Check if persistent_keep_alive value and if true get the peer persistent_keep_alive
    keep_alive=""
    if ! bashio::config.has_value "peers[${peer}].persistent_keep_alive"; then
        bashio::exit.nok 'You need a persistent_keep_alive configured for the peer'
    else
        keep_alive=$(bashio::config "peers[${peer}].persistent_keep_alive")
    fi

    # Determine allowed IPs for server side config, by default use
    # peer defined addresses.
    list=()
    if bashio::config.has_value "peers[${peer}].allowed_ips"; then
        # Use allowed IP's defined by the user.
        for address in $(bashio::config "peers[${peer}].allowed_ips"); do
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
        if [ ! $pre_shared_key == "" ]
        then
            echo "PreSharedKey = ${pre_shared_key}"
        fi
        echo "Endpoint = ${endpoint}"
        echo "AllowedIPs = ${allowed_ips}"
        echo "PersistentKeepalive = ${keep_alive}"
        echo ""
    } >> "${config}"
done

bashio::log.info "Ended to write Wireguard configuration into: [${config}]"

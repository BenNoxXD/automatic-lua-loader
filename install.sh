#!/bin/bash

ps5_ip=""
docker="off"
killgame="off" # on/off
continue="shutdown" # shutdown/ping
inject="none" # none/etaHEN/kstuff

print_info() {
    echo -e "\033[0;33m$1\033[0m"
}

# Parse command-line arguments
for arg in "$@"; do
    case $arg in
        -killgame=on)
            killgame="on"
            ;;
        -killgame=off)
            killgame="off"
            ;;
        -continue=shutdown)
            continue="shutdown"
            ;;
        -continue=ping)
            continue="ping"
            ;;
        -inject=none)
            inject="none"
            ;;
        -inject=etaHEN)
            inject="etaHEN"
            ;;
        -inject=kstuff)
            inject="kstuff"
            ;;
        -docker=on)
            docker="on"
            ;;
        -docker=off)
            docker="off"
            ;;
        -ps5_ip=*)
            ps5_ip="${arg#*=}"
            ;;
        -h|--help)
            echo "Usage: ./install.sh -ps5_ip=YOURPS5IP [-killgame=on|off] [-continue=shutdown|ping] [-inject=none|etaHEN|kstuff] [-docker=on|off]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

# Ensure PS5 IP is set.
if [[ -z "$ps5_ip" ]]; then
    echo "Error: You must specify the PS5 IP Address using -ps5_ip=<YOURPS5IP>"
    echo "Use -h or --help for usage information."
    exit 1
fi

if [[ "$docker" == "off" ]]; then
    ## Start installation
    print_info "Your PS5 IP Address is set to: $ps5_ip"

    # install dependencies
    apt-get install -y git python3 wget socat

    # remove old version
    systemctl stop lualoader
    systemctl disable lualoader
    rm /etc/systemd/system/lualoader.service
    rm -r /opt/automatic-lua-loader
fi

echo $ps5_ip > /tmp/ip.txt
cd /opt
# install new version
git clone https://github.com/BenNoxXD/automatic-lua-loader/
cd automatic-lua-loader
mv /tmp/ip.txt /opt/automatic-lua-loader
mkdir exploit
wget https://raw.githubusercontent.com/shahrilnet/remote_lua_loader/refs/heads/main/payloads/umtx.lua -P exploit
wget https://raw.githubusercontent.com/shahrilnet/remote_lua_loader/refs/heads/main/payloads/send_lua.py
wget https://raw.githubusercontent.com/shahrilnet/remote_lua_loader/refs/heads/main/payloads/elf_loader.lua -P exploit


# create run.sh
cat > /opt/automatic-lua-loader/run.sh <<- "EOF"
#/bin/bash
cd /opt/automatic-lua-loader/
EOF

# continue
if [[ "$continue" == "ping" ]]; then
# modify run.sh
cat >> /opt/automatic-lua-loader/run.sh <<- "EOF"
while true
do
EOF
fi


# modify run.sh - exploit
cat >> /opt/automatic-lua-loader/run.sh <<- "EOF"
python3 test_port.py $(cat ip.txt) 9021 15 close
python3 test_port.py $(cat ip.txt) 9026 1 open
sleep .25
python3 send_lua.py $(cat ip.txt) 9026 status/running.lua
python3 send_lua.py $(cat ip.txt) 9026 exploit/umtx.lua
python3 send_lua.py $(cat ip.txt) 9026 status/finished.lua
python3 send_lua.py $(cat ip.txt) 9026 exploit/elf_loader.lua
EOF


# killgame
if [[ "$killgame" == "on" ]]; 
then
cat >> run.sh <<- "EOF"
sleep 3 #give the elfldr some time to get up and running
socat -t 99999999 - TCP:$(cat ip.txt):9021 < KillLuaGame/KillLuaGame.elf
sleep 1 #give the elfldr some time to get ready for the next payload
EOF
fi

# inject etaHEN
if [[ "$inject" == "etaHEN" ]]; 
then
mkdir Payloads
wget -O Payloads/etaHEN.bin $(curl -s https://api.github.com/repos/etaHEN/etaHEN/releases/latest | jq -r '.assets[].browser_download_url')
cat >> run.sh <<- "EOF"
socat FILE:Payloads/etaHEN.bin TCP:$(cat ip.txt):9021
EOF
fi

# inject kstuff
if [[ "$inject" == "kstuff" ]]; 
then
mkdir Payloads
wget https://github.com/EchoStretch/kstuff/releases/latest/download/kstuff.elf -P Payloads
cat >> run.sh <<- "EOF"
socat FILE:Payloads/kstuff.elf TCP:$(cat ip.txt):9021
EOF
fi

echo "sleep 5" >> /opt/automatic-lua-loader/run.sh

# end while loop or shutdown
if [[ "$continue" == "ping" ]]; 
then
    echo "done" >> /opt/automatic-lua-loader/run.sh
else
    echo "shutdown now" >> /opt/automatic-lua-loader/run.sh
fi

chmod +x run.sh

if [[ "$docker" == "off" ]]; 
then
# create a service for autostart
cat > /etc/systemd/system/lualoader.service <<- "EOF"
[Unit]
Description=PS5 automatic lua loader

[Service]
ExecStart=/bin/bash /opt/automatic-lua-loader/run.sh

[Install]
WantedBy=multi-user.target
EOF

# enable the service
systemctl enable lualoader
systemctl start lualoader
print_info "Installation complete!"
fi

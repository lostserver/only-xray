# Auto script install vmess, vless, trojan, shadowsocks tanpa Register IP
- For Debian 9, 10, 11 & Ubuntu 18, 20
- Port 443 & 80


# Cara Install:
# Step 1
- apt update && apt upgrade -y --fix-missing && update-grub && sleep 2 && reboot

# Step 2
- sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt install -y bzip2 gzip coreutils screen curl unzip && wget -O install 'https://raw.githubusercontent.com/lostserver/only-xray/master/install.sh' && chmod +x install && screen -S install ./install

- Jika ada error bisa chat ke https://t.me/syntaxerorrr

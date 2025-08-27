#!/bin/bash
# ===================================================
# All-in-One PPTP VPN Setup + Auto-Reconnect
# ===================================================

VPN_NAME="myvpn"
VPN_SERVER="103.218.167.29"
VPN_USER="nusanet"
VPN_PASS="Nusanet2022#"

# 1. Install pptp client
sudo apt update
sudo apt install pptp-linux -y

# 2. Load kernel modules
sudo modprobe ppp_generic
sudo modprobe ppp_async
sudo modprobe ppp_mppe

# 3. Buat koneksi PPTP
sudo pptpsetup --create "$VPN_NAME" --server "$VPN_SERVER" --username "$VPN_USER" --password "$VPN_PASS" --encrypt

# 4. Pastikan chap-secrets sudah benar
echo -e "$VPN_USER\t*\t$VPN_PASS\t*" | sudo tee -a /etc/ppp/chap-secrets

# 5. Buat routing default script
sudo tee /etc/ppp/ip-up.d/route <<'EOF'
#!/bin/bash
ip route del default
ip route add default dev ppp0
EOF
sudo chmod +x /etc/ppp/ip-up.d/route

# 6. Buat auto-reconnect script
sudo tee /usr/local/bin/pptp-reconnect.sh <<'EOF'
#!/bin/bash
VPN_NAME="myvpn"
while true; do
    if ip addr show ppp0 > /dev/null 2>&1; then
        echo "$(date) - VPN $VPN_NAME sudah connect"
    else
        echo "$(date) - VPN $VPN_NAME tidak connect. Mencoba connect..."
        sudo pon $VPN_NAME
        sleep 10
    fi
    sleep 30
done
EOF
sudo chmod +x /usr/local/bin/pptp-reconnect.sh

# 7. Buat systemd service untuk auto-reconnect
sudo tee /etc/systemd/system/pptp-reconnect.service <<EOF
[Unit]
Description=PPTP VPN Auto-Reconnect Service
After=network-online.target
Wants=network-online.target
Requires=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/pptp-reconnect.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 8. Enable service
sudo systemctl daemon-reload
sudo systemctl enable pptp-reconnect
sudo systemctl start pptp-reconnect

echo "✅ Setup selesai. Cek status dengan: sudo systemctl status pptp-reconnect"

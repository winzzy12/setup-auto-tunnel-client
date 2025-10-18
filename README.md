# ☕ Cara Installasi

* Download script sh
  ```bash
  git clone https://github.com/winzzy12/setup-auto-tunnel-client.git
  ```

* Masuk ke Directory
  ```bash
  cd setup-auto-tunnel-client
  ```
  
* Sesuaikan VPN Client
  ```bash
  nano setup_pptp_auto.sh
  ```
  
* Installasi Script SH
  ```bash
  chmod +x install_setup_pptp_auto.sh
  ./install_setup_pptp_auto.sh
  ```

* Disable service auto-start
  ```bash
  sudo systemctl disable pptp-reconnect
  ```

* Tujuan	Perintah
Hapus auto-route VPN
  ```bash
  sudo rm -f /etc/ppp/ip-up.d/route
  ```
* Connect VPN
  ```bash
  sudo pon myvpn
  ```
* Kembalikan route utama
  ```bash
  sudo ip route del default && sudo ip route add default via 192.168.0.254 dev enp0s3
  ```
* Tambah route khusus ke VPN (opsional)
  ```bash
  sudo ip route add 10.10.10.0/24 dev ppp0
  ```
  
* Done

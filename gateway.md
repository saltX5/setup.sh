# Tor Gateway VM Setup in VirtualBox (Using Alpine Linux)

## Overview

This guide sets up a minimal Alpine Linux VM as a Tor gateway in VirtualBox. The VM routes all traffic from client VMs through the Tor network for anonymity.

---

## Prerequisites

* Host OS with VirtualBox installed
* Alpine Linux x86\_64 ISO (download from [https://alpinelinux.org/downloads/](https://alpinelinux.org/downloads/))
* Basic VirtualBox knowledge

---

## Steps

### 1. Download Alpine Linux ISO

* Choose **x86\_64** architecture ISO.

---

### 2. Create a New VirtualBox VM for the Gateway

* Name: `tor-gateway` (or any name you want)
* Type: Linux
* Version: Other Linux (64-bit)
* Memory: 1024 MB RAM
* CPUs: 2
* Storage: 4 GB dynamically allocated VDI 
* Attach the Alpine ISO during VM creation.

---

### 3. Configure Network Adapters

* Adapter 1: NAT (for Internet access)
* Adapter 2: Internal Network named `tor_net` (must match on client VM)

---

### 4. Hardware Settings

* Disable audio and USB (optional)

---

### 5. Installing Alpine Linux on the Gateway VM

* Start the VM, it will boot from the Alpine ISO automatically.
* Login as user `root` (no password yet).
* Run:

  ```bash
  setup-alpine
  ```
* Follow the prompts:

  
  * Select keyboard layout (default is fine)
  * Enter hostname (your choice)
  * For `eth0` (NAT interface), type `eth0` 
  * For ipaddres for eth0 type `dhcp` to get IP automatically
  * Do you want manual network configuration type `n` 
  * Set root password (your choice)
  * Set you timezone 
  * Add proxy if you want or skip this type `none` 
  * Enable NTP with `busybox` (default)
  * Use default APK mirror or choose “find fastest mirror” (`f`) it will take 3-5  minutes
  * set username (your choice)
  * SSH key type `none`
  * SSH server again `none`
  * Disk & Install select `sda`
  * How would you like to use it `sys`
  * Erase the disk and continue `Y`
 
* When installation finishes, reboot and remove ISO from VM storage.

---

### 6. Post-install Login

* Login with root and password set during installation.

---

### 7. Update system and install required packages

```bash
apk update
apk upgrade
apk add tor iptables
```

---

### 8. Configure Tor

```bash
nano /etc/tor/torrc
```

Add the following lines:

```
Log notice file /var/log/tor/notices.log
RunAsDaemon 1
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 53
```

---

### 9. Enable IP Forwarding

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
```

---

### 10. Set iptables Rules

```bash
iptables -F
iptables -t nat -F

# Redirect DNS requests to Tor's DNSPort
iptables -t nat -A PREROUTING -i eth1 -p udp --dport 53 -j REDIRECT --to-ports 53

# Redirect TCP traffic to Tor's TransPort
iptables -t nat -A PREROUTING -i eth1 -p tcp --syn -j REDIRECT --to-ports 9040

# Allow localhost traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Save rules
rc-update add iptables default
/etc/init.d/iptables save
```

---

### 11. Enable and Start Tor

```bash
rc-update add tor default
rc-service tor start
```

---

### 12. Configure Client VM

* Create another VM (Linux, Windows, etc.).
* Adapter 1: Internal Network `tor_net`
* Static IP settings:

  * IP: `10.0.0.2`
  * Netmask: `255.255.255.0`
  * Gateway: `10.0.0.1`
  * DNS: `10.0.0.1`

---

Now your client VM routes all traffic through Tor automatically.

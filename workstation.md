# Tor Workstation VM Setup 

## Overview

This workstation VM routes all traffic through the Tor Gateway VM. It uses the internal network `tor_net` to communicate securely with the gateway.

---

## 1. Create the Workstation VM in VirtualBox

* **Name:** `tor-workstation`
* **Type:** Linux → Ubuntu (64-bit)
* **Memory:** 2048 MB (recommended)
* **CPUs:** 2
* **Storage:** 10 GB dynamically allocated VDI
* Attach Ubuntu ISO during creation.

---

## 2. Configure Network

* **Adapter 1:** Internal Network → Name: `tor_net` (same as the gateway)
* **No other network adapters** (ensures traffic only goes through Tor Gateway).

---

## 3. Install Ubuntu

* Boot from ISO and complete installation.
* Set root and user credentials.

---

## 4. Configure Static IP with Netplan

Edit the Netplan config:

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

Add:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 10.0.0.2/24
      gateway4: 10.0.0.1
      nameservers:
        addresses: [10.0.0.1]
```

Apply changes:

```bash
sudo netplan apply
```

---

## 5. Disable IPv6

Prevent leaks by disabling IPv6:

```bash
sudo nano /etc/sysctl.conf
```

Add:

```
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

Apply:

```bash
sudo sysctl -p
```

---

## 6. Test Connectivity

Check connection with gateway and Internet:

```bash
ping 10.0.0.1    # Test gateway
ping 1.1.1.1     # Test Internet
```

---

## 7. Verify Tor Routing

Install curl and check your IP:

```bash
sudo apt update && sudo apt install curl -y
curl https://check.torproject.org
```

It should display **"Congratulations. This browser is configured to use Tor."**

---

## 8. Browser Setup

* Use **Firefox** or **LibreWolf**.
* Disable WebRTC:

  * Open `about:config`
  * Search `media.peerconnection.enabled`
  * Set to **false**.
* Disable geolocation and telemetry.

---

## 9. Security Hardening

* Do **not** install unnecessary apps.
* Disable auto-updates for anonymity.
* Disable bidirectional clipboard and shared folders in VirtualBox.
* Gateway handles networking only; workstation runs apps only.

---

## 10. Optional Privacy Enhancements

* Use **VPN over Tor** inside workstation for extra anonymity.
* Use **Tor Browser** for sensitive browsing.

---

## Snapshot Recommendation

Take a **clean snapshot** after setup:

* VirtualBox → `Machine` → `Take Snapshot`.
* Revert anytime if needed.


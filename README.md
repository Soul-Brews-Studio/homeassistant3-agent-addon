# Home Assistant 3 Agent Add-ons

This repository contains Home Assistant add-ons for the `homeassistant3` HAOS
guest. The first add-on, **Shell Agent**, provides a persistent, key-authenticated
SSH shell with Git, curl, Node.js, npm, and basic build tools.

It does **not** install or configure an AI or coding-agent CLI. After connecting,
you can install any additional tools manually inside the add-on container.

## Install Shell Agent

1. In Home Assistant, open **Settings → Add-ons → Add-on Store**.
2. Open **⋮ → Repositories**.
3. Paste this repository URL and add it:

   ```text
   https://github.com/Soul-Brews-Studio/homeassistant3-agent-addon
   ```

4. Find **Shell Agent** in the Add-on Store and select **Install**.
5. Open the add-on's **Configuration** tab and paste your SSH public key into
   `ssh_authorized_key`.
6. Leave `ssh_port` at `2222` unless you also update the exposed port in the
   add-on's **Network** settings to match.
7. Start the add-on.
8. Connect to the HAOS guest:

   ```sh
   ssh -p 2222 root@192.168.1.191
   ```

Replace the port and address if your Network settings or HAOS address differ.
The add-on refuses to start without a valid SSH public key. Password login is
disabled.

## Scope and persistence

- The shell runs inside the add-on container, not on the immutable HAOS host.
- `/data` is the add-on's persistent volume. SSH host keys and the authorized
  key file are stored there so host fingerprints survive restarts and upgrades.
- Packages installed manually outside `/data` may be lost when the add-on is
  rebuilt or upgraded.

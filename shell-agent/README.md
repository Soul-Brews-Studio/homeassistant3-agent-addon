# Shell Agent

Shell Agent provides a persistent interactive SSH shell inside a Home Assistant
add-on container. It targets `amd64` HAOS installations and includes:

- OpenSSH server with public-key authentication only
- Git and curl
- Node.js and npm
- Alpine build tools (`build-base`)

No coding-agent CLI is preinstalled or configured.

## Configuration

| Option | Required | Default | Description |
| --- | --- | --- | --- |
| `ssh_authorized_key` | Yes | None | A complete SSH public key, such as the contents of `~/.ssh/id_ed25519.pub`. |
| `ssh_port` | Yes | `2222` | Port on which `sshd` listens inside the container. |

The add-on refuses to start when the public key is empty or invalid. Password
authentication is disabled.

The manifest maps container port `2222/tcp` to host port `2222` by default. If
you change `ssh_port`, set the exposed host/container port consistently in the
add-on's **Network** settings; for the normal setup, leave both at `2222`.

## Connect

```sh
ssh -p 2222 root@<haos-ip>
```

For the current `homeassistant3` guest:

```sh
ssh -p 2222 root@192.168.1.191
```

SSH host keys and `authorized_keys` are stored under `/data/ssh`, so host key
fingerprints persist across restarts and add-on upgrades. Files elsewhere in
the container, including manually installed global npm packages, can be lost
when the image is rebuilt or upgraded.

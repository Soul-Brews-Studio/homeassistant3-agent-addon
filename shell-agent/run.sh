#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -euo pipefail

readonly SSH_DATA_DIR="/data/ssh"
readonly AUTHORIZED_KEYS_FILE="${SSH_DATA_DIR}/authorized_keys"
readonly SSHD_CONFIG_FILE="${SSH_DATA_DIR}/sshd_config"

authorized_key="$(bashio::config 'ssh_authorized_key')"
ssh_port="$(bashio::config 'ssh_port')"

if [[ -z "${authorized_key//[[:space:]]/}" || "${authorized_key}" == "null" ]]; then
    bashio::log.fatal "The ssh_authorized_key option is required; refusing to start SSH."
    exit 1
fi

mkdir -p "${SSH_DATA_DIR}" /root/.ssh /run/sshd
chmod 0700 "${SSH_DATA_DIR}" /root/.ssh

# Alpine ships the root account locked. Remove the password hash so OpenSSH can
# accept public-key login; sshd still categorically disables password login.
passwd -d root >/dev/null

printf '%s\n' "${authorized_key}" > "${AUTHORIZED_KEYS_FILE}"
chmod 0600 "${AUTHORIZED_KEYS_FILE}"

if ! ssh-keygen -l -f "${AUTHORIZED_KEYS_FILE}" >/dev/null 2>&1; then
    bashio::log.fatal "The ssh_authorized_key option is not a valid SSH public key."
    exit 1
fi

if [[ ! -f "${SSH_DATA_DIR}/ssh_host_ed25519_key" ]]; then
    bashio::log.info "Generating persistent Ed25519 SSH host key..."
    ssh-keygen -q -t ed25519 -N '' -f "${SSH_DATA_DIR}/ssh_host_ed25519_key"
fi

if [[ ! -f "${SSH_DATA_DIR}/ssh_host_rsa_key" ]]; then
    bashio::log.info "Generating persistent RSA SSH host key..."
    ssh-keygen -q -t rsa -b 4096 -N '' -f "${SSH_DATA_DIR}/ssh_host_rsa_key"
fi

cat > "${SSHD_CONFIG_FILE}" <<EOF
Port ${ssh_port}
ListenAddress 0.0.0.0
HostKey ${SSH_DATA_DIR}/ssh_host_ed25519_key
HostKey ${SSH_DATA_DIR}/ssh_host_rsa_key
AuthorizedKeysFile ${AUTHORIZED_KEYS_FILE}
PermitRootLogin prohibit-password
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
UsePAM no
X11Forwarding no
AllowTcpForwarding yes
PrintMotd no
Subsystem sftp internal-sftp
PidFile /run/sshd.pid
EOF

chmod 0600 "${SSH_DATA_DIR}"/ssh_host_*_key

bashio::log.info "Starting SSH server on container port ${ssh_port}..."
exec /usr/sbin/sshd -D -e -f "${SSHD_CONFIG_FILE}"

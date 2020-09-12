#!/bin/sh
# heaviliy inspired by https://github.com/sdelafond/docker-protonmail-bridge

set -eux

# constants
BRIDGE="/Desktop-Bridge --cli --log-level info"
BRIDGE_IMAP_PORT=1143
BRIDGE_SMTP_PORT=1025
FIFO="/fifo"

# check if required variables are set
# FIXME make more compact
die() { echo "$1"; exit 1; }
[ -z "$IMAP_PORT" ] && die '$IMAP_PORT is not set'
[ -z "$SMTP_PORT" ] && die '$SMTP_PORT is not set'

# initialize gpg if necessary
if ! [ -d /root/.gnupg ]; then
  gpg --generate-key --batch << 'EOF'
    %no-protection
    %echo Generating GPG key
    Key-Type:RSA
    Key-Length:4096
    Name-Real:proton-bridge
    Expire-Date:0
    %commit
EOF
fi

# initialize pass if necessary
if ! [ -d /root/.password-store ]; then
  pass init proton-bridge
fi

# login to ProtonMail if neccessary
if ! [ -f /root/.cache/protonmail/bridge ]; then
  [ -z "$PM_USER" ] && die '$PM_USER is not set'
  [ -z "$PM_PASS" ] && die '$PM_PASS is not set'
  printf "login\n%s\n%s\n" "${PM_USER}" "${PM_PASS}" | ${BRIDGE}
fi

# socat will make the connection appear to come from 127.0.0.1, since
# the ProtonMail Bridge expects that
socat TCP-LISTEN:${SMTP_PORT},fork TCP:127.0.0.1:${BRIDGE_SMTP_PORT} &
socat TCP-LISTEN:${IMAP_PORT},fork TCP:127.0.0.1:${BRIDGE_IMAP_PORT} &

# display account information, then keep stdin open
[ -e ${FIFO} ] || mkfifo ${FIFO}
{
  printf "info\n";
  cat ${FIFO}
} | ${BRIDGE}

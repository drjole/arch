#!/bin/bash

set -e

# Brightness control
sudo usermod -aG i2c jole
if [ ! -e "/etc/modules-load.d/ic2-dev.conf" ]; then
    cat <<EOF | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
i2c-dev
EOF
fi

# Sensors
if [ ! -e "/etc/modules-load.d/nct6775.conf" ]; then
    echo nct6775 | sudo tee /etc/modules-load.d/nct6775.conf
    echo "options nct6775 force_id=0xd802" | sudo tee /etc/modprobe.d/nct6775.conf
fi

#!/bin/bash

# Run setup.sh if it exists
if [ -f scripts/setup.sh ]; then
    scripts/setup.sh || true
fi
MEM_SIZE_CONVERTED=$(echo "$MEM_SIZE" | sed 's/Gi/G/')
# Start SPDK app with specified memory size
/spdk/build/bin/nvmf_tgt --mem-size ${MEM_SIZE_CONVERTED:-1024} --iova-mode=va &

sleep 10

/spdk/scripts/rpc.py nvmf_create_transport -t TCP -u 16384 -m 8 -c 8192

# Prevent container from exiting
tail -f /dev/null


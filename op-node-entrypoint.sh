#!/bin/bash
set -eu

# wait until local geth comes up (authed so will return 401 without token)
until [ "$(curl -s -w '%{http_code}' -o /dev/null "$OP_NODE_L2_ENGINE_RPC")" -eq 401 ]; do
  echo "waiting for geth to be ready"
  sleep 5
done

# public-facing P2P node, advertise public IP address
PUBLIC_IP=$(curl -s v4.ident.me)
export OP_NODE_P2P_ADVERTISE_IP=$PUBLIC_IP

echo "$OP_NODE_L2_ENGINE_AUTH_RAW" > "$OP_NODE_L2_ENGINE_AUTH"

./op-node

#!/bin/bash
set -eu

VERBOSITY=${GETH_VERBOSITY:-3}
GETH_DATA_DIR=/data
GETH_CHAINDATA_DIR="$GETH_DATA_DIR/geth/chaindata"
OP_GETH_GENESIS_FILE_PATH="${OP_GETH_GENESIS_FILE_PATH:-/genesis.json}"
CHAIN_ID=$(cat "$OP_GETH_GENESIS_FILE_PATH" | jq -r .config.chainId)
RPC_PORT="${RPC_PORT:-8545}"
WS_PORT="${WS_PORT:-8546}"
AUTHRPC_PORT="${AUTHRPC_PORT:-8551}"
HOST_IP="0.0.0.0"

mkdir -p $GETH_DATA_DIR

if [ ! -d "$GETH_CHAINDATA_DIR" ]; then
	echo "$GETH_CHAINDATA_DIR missing, running init"
	echo "Initializing genesis."
	./geth --verbosity="$VERBOSITY" init \
		--datadir="$GETH_DATA_DIR" \
		"$OP_GETH_GENESIS_FILE_PATH"
else
	echo "$GETH_CHAINDATA_DIR exists."
fi

echo "$OP_NODE_L2_ENGINE_AUTH_RAW" > "$OP_NODE_L2_ENGINE_AUTH"

./geth \
	--datadir="$GETH_DATA_DIR" \
	--verbosity="$VERBOSITY" \
	--http \
	--http.corsdomain="*" \
	--http.vhosts="*" \
	--http.addr=0.0.0.0 \
	--http.port="$RPC_PORT" \
	--http.api=web3,debug,eth,txpool,net,engine \
	--authrpc.addr=0.0.0.0 \
	--authrpc.port="$AUTHRPC_PORT" \
	--authrpc.vhosts="*" \
	--authrpc.jwtsecret="$OP_NODE_L2_ENGINE_AUTH" \
	--ws \
	--ws.addr=0.0.0.0 \
	--ws.port="$WS_PORT" \
	--ws.origins="*" \
	--ws.api=debug,eth,txpool,net,engine \
	--syncmode=full \
	--gcmode=archive \
	--nodiscover \
	--maxpeers=100 \
	--nat=extip:$HOST_IP \
	--networkid="$CHAIN_ID"

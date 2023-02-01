# node

This repository contains the relevant Docker builds to run your own node on the Base network.
Currently only the Base testnet (on Goerli) is supported.

Note: transaction submission to the sequencer is not yet supported. We'll provide a value for `op-geth`'s `--rollup.sequencerhttp` soon.

### Usage

1. Ensure you have an Goerli L1 node RPC available, and set `OP_NODE_L1_ETH_RPC` (in `docker-compose.yml` if using docker-compose).
2. Run:
```
docker-compose up
```
3. You should now be able to `curl` your Base node:
```
curl -d '{"id":0,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
     -H "Content-Type: application/json" \
     http://localhost:8545
```

![Base](logo.webp)

# Base node

Base is a secure, low-cost, developer-friendly Ethereum L2 built to bring the next billion users to web3. It's built on Optimism’s open-source [OP Stack](https://stack.optimism.io/).

This repository contains the relevant Docker builds to run your own node on the Base network.

### Hardware requirements

We recommend you this configuration to run a node:
- at least 16 GB RAM
- an SSD drive with at least 100 GB free

### Troubleshooting

If you encounter problems with your node, please open a [GitHub issue](https://github.com/base-org/node/issues/new/choose) or reach out on our [Discord](https://discord.gg/buildonbase):
- Once you've joined, in the Discord app go to `server menu` > `Linked Roles` > `connect GitHub` and connect your GitHub account so you can gain access to our developer channels
- Report your issue in `#🛟|node-support`

### Supported networks

| Ethereum Network | Status |
|------------------|--------|
| Goerli testnet   | ✅     |
| Mainnet          | 🚧     |


### Usage

1. Ensure you have [an ethereum Goerli L1 node RPC](https://docs.base.org/tools/node-providers) available (not Base Goerli), and set `OP_NODE_L1_ETH_RPC` (in `docker-compose.yml` if using docker-compose). If running your own L1 node, it needs to be synced before Base will be able to fully sync.
2. Run:
```
docker compose up
```
3. You should now be able to `curl` your Base node:
```
curl -d '{"id":0,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
  -H "Content-Type: application/json" http://localhost:8545
```

Note: Some L1 nodes (e.g. Erigon) do not support fetching storage proofs. You can work around this by specifying `--l1.trustrpc` when starting op-node (add it in `op-node-entrypoint.sh` and rebuild the docker image with `docker compose build`.) Do not do this unless you fully trust the L1 node provider.

### Syncing

Sync speed depends on your L1 node, as the majority of the chain is derived from data submitted to the L1. You can check your syncing status using the `optimism_syncStatus` RPC on the `op-node` container. Example:
```
echo Latest synced block behind by: \
$((($( date +%s )-\
$( curl -d '{"id":0,"jsonrpc":"2.0","method":"optimism_syncStatus"}' -H "Content-Type: application/json" http://localhost:7545 |
   jq -r .result.unsafe_l2.timestamp))/60)) minutes
```

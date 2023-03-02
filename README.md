![Base](logo.webp)

# Base node

Base is a secure, low-cost, developer-friendly Ethereum L2 built to bring the next billion users to web3. It's built on Optimism’s open-source [OP Stack](https://stack.optimism.io/).

This repository contains the relevant Docker builds to run your own node on the Base network.

### Hardware requirements

We recommend you this configuration to run a node:
- at least 16 GB RAM
- an SSD drive with at least 100 GB free

### Troubleshootings

If you encounter problems with your node, please reach it out on [our Discord](https://discord.gg/buildonbase):
- take the "Developer" role (to do this, go to `the server menu > Linked Roles > connect GitHub`)
- ask it in `#🛟|node-support`

### Supported networks

| Ethereum Network | Status |
|------------------|--------|
| Goerli testnet   | ✅     |
| Mainnet          | 🚧     |

### Upgrades

If you run a node you need to subscribe to [an update feed](https://community.optimism.io/docs/developers/releases/) (either [the mailing list](https://groups.google.com/a/optimism.io/g/optimism-announce) or [the RSS feed](https://changelog.optimism.io/feed.xml)) to know when to upgrade. <br/>
Otherwise, your node will eventually stop working.

### Hosted Goerli L1 nodes providers

You'll need your own L1 RPC URL. This can be one that you run yourself, or via a third-party provider, such as our [partners](https://docs.base.org/tools/node-providers/).

### Usage

1. Ensure you have an Goerli L1 node RPC available, and set `OP_NODE_L1_ETH_RPC` (in `docker-compose.yml` if using docker-compose).
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

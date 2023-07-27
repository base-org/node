![Base](logo.webp)

# Base node

Base is a secure, low-cost, developer-friendly Ethereum L2 built to bring the next billion users onchain. It's built on Optimism’s open-source [OP Stack](https://stack.optimism.io/).

This repository contains the relevant Docker builds to run your own node on the Base network.

<!-- Badge row 1 - status -->

[![GitHub contributors](https://img.shields.io/github/contributors/base-org/node)](https://github.com/base-org/node/graphs/contributors)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/w/base-org/node)](https://github.com/base-org/node/graphs/contributors)
[![GitHub Stars](https://img.shields.io/github/stars/base-org/node.svg)](https://github.com/base-org/node/stargazers)
![GitHub repo size](https://img.shields.io/github/repo-size/base-org/node)
[![GitHub](https://img.shields.io/github/license/base-org/node?color=blue)](https://github.com/base-org/node/blob/main/LICENSE)

<!-- Badge row 2 - links and profiles -->

[![Website base.org](https://img.shields.io/website-up-down-green-red/https/base.org.svg)](https://base.org)
[![Blog](https://img.shields.io/badge/blog-up-green)](https://base.mirror.xyz/)
[![Docs](https://img.shields.io/badge/docs-up-green)](https://docs.base.org/)
[![Discord](https://img.shields.io/discord/1067165013397213286?label=discord)](https://base.org/discord)
[![Twitter BuildOnBase](https://img.shields.io/twitter/follow/BuildOnBase?style=social)](https://twitter.com/BuildOnBase)

<!-- Badge row 3 - detailed status -->

[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr-raw/base-org/node)](https://github.com/base-org/node/pulls)
[![GitHub Issues](https://img.shields.io/github/issues-raw/base-org/node.svg)](https://github.com/base-org/node/issues)

### Hardware requirements

We recommend you have this configuration to run a node:

- at least 16 GB RAM
- an SSD drive with at least 100 GB free

### Troubleshooting

If you encounter problems with your node, please open a [GitHub issue](https://github.com/base-org/node/issues/new/choose) or reach out on our [Discord](https://discord.gg/buildonbase):

- Once you've joined, in the Discord app go to `server menu` > `Linked Roles` > `connect GitHub` and connect your GitHub account so you can gain access to our developer channels
- Report your issue in `#🛟|node-support`

### Supported networks

| Ethereum Network | Status |
| ---------------- | ------ |
| Goerli testnet   | ✅     |
| Mainnet          | ✅     |

### Usage

1. Ensure you have an Ethereum L1 full node RPC available (not Base), and set `OP_NODE_L1_ETH_RPC` (in the `.env.*` file if using docker-compose). If running your own L1 node, it needs to be synced before Base will be able to fully sync.
2. Uncomment the line relevant to your network (`.env.goerli` or `.env.mainet`) under the 2 `env_file` keys in `docker-compose.yml`.
3. Run:

```
docker compose up --build
```

3. You should now be able to `curl` your Base node:

```
curl -d '{"id":0,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
  -H "Content-Type: application/json" http://localhost:8545
```

Note: Some L1 nodes (e.g. Erigon) do not support fetching storage proofs. You can work around this by specifying `--l1.trustrpc` when starting op-node (add it in `op-node-entrypoint` and rebuild the docker image with `docker compose build`.) Do not do this unless you fully trust the L1 node provider.

You can map a local data directory for `op-geth` by adding a volume mapping to the `docker-compose.yaml`:

```yaml
services:
  geth: # this is Optimism's geth client
    ...
    volumes:
      - $HOME/data/base:/data
```

### Syncing

Sync speed depends on your L1 node, as the majority of the chain is derived from data submitted to the L1. You can check your syncing status using the `optimism_syncStatus` RPC on the `op-node` container. Example:

```
command -v jq  &> /dev/null || { echo "jq is not installed" 1>&2 ; }
echo Latest synced block behind by: \
$((($( date +%s )-\
$( curl -s -d '{"id":0,"jsonrpc":"2.0","method":"optimism_syncStatus"}' -H "Content-Type: application/json" http://localhost:7545 |
   jq -r .result.unsafe_l2.timestamp))/60)) minutes
```

## Disclaimer

We’re excited for you to build on Base 🔵 — but we want to make sure that you understand the nature of the the node software and smart contracts offered here.

THE NODE SOFTWARE AND SMART CONTRACTS CONTAINED HEREIN ARE FURNISHED AS IS, WHERE IS, WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTY OF MERCHANTABILITY, NON- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE. IN PARTICULAR, THERE IS NO REPRESENTATION OR WARRANTY THAT THE NODE SOFTWARE AND SMART CONTRACTS WILL PROTECT YOUR ASSETS — OR THE ASSETS OF THE USERS OF YOUR APPLICATION — FROM THEFT, HACKING, CYBER ATTACK, OR OTHER FORM OF LOSS OR DEVALUATION.

You also understand that using the node software and smart contracts are subject to applicable law, including without limitation, any applicable anti-money laundering laws, anti-terrorism laws, export control laws, end user restrictions, privacy laws, or economic sanctions laws/regulations.

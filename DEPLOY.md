# Deploy Mercado to Bulletin Chain

1. Clone repository

2. Install dependencies: `pnpm install`

3. Get testnet tokens from [Paseo faucet](https://faucet.polkadot.io/?parachain=paseo)

4. Deploy:

```
MNEMONIC="your twelve word phrase" ./scripts/deploy.sh
```

5. (Optional) Deploy with a .dot domain:

```
MNEMONIC="your twelve word phrase" ./scripts/deploy.sh --domain mystore.dot
```

## Script Options

| Option            | Description                                     |
| ----------------- | ----------------------------------------------- |
| `--domain <name>` | Register/use a DotNS domain (e.g., mystore.dot) |
| `--app <name>`    | App to deploy: web (default), admin, mm-portal  |
| `--skip-build`    | Skip build step (use existing dist/)            |
| `--dry-run`       | Preview what would be deployed                  |

## Verify

- The script outputs an IPFS CID and gateway URL
- Open the gateway URL to verify your deployment

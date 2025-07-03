# FundMe Smart Contract 

A decentralized crowdfunding smart contract built with Solidity and Foundry. This is a learning project for understanding smart contract development.

## Features

- Accept ETH donations with minimum funding requirements ($5 USD equivalent)
- Uses Chainlink Price Feeds for ETH to USD conversion
- Owner can withdraw all collected funds
- Tracks all contributors and their funding amounts

## Prerequisites

- [Git](https://git-scm.com/)
- [Foundry](https://getfoundry.sh/)

## Installation

```bash
git clone https://github.com/AakashJamadar/foundry-fund-me.git
cd foundry-fund-me
forge install
forge build
```

## Testing

```bash
forge test
```

## Deployment

### Local Network (Anvil)
```bash
anvil
make deploy
```

### Sepolia Testnet
1. Create `.env` file with:
```
SEPOLIA_RPC_URL=your_sepolia_rpc_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

2. Deploy:
```bash
make deploy-sepolia
```

## Usage

### Fund the Contract
```bash
cast send <CONTRACT_ADDRESS> "fund()" --value 0.1ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

### Withdraw Funds (Owner only)
```bash
cast send <CONTRACT_ADDRESS> "withdraw()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

### Check Contract Balance
```bash
cast balance <CONTRACT_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

## Project Structure

```
├── src/
│   ├── FundMe.sol          # Main contract
│   └── PriceConverter.sol  # Price conversion library
├── script/
│   ├── DeployFundMe.s.sol  # Deployment script
│   └── Interactions.s.sol  # Interaction scripts
├── test/
│   └── FundMeTest.t.sol    # Tests
└── Makefile               # Build commands
```

## Key Contract Functions

- `fund()` - Send ETH to the contract (minimum $5 USD)
- `withdraw()` - Withdraw all funds (owner only)
- `getFunderFromIndex(uint256)` - Get funder by index
- `getAddressToAmountFunded(address)` - Get amount funded by address

## Networks Supported

- **Ethereum Mainnet**
- **Sepolia Testnet** 
- **Local Network** (with mock price feeds)

## License

MIT
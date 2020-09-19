# Ethereum Atomic Swaps Smart Contracts

The Atomic Swap exchange is based on HTLC Contracts on each blockchain. This type of contracts allows exchanges between blockchains with guaranteed atomicity - that is, the exchange will either take place, or you will receive your funds back.

Contains:
 - Ethereum Atomic Swaps smart contract
 - ERC20 Token Atomic smart contract
 - Token smart contract for USDT emulation


## Testnet console
```
truffle console --network ropsten
// mint some tokens
Token.deployed().then(function(instance) {test = instance})
test.mint('0xe5f178488DB8a528915aBA104aBaad69977Ce3b6', 100000000);
test.mint('0xf6b3ebCF52B1a38756Da754fE0Ec44222A9f8ce5', 100000000);
```

### Deploy to testnet
```
truffle deploy --network ropsten
```

### Deploy to mainnet
```
truffle deploy --network mainnet
```

### Tests
```
truffle develop
# > test
```

### Related projects
[Free TON Atomic Swaps smart contracts](https://github.com/ton-swaps/tonswapsmc)
[Free TON Atomic Swaps javascript library](https://github.com/ton-swaps/tonswaplib)
[Free TON Atomic Swaps Dapp](https://github.com/ton-swaps/tonswapapp)

### Submission
This remark was added for participation in [Free TON Contest: Atomic Swaps on Free TON [31 August 2020 - 20 September 2020]](https://forum.freeton.org/t/contest-atomic-swaps-on-free-ton-31-august-2020-20-september-2020/2508)

### Authors
Based on https://github.com/swaponline/swap.truffle
E-mail: sergeydobkin8@gmail.com
Telegram: @Sergeydobkin

### License
MIT


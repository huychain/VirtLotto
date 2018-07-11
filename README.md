# VirtLotto

Required user stories:

- [x] The contract has one operation pickNumber(uint number) payable.
- [x] pickNumber should accept integer between 1 and 10 inclusive, and accept any amount of ether (minimum bet is X finney).
- [x] After Y calls to pickNumber, the contract will choose a random number.
- [x] X and Y are configurable in the constructor of the contract.
- [x] The winner(s) get to keep all the money that has been pooled in the contract. If there is more than one winner, the prize money is split evenly.
- [x] Addresses are limited on the number of tickets. One address can only purchase a maximum of 4 tickets.
- [ ] Users should be able to pick numbers via a simple web interface. A sample index.html can be found here.

Advanced user stories (optional):

- [ ] Make a "true" random number. A common example is to use Oraclize.
- [ ] Contract picks winner after 5 calls or 5 minutes, whichever happens first. To schedule calls, you might want to look into using the Ethereum Alarm Clock.
- [ ] Contract offers dynamic odds. Once a number is picked, the payout to the winners decreases and odds on others increase proportionally.

------------------------------

#### start Ganache server

```
ganache-cli
```

or on specific port

```
ganache-cli -p 7545
```

#### setup environment for project

```
npm install solc
npm install web3@0.20.2
```

#### build
open terminal, type `node` to get to REPL, then

```javascript
Web3 = require('web3')
web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545")) // Check for the right port number

code = fs.readFileSync('VirtLotto.sol').toString();
solc = require('solc');
compiledCode = solc.compile(code);

VirtLottoContract = web3.eth.contract(JSON.parse(compiledCode.contracts[':VirtLotto'].interface))

byteCode = compiledCode.contracts[':VirtLotto'].bytecode
```

#### deploy
(latest contract version)

```javascript
deployedContract = VirtLottoContract.new(
    web3.toWei('1', 'finney'), 5,
    {
        data: byteCode,
        from: web3.eth.accounts[0],
        gas: 2000000
    })
contractInstance = VirtLottoContract.at(deployedContract.address)
```

#### place a bet

```javascript
contractInstance.pickNumber(1, {from: web3.eth.accounts[0], gas: 1000000, value: web3.toWei(1, "finney")});
```

#### notes on config index.js

replace `<interface>`, `<address>`

```javascript
...
abi = JSON.parse('<interface>')
...
contractInstance = VirtLottoContract.at('<address>');
...
```

with latest retrieved from command

```javascript
compiledCode.contracts[':VirtLotto'].interface

contractInstance.address
```

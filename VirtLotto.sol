// The following user stories must be completed:
// [x] The contract has one operation pickNumber(uint number) payable.
// [x] pickNumber should accept integer between 1 and 10 inclusive, and accept any amount of ether (minimum bet is X finney).
// [x] After Y calls to pickNumber, the contract will choose a random number.
// [x] X and Y are configurable in the constructor of the contract.
// [ ] The winner(s) get to keep all the money that has been pooled in the contract. If there is more than one winner, the prize money is split evenly.
// [ ] Addresses are limited on the number of tickets. One address can only purchase a maximum of 4 tickets.
// [ ] Users should be able to pick numbers via a simple web interface. A sample index.html can be found here.

// The following advanced user stories are optional. You're not required to do these, but you will learn more from doing them:
// [ ] Make a "true" random number. A common example is to use Oraclize.
// [ ] Contract picks winner after 5 calls or 5 minutes, whichever happens first. To schedule calls, you might want to look into using the Ethereum Alarm Clock.
// [ ] Contract offers dynamic odds. Once a number is picked, the payout to the winners decreases and odds on others increase proportionally.

pragma solidity ^0.4.18;

contract VirtLotto {
  address public owner;

  // configurations
  uint public minBet = 100 finney;
  uint8 public maxNumOfBets = 5;
  // constants
  uint8 public constant MIN_NUMBER = 1;
  uint8 public constant MAX_NUMBER = 10;

  uint public totalBet;
  uint8 public numberOfBets;
  address[] public players;

  modifier onlyOwner {
    require (
      msg.sender == owner,
      "Only owner can call this function."
    );
    _;
  }

  constructor(uint _minBet, uint8 _maxNumOfBets) public {
    if (_minBet > 0) {
      minBet = _minBet;
    }
    if (_maxNumOfBets > 0) {
      maxNumOfBets = _maxNumOfBets;
    }
    owner = msg.sender;
  }

  function pickNumber(uint8 number) public payable {
    require(validBet(number) == true, "Bet between 1 and 10");
    require(msg.value >= minBet, "Below min bet");

    // increase bet count
    numberOfBets += 1;
    // keep bet value
    totalBet += msg.value;
    // keep player
    players.push(msg.sender);

    if (numberOfBets >= maxNumOfBets) {
      uint8 winNumber = random();

      // then, reset count
      numberOfBets = 0;
    }
  }

  function validBet(uint8 num) private pure returns (bool) {
    if (num >= MIN_NUMBER && num <= MAX_NUMBER) {
      return true;
    } else {
      return false;
    }
  }

  function random() view public returns (uint8) {
    return uint8(uint256(keccak256(abi.encodePacked(block.timestamp)))%10);
  }

  function kill() public onlyOwner {
    selfdestruct(owner);
  }
}

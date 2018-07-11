// The following user stories must be completed:
// [x] The contract has one operation pickNumber(uint number) payable.
// [x] pickNumber should accept integer between 1 and 10 inclusive, and accept any amount of ether (minimum bet is X finney).
// [x] After Y calls to pickNumber, the contract will choose a random number.
// [x] X and Y are configurable in the constructor of the contract.
// [ ] The winner(s) get to keep all the money that has been pooled in the contract. If there is more than one winner, the prize money is split evenly.
// [x] Addresses are limited on the number of tickets. One address can only purchase a maximum of 4 tickets.
// [ ] Users should be able to pick numbers via a simple web interface. A sample index.html can be found here.

// The following advanced user stories are optional. You're not required to do these, but you will learn more from doing them:
// [ ] Make a "true" random number. A common example is to use Oraclize.
// [ ] Contract picks winner after 5 calls or 5 minutes, whichever happens first. To schedule calls, you might want to look into using the Ethereum Alarm Clock.
// [ ] Contract offers dynamic odds. Once a number is picked, the payout to the winners decreases and odds on others increase proportionally.

pragma solidity ^0.4.18;

contract VirtLotto {
  // constants
  uint8 public constant MIN_NUMBER = 1;
  uint8 public constant MAX_NUMBER = 10;
  uint8 public constant MAX_TICKETS_PER_PLAYER = 4;

  struct Ticket {
    uint8 number;
    uint amount;
  }

  // configurations
  uint public minBet = 100 finney;
  uint8 public betsPerRound = 5;

  address public owner;

  address[] public players;
  mapping(address => Ticket[]) public playerTickets;
  uint public totalBetAmount;
  uint8 public betCount;

  modifier onlyOwner {
    require (
      msg.sender == owner,
      "Only owner can call this function."
    );
    _;
  }

  constructor(uint _minBet, uint8 _betsPerRound) public {
    minBet = _minBet;
    betsPerRound = _betsPerRound;
    owner = msg.sender;
  }

  function pickNumber(uint8 number) public payable {
    require(number >= MIN_NUMBER && number <= MAX_NUMBER, "Bet between 1 and 10");
    require(msg.value >= minBet, "Below min bet");
    require(playerTickets[msg.sender].length < MAX_TICKETS_PER_PLAYER, "Excess max bet times per player");

    // first bet of sender? keep track
    if (playerTickets[msg.sender].length == 0) {
      players.push(msg.sender);
    }

    // get to this, the bet is valid, keep it
    playerTickets[msg.sender].push(Ticket(number, msg.value));

    // increase bet count
    betCount++;
    // increase bet amount
    totalBetAmount += msg.value;

    // check end round
    if (betCount >= betsPerRound) {
      // TODO: get random number

      // deliver prizes

      // reset game
    }
  }

  function random() view public returns (uint8) {
    return uint8(uint256(keccak256(abi.encodePacked(block.timestamp)))%10);
  }

  function kill() public onlyOwner {
    selfdestruct(owner);
  }
}

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
  address[] public winners;
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
      // get win number
      uint8 winNumber = random();
      // end round
      endRound(winNumber);
    }
  }

  function endRound(uint8 winNumber) private {
    // get winners
    for (uint i = 0; i < players.length; i++) {
      if (isWinner(winNumber, players[i])) {
        winners.push(players[i]);
      }
    }

    bool hasWinners = winners.length > 0;

    // deliver prizes if have winners
    if (hasWinners) {
      uint prize = totalBetAmount / winners.length;
      for (i = 0; i < winners.length; i++) {
        winners[i].transfer(prize);
      }
    }

    // reset round
    if (hasWinners) {
      totalBetAmount = 0;
    }
    for (i = 0; i < players.length; i++) {
      delete playerTickets[players[i]];
    }
    players.length = 0;
    winners.length = 0;
    betCount = 0;
  }

  function isWinner(uint8 winNumber, address player) private view returns (bool) {
    for (uint i = 0; i < playerTickets[player].length; i++) {
      if (playerTickets[player][i].number == winNumber) {
        return true;
      }
    }
    return false;
  }

  function random() view public returns (uint8) {
    return uint8(uint256(keccak256(abi.encodePacked(block.timestamp)))%10);
  }

  function kill() public onlyOwner {
    selfdestruct(owner);
  }
}

pragma solidity ^0.4.18;

import "./oraclizeAPI_0.5.sol";

contract VirtLotto is usingOraclize {
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

  // Events that will be fired on changes.
  event PickNumber(address player, uint8 number, uint amount);
  event WinNumber(uint8 winNumber);
  event DeliverPrize(address winner, uint prize);

  event newRandomNumber_bytes(bytes);
  event newRandomNumber_uint(uint);

  constructor(uint _minBet, uint8 _betsPerRound) public {
    minBet = _minBet;
    betsPerRound = _betsPerRound;
    owner = msg.sender;
    oraclize_setProof(proofType_Ledger); // sets the Ledger authenticity proof in the constructor
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

    emit PickNumber(msg.sender, number, msg.value);

    // check end round
    if (betCount >= betsPerRound) {
      // get win number
      trueRandom();
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

        emit DeliverPrize(winners[i], prize);
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

  // the callback function is called by Oraclize when the result is ready
  // the oraclize_randomDS_proofVerify modifier prevents an invalid proof to execute this function code:
  // the proof validity is fully verified on-chain
  function __callback(bytes32 _queryId, string _result, bytes _proof)
  {
    if (msg.sender != oraclize_cbAddress()) revert();

    if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
      // the proof verification has failed, do we need to take any action here? (depends on the use case)
    } else {
      // the proof verification has passed
      // now that we know that the random number was safely generated, let's use it..

      emit newRandomNumber_bytes(bytes(_result)); // this is the resulting random number (bytes)

      // for simplicity of use, let's also convert the random bytes to uint if we need
      uint maxRange = 2**(8* 7); // this is the highest uint we want to get. It should never be greater than 2^(8*N), where N is the number of random bytes we had asked the datasource to return
      uint randomNumber = uint(keccak256(abi.encodePacked(_result))) % maxRange; // this is an efficient way to get the uint out in the [0, maxRange] range

      emit newRandomNumber_uint(randomNumber); // this is the resulting random number (uint)

      uint8 winNumber = uint8(randomNumber % 10);

      emit WinNumber(winNumber);

      // end round
      endRound(winNumber);
    }
  }

  function trueRandom() payable {
    uint N = 7; // number of random bytes we want the datasource to return
    uint delay = 0; // number of seconds to wait before the execution takes place
    uint callbackGas = 200000; // amount of gas we want Oraclize to set for the callback function
    bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas); // this function internally generates the correct oraclize_query and returns its queryId
  }

  function random() view public returns (uint8) {
    return uint8(uint256(keccak256(abi.encodePacked(block.timestamp)))%10);
  }

  function kill() public onlyOwner {
    selfdestruct(owner);
  }
}

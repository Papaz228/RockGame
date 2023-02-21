// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RockPaperScissorsWithoutOracle {
    IERC20 public token;
    uint256 public minBetAmount;
    uint256 public maxBetAmount;
    address owner;

    enum Choice {None, Rock, Paper, Scissors}
    enum Result {None, PlayerWins, ComputerWins, Draw}

    struct Game {
        address player;
        uint256 betAmount;
        Choice playerChoice;
        Choice computerChoice;
        Result result;
        uint256 payout;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "you are not owner");
        _;
    }

    mapping(bytes32 => Game) public games;

    event GameStarted(address player, uint256 betAmount);
    event GameEnded(address player, uint256 betAmount, Choice playerChoice, Choice computerChoice, Result result, uint256 payout);

    constructor(
        address _token,
        uint256 _minBetAmount,
        uint256 _maxBetAmount
    ) {
        token = IERC20(_token);
        minBetAmount = _minBetAmount;
        maxBetAmount = _maxBetAmount;
        owner = msg.sender;
    }

    // Function to fund the contract with tokens
    function fund(uint256 amount) external onlyOwner {
        token.transferFrom(msg.sender, address(this), amount);
    }

    function startGame(uint256 _betAmount, uint256 _playerChoice) public {
        require(_betAmount >= minBetAmount && _betAmount <= maxBetAmount, "Invalid bet amount");
        require(token.balanceOf(msg.sender) >= _betAmount, "Insufficient token balance");
        require(_playerChoice >= 1 && _playerChoice <= 3, "Invalid player choice");

        // Transfer tokens from the player to this contract
        token.transferFrom(msg.sender, address(this), _betAmount);

        // Generate a new request ID for this game
        bytes32 requestId = keccak256(abi.encodePacked(msg.sender, block.number));

        // Store the game data in a struct
        Game storage game = games[requestId];
        game.player = msg.sender;
        game.betAmount = _betAmount;
        game.playerChoice = Choice(_playerChoice);

        // Determine the computer's move based on a pseudo-random number
        uint256 computerChoice = (block.timestamp % 3) + 1;
        game.computerChoice = Choice(computerChoice);

        // Determine the result of the game
        if (game.playerChoice == game.computerChoice) {
            game.result = Result.Draw;
            token.transfer(game.player, game.betAmount);
        } else if ((game.playerChoice == Choice.Rock && game.computerChoice == Choice.Scissors) ||
                   (game.playerChoice == Choice.Paper && game.computerChoice == Choice.Rock) ||
                   (game.playerChoice == Choice.Scissors && game.computerChoice == Choice.Paper)) {
            game.result = Result.PlayerWins;
            uint256 payout = game.betAmount * 2;
            token.transfer(game.player, payout);
            game.payout = payout;
        } else {
            game.result = Result.ComputerWins;
            game.payout = 0;
        }

        // Emit a GameEnded event with the game data
        emit GameEnded(game.player, game.betAmount, game.playerChoice, game.computerChoice, game.result, game.payout);
    }

    // Withdraw contract balance
    function withdraw() external onlyOwner{
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    // Set the bet amount
    function setBetAmount(uint256 _minBetAmount, uint256 _maxBetAmount) external onlyOwner {
    minBetAmount = _minBetAmount;
    maxBetAmount = _maxBetAmount;
}

    // Set the token address for paying bets and transferring winnings
    function setTokenAddress(address _token) external onlyOwner{
        token = IERC20(_token);
    }
}

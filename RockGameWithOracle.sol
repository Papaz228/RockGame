// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RockGame is VRFConsumerBase {
    //Enum for 3 moves and null
    enum Move { None, Rock, Paper, Scissors }
    //Enum for showing result of the game
    enum Result { None, PlayerWins, ComputerWins, Draw }
    //Struct for saving games
    struct Game {
        address player;
        Move playerMove;
        Move computerMove;
        uint256 betAmount;
        bytes32 requestId;
    }
    //Modifier to check owner address
    modifier onlyOwner(){
        require(msg.sender == owner,"Only owner!");
        _;
    }

    address owner;

    //Link token to pay for service
    address linkToken;

    // Declare a variable to store the RNG coordinator contract address
    address  vrfCoordinator;

    // Declare a variable to store the fee to request randomness
    uint256 fee;

    // Declare a variable to store the chainlink key hash
    bytes32 keyHash;

    //Map for structs and id
    mapping(bytes32 => Game) games;


    // Variable to store the token contract address
    IERC20 token;

    //Event to emit the result of a game
    event GameResult(bytes32 requestId, Result result, uint256 payout);

    // Event to emit when the contract is funded with tokens
    event Funded(uint256 amount);

    // Event to emit when a player withdraws tokens from the contract
    event Withdrawn(address player, uint256 amount);

    //Constructor for coordinator address, link token address, hash for random, fee for request and ERC20 token 
    constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyHash, address _token) 
        VRFConsumerBase(vrfCoordinator, linkToken) 
    {
        vrfCoordinator = _vrfCoordinator;
        linkToken = _linkToken;
        keyHash = _keyHash;
        fee = 0.1 * 10 ** 18;
        token = IERC20(_token);
        owner = msg.sender;
    }

    // Function to fund the contract with tokens
    function fund(uint256 amount) external onlyOwner {
        token.transferFrom(msg.sender, address(this), amount);
        emit Funded(amount);
    }

    // Function to withdraw any remaining tokens from the contract
    function withdrawToken() external {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
        emit Withdrawn(msg.sender, balance);
    }

    // Function to start a game
    function startGame(Move move, uint256 betAmount) external {
        require(move == Move.Rock || move == Move.Paper || move == Move.Scissors, "Invalid move");
        require(token.balanceOf(msg.sender) >= betAmount, "Insufficient balance");

        bytes32 requestId = requestRandomness(keyHash, fee);
        Game memory game = Game(msg.sender, move, Move.None, betAmount, requestId);
        games[requestId] = game;
    }

    // Callback function that processes the random number generated by Chainlink VRF
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        Game storage game = games[requestId];
        require(game.player != address(0), "Game not found");
        require(game.computerMove == Move.None, "Move already set");
        // Set the computer's move based on the random number
        Move computerMove = Move(randomness % 3 + 1);
        game.computerMove = computerMove;
        // Determine the result of the game
        Result result = determineResult(game.playerMove, computerMove);
        // Calculate the payout and transfer tokens accordingly
        uint256 payout = 0;
        if (result == Result.PlayerWins) {
            payout = game.betAmount * 2;
            token.transfer(game.player, payout);
        } else if (result == Result.Draw) {
            payout = game.betAmount;
            token.transfer(game.player, payout);
        }
        // Emit the game result event
        emit GameResult(requestId, result, payout);
}

// Function to determine the result of a game
function determineResult(Move playerMove, Move computerMove) internal pure returns (Result) {
    if (playerMove == Move.Rock) {
        if (computerMove == Move.Paper) {
            return Result.ComputerWins;
        } else if (computerMove == Move.Scissors) {
            return Result.PlayerWins;
        } else {
            return Result.Draw;
        }
    } else if (playerMove == Move.Paper) {
        if (computerMove == Move.Scissors) {
            return Result.ComputerWins;
        } else if (computerMove == Move.Rock) {
            return Result.PlayerWins;
        } else {
            return Result.Draw;
        }
    } else {
        if (computerMove == Move.Rock) {
            return Result.ComputerWins;
        } else if (computerMove == Move.Paper) {
            return Result.PlayerWins;
        } else {
            return Result.Draw;
        }
    }
}
}
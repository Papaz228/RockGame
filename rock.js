var contractInstance;
async function connect() {
  if (window.ethereum) {
    await window.ethereum.request({ method: "eth_requestAccounts" });
    window.web3 = new Web3(window.ethereum);
    const account = web3.eth.accounts;
    walletAddress = account.givenProvider.selectedAddress;
    console.log(`Wallet: ${walletAddress}`);
    document.getElementById("submit-button").style.display = "block";
    contractInstance = new web3.eth.Contract(abi, contractAddress);
    contractInstance.events.GameStarted({ filter: { player: walletAddress } })
  .on('data', function(event) {
    console.log('GameStarted event:', event);
    const game = event.returnValues;
    const message = `Game started with bet amount ${game.betAmount}.`;
    document.getElementById("result").innerText = message;
  })
  .on("error", console.error);
  
  // Listen for the "GameEnded" event and update the UI accordingly
  contractInstance.events.GameEnded({ filter: { player: walletAddress } })
  .on('data', function(event) {
    console.log('GameEnded event:', event);
    const game = event.returnValues;
    let message = "";
    let result = "";
    let payout = "";
  
    switch (game.result) {
      case "0":
        result = "None";
        break;
      case "1":
        result = "Player Wins";
        payout = `You won ${game.payout} tokens!`;
        break;
      case "2":
        result = "Computer Wins";
        break;
      case "3":
        result = "Draw";
        payout = `You got your bet amount of ${game.betAmount} tokens back.`;
        break;
    }
  
    message = `Game ended with player choice ${game.playerChoice}, computer choice ${game.computerChoice}, and result ${result}.`;
    document.getElementById("gameStatus").innerText = message;
    document.getElementById("result").innerText = result;
    document.getElementById("payout").innerText = payout;
  })
  .on("error", console.error);
  } else {
    console.log("No wallet");
  }
}
  
  const contractAddress = '0x3ab596AbfCEd1e9eA5398fDeeFc365d9cCd8341E';
  const abi = [
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_token",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_minBetAmount",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_maxBetAmount",
                "type": "uint256"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "player",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "betAmount",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "enum RockPaperScissorsWithoutOracle.Choice",
                "name": "playerChoice",
                "type": "uint8"
            },
            {
                "indexed": false,
                "internalType": "enum RockPaperScissorsWithoutOracle.Choice",
                "name": "computerChoice",
                "type": "uint8"
            },
            {
                "indexed": false,
                "internalType": "enum RockPaperScissorsWithoutOracle.Result",
                "name": "result",
                "type": "uint8"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "payout",
                "type": "uint256"
            }
        ],
        "name": "GameEnded",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "player",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "betAmount",
                "type": "uint256"
            }
        ],
        "name": "GameStarted",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "fund",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "name": "games",
        "outputs": [
            {
                "internalType": "address",
                "name": "player",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "betAmount",
                "type": "uint256"
            },
            {
                "internalType": "enum RockPaperScissorsWithoutOracle.Choice",
                "name": "playerChoice",
                "type": "uint8"
            },
            {
                "internalType": "enum RockPaperScissorsWithoutOracle.Choice",
                "name": "computerChoice",
                "type": "uint8"
            },
            {
                "internalType": "enum RockPaperScissorsWithoutOracle.Result",
                "name": "result",
                "type": "uint8"
            },
            {
                "internalType": "uint256",
                "name": "payout",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "maxBetAmount",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "minBetAmount",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_minBetAmount",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_maxBetAmount",
                "type": "uint256"
            }
        ],
        "name": "setBetAmount",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_token",
                "type": "address"
            }
        ],
        "name": "setTokenAddress",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_betAmount",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_playerChoice",
                "type": "uint256"
            }
        ],
        "name": "startGame",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "token",
        "outputs": [
            {
                "internalType": "contract IERC20",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "withdraw",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];


  async function start() {
  if (!walletAddress) {
  console.error("Please connect MetaMask first");
  return;
  }
  if (!contractInstance) {
    console.error("Please connect MetaMask and wait for the contract instance to be created");
    return;
  }
  
  var playerChoice = document.getElementById("playerChoice").value;
  var betAmount = document.getElementById("betAmount").value;



  if (!Number.isInteger(Number(betAmount)) || Number(betAmount) <= 0) {
  console.error("Invalid betAmount");
  return;
  }

  contractInstance.methods.startGame([betAmount], [playerChoice]).send({ from: walletAddress })
  .on("transactionHash", function(hash) {
    const message = `Transaction ${hash} submitted. Waiting for confirmation...`;
    document.getElementById("gameStatus").innerText = message;
  })
  .on("confirmation", function(confirmationNumber, receipt) {
    const message = `Transaction confirmed!`;
    document.getElementById("gameStatus").innerText = message;
  })
  .on("error", function(error) {
    const message = `Error: ${error.message}`;
    document.getElementById("gameStatus").innerText = message;
  });

  }

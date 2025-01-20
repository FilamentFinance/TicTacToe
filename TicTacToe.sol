// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

contract TicTacToeGame {
    enum GameStatus {
        ACTIVE,
        WIN,
        DRAW
    }

    uint256 public immutable gameId;
    address public immutable playerOne;
    address public immutable playerTwo;
    address public winner;
    address private lastPlayed;
    uint8 private turnsTaken = 0;
    address[9] private gameBoard;
    GameStatus public gameStatus;

    event MovePlaced(uint256 indexed gameId, address indexed player, uint8 indexed location);
    event WinnerDeclared(uint256 indexed gameId, address indexed winner);
    event GameEnded(uint256 indexed gameId, uint8 indexed gameStatus);

    error TTT__GameOver();
    error TTT__NotAValidPlayer();
    error TTT__LocationTaken(uint8 location);
    error TTT__WaitForTurn();
    error TTT_InvalidLocation();

    constructor(
        uint256 _gameId,
        address _player1,
        address _player2
    ) {
        gameId = _gameId;
        playerOne = _player1;
        playerTwo = _player2;
    }

    function placeMove(address player, uint8 _location) external {
        if (_location >= 9) revert TTT_InvalidLocation();
        if (gameStatus != GameStatus.ACTIVE) revert TTT__GameOver();
        if (player != playerOne && player != playerTwo) revert TTT__NotAValidPlayer();
        if (gameBoard[_location] != address(0)) revert TTT__LocationTaken(_location);
        if (player == lastPlayed) revert TTT__WaitForTurn();

        gameBoard[_location] = player;
        lastPlayed = player;
        turnsTaken++;

        emit MovePlaced(gameId, player, _location);
        if (turnsTaken >= 5) {
            if (isWinner(player)) {
                winner = player;
                gameStatus = GameStatus.WIN;
                emit WinnerDeclared(gameId, player);
                emit GameEnded(gameId, uint8(gameStatus));
            } else if (turnsTaken == 9) {
                gameStatus = GameStatus.DRAW;
                emit GameEnded(gameId, uint8(gameStatus));
            }
        }
    }

    function isWinner(address _player) private view returns (bool) {
        uint8[3][8] memory winningfilters = [
            [0, 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [0, 4, 8],
            [6, 4, 2]
        ];
        for (uint8 i = 0; i < winningfilters.length; i++) {
            uint8[3] memory filter = winningfilters[i];
            if (gameBoard[filter[0]] == _player && gameBoard[filter[1]] == _player && gameBoard[filter[2]] == _player) {
                return true;
            }
        }
        return false;
    }

    function getGameBoard() external view returns (address[9] memory) {
        address[9] memory _gameBoard = gameBoard;
        return _gameBoard;
    }

    function getGameDetails()
        external
        view
        returns (
            address,
            address,
            address,
            GameStatus,
            address
        )
    {
        return (address(this), playerOne, playerTwo, gameStatus, winner);
    }
}

contract TicTacToe {
    struct GameInfo {
        TicTacToeGame game;
        address playerOne;
        address playerTwo;
    }
    GameInfo[] gameInfo;

    error TTTS__UnauthorizedPlayer(uint256 gameId);
    event NewTicTacToeCreated(address indexed gameAddress, uint256 indexed gameId);

    function createNewGame(address player2) external {
        uint256 gameId = gameInfo.length;
        TicTacToeGame ttt = new TicTacToeGame(gameId, msg.sender, player2);
        gameInfo.push(GameInfo(ttt, msg.sender, player2));
        emit NewTicTacToeCreated(address(ttt), gameId);
    }

    function placeMove(uint256 gameId, uint8 _location) external {
        TicTacToeGame ttt = gameInfo[gameId].game;
        if (msg.sender != gameInfo[gameId].playerOne && msg.sender != gameInfo[gameId].playerTwo)
            revert TTTS__UnauthorizedPlayer(gameId);
        ttt.placeMove(msg.sender, _location);
    }

    function getLatestGameId() external view returns (uint256) {
        return gameInfo.length == 0 ? 0 : gameInfo.length - 1;
    }

    function getGameBoard(uint256 gameId) external view returns (address[9] memory) {
        TicTacToeGame ttt = gameInfo[gameId].game;
        return ttt.getGameBoard();
    }

    function getGameDetails(uint256 gameId)
        external
        view
        returns (
            address,
            address,
            address,
            TicTacToeGame.GameStatus,
            address
        )
    {
        TicTacToeGame ttt = gameInfo[gameId].game;
        return ttt.getGameDetails();
    }
}

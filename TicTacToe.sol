// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

contract TicTacToe {

    address public _playerOne = msg.sender;
    address public _playerTwo = address(0);
    address private _lastPlayed = address(0);
    address public _winner = address(0);
    bool public _isGameOver = false;
    uint8 private _turnsTaken = 0;

    //GameBoard is a 1D array having the location indexes as 
    /*  
        0   1   2
        3   4   5
        6   7   8
    */
    address[9] private _gameBoard;
    
    //Function will start the game by taking the address of the second player. 
    //The address of the first player will be the same one which will initiate the game.
    function startGame(address _player2) external {
        _playerTwo = _player2;
    }
    

    //Function for placing the move of the current player on the game board
    function placeMove(uint8 _location) external {

        //This will check if the game is over or is still active by checking the isGameOver flag and the winner address
        require(!_isGameOver || _winner != address(0), "Game is over. Please try to initiate a new game.");

        //This will check if the game is draw or is still active by checking the isGameOver flag
        require(!_isGameOver, "Game is a draw. Please try to initiate a new game.");

        //This will check if the transaction is made from some other system(having different address other then that of players) apart from both the players
        require(msg.sender == _playerOne || msg.sender == _playerTwo, "Please try to perform the move from a valid player.");

        //While placing the move, we will check if the move at the specified location is already taken of not
        require(_gameBoard[_location] == address(0), "Location is already taken. Please try to perfom the move on other locations.");

        //This condition is to check if the last played player is again the turn or is the turn given to the next player inline
        require(msg.sender != _lastPlayed, "You already attempted the move. Its not your turn to exercise the move.");
        
        //Saving the player's address on the required location.
        _gameBoard[_location] = msg.sender;

        //Saving the current player's address in the last played variable so as to keep the track of the latest plater which exercised the move
        _lastPlayed = msg.sender;

        //Tracking the number of turns
        _turnsTaken++;
        
        //Checking if the game lead to the winner after the current move and accordingly updating the winner and isGameOver flag
        if (isWinner(msg.sender)) {
            _winner = msg.sender;
            _isGameOver = true;
            
        } 
        //For checking if the game is draw
        else if (_turnsTaken == 9) {
            _isGameOver = true;
        }
    }
    
    //Function for checking if we have a winner of the game
    function isWinner(address player) private view returns(bool) {
        //various winning filters in terms of rows, columns and diagonals
        uint8[3][8] memory winningfilters = [
            [0,1,2],[3,4,5],[6,7,8],  // winning row filters
            [0,3,6],[1,4,7],[2,5,8],  // winning column filters
            [0,4,8],[6,4,2]           // winning diagonal filters
        ];
        
        for (uint8 i = 0; i < winningfilters.length; i++) {
            uint8[3] memory filter = winningfilters[i];
            if (
                _gameBoard[filter[0]]==player &&
                _gameBoard[filter[1]]==player &&
                _gameBoard[filter[2]]==player
            ) {
                return true;
            }
        }
        return false;
    }
    
    //Function which returns the game board view 
    function getBoard() external view returns(string memory) {
        string memory gameBoardView;
        for(uint8 i = 0; i<_gameBoard.length; i++){
            gameBoardView = string(abi.encodePacked(bytes(gameBoardView), bytes(getLocationShape(_gameBoard[i])), " "));
            if((i+1)%3 == 0 && i != 0 && i != 8){
                gameBoardView = string(abi.encodePacked(bytes(gameBoardView), " | "));
            }
        }
        return gameBoardView;
    }

    //Function for checking the game board location is having the player one's address or player two's address
    function getLocationShape(address addressStored) private view returns(string memory){
        if(addressStored == address(0)){
            return "-";
        } else if(addressStored == _playerOne){
            return "X";
        } else{
            return "O";
        }
    }
}

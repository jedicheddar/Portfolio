import { useState } from 'react'
import './Game.css'

function Game() {
    const [gamesTotal, setGamesTotal] = useState(0);
    const [compWon, setCompWon] = useState(0);
    const [playerWon, setPlayerWon] = useState(0);
    const [currentMove, setCurrentMove] = useState(0);
    const [piece, setPiece] = useState(Array(9).fill(null));
    const [firstMove, setFirstMove] = useState('player');

    function playPiece(item) {
        const winner = isWinner(item);
        if (winner) {
            setGamesTotal((gamesTotal + 1));
            if (winner === 'O') {
                setCompWon((compWon + 1));
            } else {
                setPlayerWon((playerWon + 1));
            }
        } else {
            setCurrentMove((currentMove + 1));
        }
        setPiece(item);
        // determine if the game is a tie
        let i = 0
        for (i = 0; i < item.length; i++) {
            if (item[i] === null) {
                break;
            }
        }
        if (i === item.length) {
            setGamesTotal((gamesTotal + 1));
        }
    }

    function changePlayer(e) {
        setFirstMove(e.target.value);
    }

    function resetGame(e) {
        e.preventDefault();
        const item = piece.map(() => null);
        setPiece(item);
        if (firstMove === 'computer') {
            computerMove(-1, item, playPiece);
        }
    }

    return (
        <div id="center">
            <div>
                <DecideFirstMove resetGame={resetGame} firstMove={firstMove} changePlayer={changePlayer} />
                <Board currentMove={currentMove} item={piece} playItem={playPiece}/>
            </div>
            <div id="statsContainer">
                <h1>Statistics</h1>
                <div id="stats">
                    <span>Games Played:</span><span>{gamesTotal}</span>
                    <span>Computer Won:</span><span>{compWon}</span>
                    <span>Player Won:</span><span>{playerWon}</span>
                </div>
            </div>
        </div>
    );
}

function DecideFirstMove({ resetGame, firstMove, changePlayer }) {
    return (
        <form>
            <label>
                <input type="radio" name="firstMove" value="player" checked={firstMove === 'player'} onChange={changePlayer} />
                Player
            </label>
            <label>
                <input type="radio" name="firstMove" value="computer" checked={firstMove === 'computer'} onChange={changePlayer} />
                Computer
            </label>
            <button type="submit" id="resetButton" onClick={resetGame}>Reset Game</button>
        </form>
    );
}

function Board({currentMove, item, playItem}) {
    function handleClick(i) {
        if (item[i] || isWinner(item)) {
            return;
        }
        const piece = item.slice();
        piece[i] = 'X';
        playItem(piece);
        if (!isWinner(piece)) {
            computerMove(i, piece, playItem);
        }
    }

    return (
        <div id="grid">
            <MakeButton value={item[0]} onSquareClick={() => handleClick(0)}/>
            <MakeButton value={item[1]} onSquareClick={() => handleClick(1)} />
            <MakeButton value={item[2]} onSquareClick={() => handleClick(2)} />
            <MakeButton value={item[3]} onSquareClick={() => handleClick(3)} />
            <MakeButton value={item[4]} onSquareClick={() => handleClick(4)} />
            <MakeButton value={item[5]} onSquareClick={() => handleClick(5)} />
            <MakeButton value={item[6]} onSquareClick={() => handleClick(6)} />
            <MakeButton value={item[7]} onSquareClick={() => handleClick(7)} />
            <MakeButton value={item[8]} onSquareClick={() => handleClick(8)} />
        </div>
    );
}

function MakeButton({value, onSquareClick}) {
    return (
        <button onClick={onSquareClick}>
            {value}
        </button>
    );
}

function computerMove(currentMove, item, playItem) {
    const piece = item.slice();
    let didMove = false;
    // if first move, move randomly
    if (currentMove === -1) {
        const move = movePiece(piece, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
        piece[move] = 'O';
        didMove = true;
    }
    // see if computer can win in the next move
    else if (willWin(piece, 'O') !== null) {
        piece[willWin(piece, 'O')] = 'O';
        didMove = true;
    }
    // see if player can win in the next move and block them
    else if (willWin(piece, 'X') !== null) {
        piece[willWin(piece, 'X')] = 'O';
        didMove = true;
    }
    // if the move is in the center
    else if (currentMove === 4) {
        const move = movePiece(piece, [0, 2, 6, 8]);
        if (move !== null) {
            piece[move] = 'O';
            didMove = true;
        }
    }
    // move in the opposite corner if available
    else if (currentMove === 0 || currentMove === 2 || currentMove === 6 || currentMove === 8) {
        if (movePiece(piece, [8 - currentMove]) !== null) {
            piece[8 - currentMove] = 'O';
        didMove = true;
        }
        else {
            const move = movePiece(piece, [0, 2, 6, 8]);
            if (move !== null) {
                piece[move] = 'O';
                didMove = true;
            }
        }
    }
    // try a corner if available
    else if (movePiece(piece, [0, 2, 6, 8]) !== null) {
        const move = movePiece(piece, [0, 2, 6, 8]);
        piece[move] = 'O';
        didMove = true;
    }
    // move in the center if available
    else if (piece[4] === null) {
        piece[4] = 'O';
        didMove = true;
    }
    // move in the opposite corner if available
    else if (currentMove === 1 || currentMove === 3 || currentMove === 5 || currentMove === 7) {
        const move = movePiece(piece, [1, 3, 5, 7]);
        if (move !== null) {
            piece[move] = 'O';
            didMove = true;
        }
    }
    // move randomly
    if (!didMove) {
        const move = movePiece(piece, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
        piece[move] = 'O';
    }
    playItem(piece);
}

function movePiece(item, possibleMoves) {
    const availableMoves = possibleMoves.sort(() => Math.random() - 0.5);
    for (let i = 0; i < availableMoves.length; i++) {
        const piece = item.slice();
        if (!piece[availableMoves[i]]) {
            piece[availableMoves[i]] = 'O';
            return availableMoves[i];
        }
    }
    return null;
}

function willWin(item, player) {
    for (let i = 0; i < item.length; i++) {
        const piece = item.slice();
        if (!piece[i]) {
            piece[i] = player;
            if (isWinner(piece) == player) {
                return i;
            }
        }
    }
    return null;
}

function isWinner(item) {
  const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];
  for (let i = 0; i < lines.length; i++) {
    const [a, b, c] = lines[i];
    if (item[a] && item[a] === item[b] && item[a] === item[c]) {
      return item[a];
    }
  }
  return null;
}

export default Game;
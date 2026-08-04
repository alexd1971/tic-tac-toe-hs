module TicTacToe
  ( CellIndex
  , Depth
  , Score
  , Board
  , BoardState (..)
  , Difficulty (..)
  , Game
  , GameError (..)
  , Mark (..)
  , Player (..)
  , PlayerKind (..)
  , bestMove
  , board
  , clear
  , currentPlayer
  , emptyCells
  , gameState
  , isFull
  , isInBounds
  , makeMove
  , markAt
  , newBoard
  , newGame
  , other
  , setMark
  , winner
  , withPlayers
  )
where

import TicTacToe.Board
import TicTacToe.Game
import TicTacToe.Game.AI
import TicTacToe.Game.Difficulty
import TicTacToe.Game.Error
import TicTacToe.Game.Player
import TicTacToe.Mark

type CellIndex = Int

type Depth = Int

type Score = Int

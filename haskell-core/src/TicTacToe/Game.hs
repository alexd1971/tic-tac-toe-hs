module TicTacToe.Game
  ( Game
  , board
  , currentPlayer
  , makeMove
  , newGame
  , winner
  , withPlayers
  )
where

import TicTacToe.Board
import TicTacToe.Game.Error
import TicTacToe.Game.Player
import TicTacToe.Mark

data Game = Game
  { players :: (Player, Player)
  , board :: Board
  , currentPlayerIndex :: Int
  }
  deriving stock (Eq, Show)

newGame :: Game
newGame = withPlayers (Player X Human) (Player O AI)

withPlayers :: Player -> Player -> Game
withPlayers xPlayer oPlayer
  | playerMark xPlayer /= X = error "X player must use X mark"
  | playerMark oPlayer /= O = error "O player must use O mark"
  | otherwise = Game {players = (xPlayer, oPlayer), board = newBoard, currentPlayerIndex = 0}

currentPlayer :: Game -> Player
currentPlayer game =
  case currentPlayerIndex game of
    0 -> fst (players game)
    _ -> snd (players game)

winner :: Game -> Maybe Mark
winner game =
  case gameState (board game) of
    Win mark -> Just mark
    _ -> Nothing

makeMove :: Int -> Game -> Either GameError Game
makeMove index game
  | gameState (board game) /= InProgress = Left GameOver
  | not (isInBounds (board game) index) = Left OutOfBounds
  | markAt (board game) index /= Nothing = Left Occupied
  | otherwise =
      case setMark index (Just (playerMark (currentPlayer game))) (board game) of
        Nothing -> Left OutOfBounds
        Just nextBoard -> Right game {board = nextBoard, currentPlayerIndex = currentPlayerIndex game `xorTurn` 1}

xorTurn :: Int -> Int -> Int
xorTurn 0 _ = 1
xorTurn _ _ = 0

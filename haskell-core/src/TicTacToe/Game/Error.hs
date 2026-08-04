module TicTacToe.Game.Error
  ( GameError (..)
  )
where

data GameError
  = OutOfBounds
  | Occupied
  | GameOver
  deriving stock (Eq, Show)

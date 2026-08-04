module TicTacToe.Game.Player
  ( Player (..)
  , PlayerKind (..)
  )
where

import TicTacToe.Mark (Mark)

data PlayerKind = Human | AI
  deriving stock (Eq, Show)

data Player = Player
  { playerMark :: Mark
  , playerKind :: PlayerKind
  }
  deriving stock (Eq, Show)

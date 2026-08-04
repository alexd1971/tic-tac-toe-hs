module TicTacToe.Mark
  ( Mark (..)
  , other
  )
where

data Mark = X | O
  deriving stock (Eq, Show)

other :: Mark -> Mark
other X = O
other O = X

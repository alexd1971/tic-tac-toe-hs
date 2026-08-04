module TicTacToe.Game.Difficulty
  ( Difficulty (..)
  , Heuristics (..)
  , depth
  , easyHeuristics
  , hardHeuristics
  , heuristics
  , mediumHeuristics
  )
where

data Difficulty = Easy | Medium | Hard
  deriving stock (Eq, Show)

data Heuristics = Heuristics
  { winScore :: Int
  , lineTwoScore :: Int
  , lineOneScore :: Int
  , centerScore :: Int
  , cornerScore :: Int
  }
  deriving stock (Eq, Show)

hardHeuristics :: Heuristics
hardHeuristics =
  Heuristics
    { winScore = 10000
    , lineTwoScore = 100
    , lineOneScore = 10
    , centerScore = 3
    , cornerScore = 1
    }

mediumHeuristics :: Heuristics
mediumHeuristics = hardHeuristics

easyHeuristics :: Heuristics
easyHeuristics =
  Heuristics
    { winScore = 10000
    , lineTwoScore = 10
    , lineOneScore = 1
    , centerScore = 0
    , cornerScore = 0
    }

heuristics :: Difficulty -> Heuristics
heuristics Easy = easyHeuristics
heuristics Medium = mediumHeuristics
heuristics Hard = hardHeuristics

depth :: Difficulty -> Int
depth Easy = 1
depth Medium = 3
depth Hard = 9

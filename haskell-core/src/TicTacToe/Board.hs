module TicTacToe.Board
  ( Board
  , BoardState (..)
  , clear
  , emptyCells
  , gameState
  , isFull
  , isInBounds
  , markAt
  , newBoard
  , setMark
  , winningLines
  )
where

import TicTacToe.Mark (Mark)

data BoardState = Win Mark | Draw | InProgress
  deriving stock (Eq, Show)

newtype Board = Board [Maybe Mark]
  deriving stock (Eq, Show)

newBoard :: Board
newBoard = Board (replicate boardSize Nothing)

markAt :: Board -> Int -> Maybe Mark
markAt (Board cells) index
  | isInBoundsIndex index = cells !! index
  | otherwise = Nothing

setMark :: Int -> Maybe Mark -> Board -> Maybe Board
setMark index value (Board cells)
  | isInBoundsIndex index = Just (Board (take index cells <> [value] <> drop (index + 1) cells))
  | otherwise = Nothing

isInBounds :: Board -> Int -> Bool
isInBounds _ = isInBoundsIndex

isFull :: Board -> Bool
isFull (Board cells) = all isMarked cells
 where
  isMarked Nothing = False
  isMarked (Just _) = True

clear :: Board -> Board
clear _ = newBoard

emptyCells :: Board -> [Int]
emptyCells (Board cells) = [index | (index, Nothing) <- zip [0 ..] cells]

winningLines :: Board -> [[Maybe Mark]]
winningLines (Board cells) =
  [ line 0 1 2
  , line 3 4 5
  , line 6 7 8
  , line 0 3 6
  , line 1 4 7
  , line 2 5 8
  , line 0 4 8
  , line 2 4 6
  ]
 where
  line a b c = [cells !! a, cells !! b, cells !! c]

gameState :: Board -> BoardState
gameState board =
  case winners of
    winner : _ -> Win winner
    [] | isFull board -> Draw
    [] -> InProgress
 where
  winners =
    [ mark
    | [Just mark, second, third] <- winningLines board
    , second == Just mark
    , third == Just mark
    ]

boardSize :: Int
boardSize = 9

isInBoundsIndex :: Int -> Bool
isInBoundsIndex index = index >= 0 && index < boardSize

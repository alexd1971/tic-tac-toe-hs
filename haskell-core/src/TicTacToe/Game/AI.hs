module TicTacToe.Game.AI
  ( bestMove
  )
where

import Data.List (maximumBy, minimumBy)
import Data.Ord (comparing)
import TicTacToe.Board
import TicTacToe.Game.Difficulty
import TicTacToe.Mark

bestMove :: Board -> Mark -> Difficulty -> Maybe Int
bestMove board aiMark difficulty
  | gameState board /= InProgress = Nothing
  | difficulty == Medium && length (emptyCells board) == 8 && any isXEdge [1, 3, 5, 7] = Just 0
  | otherwise = snd (minimax board aiMark (depth difficulty) (heuristics difficulty))
 where
  isXEdge index = markAt board index == Just X

minimax :: Board -> Mark -> Int -> Heuristics -> (Int, Maybe Int)
minimax board currentMark remainingDepth weights
  | remainingDepth == 0 || gameState board /= InProgress = (evaluate board weights, Nothing)
  | otherwise =
      let scoredMoves =
            [ (score, move)
            | move <- emptyCells board
            , Just nextBoard <- [setMark move (Just currentMark) board]
            , let (score, _) = minimax nextBoard (other currentMark) (remainingDepth - 1) weights
            ]
       in case scoredMoves of
            [] -> (evaluate board weights, Nothing)
            _ ->
              let choose = if currentMark == X then maximumBy else minimumBy
                  (score, move) = choose (comparing fst) scoredMoves
               in (score, Just move)

evaluate :: Board -> Heuristics -> Int
evaluate board weights =
  case gameState board of
    Win X -> winScore weights
    Win O -> negate (winScore weights)
    Draw -> 0
    InProgress -> lineScore board weights + centerScoreFor board weights + cornerScoreFor board weights

lineScore :: Board -> Heuristics -> Int
lineScore board weights = sum (map scoreLine (winningLines board))
 where
  scoreLine line =
    let xCount = length [() | Just X <- line]
        oCount = length [() | Just O <- line]
     in case (xCount, oCount) of
          (_, _) | xCount > 0 && oCount > 0 -> 0
          (2, 0) -> lineTwoScore weights
          (1, 0) -> lineOneScore weights
          (0, 2) -> negate (lineTwoScore weights)
          (0, 1) -> negate (lineOneScore weights)
          _ -> 0

centerScoreFor :: Board -> Heuristics -> Int
centerScoreFor board weights =
  case markAt board 4 of
    Just X -> centerScore weights
    Just O -> negate (centerScore weights)
    Nothing -> 0

cornerScoreFor :: Board -> Heuristics -> Int
cornerScoreFor board weights =
  sum [score index | index <- [0, 2, 6, 8]]
 where
  score index =
    case markAt board index of
      Just X -> cornerScore weights
      Just O -> negate (cornerScore weights)
      Nothing -> 0

module Main (main) where

import TicTacToe

main :: IO ()
main = do
  assert "new board is empty" (all ((== Nothing) . markAt newBoard) [0 .. 8])
  assert "set and read mark" (markAt (mustSet 4 (Just X) newBoard) 4 == Just X)
  assert "out-of-bounds read is empty" (markAt newBoard 9 == Nothing)
  assert "empty board cells" (emptyCells newBoard == [0 .. 8])
  assert "winning row" (gameState (boardWith [(0, X), (1, X), (2, X)]) == Win X)
  assert "draw board" (gameState drawBoard == Draw)
  assert "immediate winning move" (bestMove (boardWith [(0, X), (1, X), (4, O)]) X Easy == Just 2)
  assert "O blocks forced loss" (bestMove (boardWith [(0, X), (1, X), (4, O)]) O Medium == Just 2)
  assert "hard self-play draw" (hardSelfPlay == Draw)

assert :: String -> Bool -> IO ()
assert label condition =
  if condition
    then pure ()
    else fail ("test failed: " <> label)

mustSet :: Int -> Maybe Mark -> Board -> Board
mustSet index value board =
  case setMark index value board of
    Just next -> next
    Nothing -> error "test setup used invalid board index"

boardWith :: [(Int, Mark)] -> Board
boardWith = foldl (\board (index, mark) -> mustSet index (Just mark) board) newBoard

drawBoard :: Board
drawBoard =
  boardWith
    [ (0, X), (1, O), (2, X)
    , (3, O), (4, X), (5, O)
    , (6, O), (7, X), (8, O)
    ]

hardSelfPlay :: BoardState
hardSelfPlay = go newBoard X
 where
  go board mark =
    case gameState board of
      InProgress ->
        case bestMove board mark Hard of
          Just move -> go (mustSet move (Just mark) board) (other mark)
          Nothing -> gameState board
      state -> state

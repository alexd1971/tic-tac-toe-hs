module Main (main) where

import Control.Monad (when)
import Data.Char (toUpper)
import System.IO (hFlush, stdout)
import TicTacToe

main :: IO ()
main = play

play :: IO ()
play = do
  putStrLn "=== Tic-Tac-Toe ==="
  difficulty <- chooseDifficulty
  humanMark <- chooseMark
  let game =
        case humanMark of
          X -> withPlayers (Player X Human) (Player O AI)
          O -> withPlayers (Player X AI) (Player O Human)
  gameLoop difficulty humanMark game

gameLoop :: Difficulty -> Mark -> Game -> IO ()
gameLoop difficulty humanMark game = do
  putStrLn ""
  printBoard (board game)
  case gameState (board game) of
    Win mark -> putStrLn ("\n" <> if mark == humanMark then "You win!" else "AI wins!")
    Draw -> putStrLn "\nDraw!"
    InProgress ->
      if playerKind (currentPlayer game) == Human
        then do
          move <- getHumanMove (board game)
          either (fail . show) (gameLoop difficulty humanMark) (makeMove move game)
        else do
          putStrLn "AI is thinking..."
          case bestMove (board game) (playerMark (currentPlayer game)) difficulty of
            Nothing -> fail "AI should have a move"
            Just move -> either (fail . show) (gameLoop difficulty humanMark) (makeMove move game)

printBoard :: Board -> IO ()
printBoard board = do
  mapM_ printRow [0 .. 2]
 where
  printRow row = do
    when (row > 0) (putStrLn "---+---+---")
    mapM_ (printCell row) [0 .. 2]
    putStrLn ""
  printCell row col = do
    when (col > 0) (putStr "|")
    let index = row * 3 + col
    putStr $
      case markAt board index of
        Just X -> " X "
        Just O -> " O "
        Nothing -> " " <> show index <> " "

chooseDifficulty :: IO Difficulty
chooseDifficulty = do
  input <- readLine "Choose difficulty (1 = Easy, 2 = Medium, 3 = Hard): "
  case input of
    "1" -> pure Easy
    "2" -> pure Medium
    "3" -> pure Hard
    _ -> putStrLn "Invalid choice. Try again." *> chooseDifficulty

chooseMark :: IO Mark
chooseMark = do
  input <- map toUpper <$> readLine "Choose your mark (X goes first, O goes second): "
  case input of
    "X" -> pure X
    "O" -> pure O
    _ -> putStrLn "Invalid choice. Enter X or O." *> chooseMark

getHumanMove :: Board -> IO Int
getHumanMove board = do
  input <- readLine "Your move (0-8): "
  case reads input of
    [(index, "")] | isInBounds board index && markAt board index == Nothing -> pure index
    _ -> putStrLn "Invalid move. Try again." *> getHumanMove board

readLine :: String -> IO String
readLine prompt = do
  putStr prompt
  hFlush stdout
  input <- getLine
  let trimmed = trim input
  if null trimmed then readLine prompt else pure trimmed

trim :: String -> String
trim = reverse . dropWhile (== ' ') . reverse . dropWhile (== ' ')

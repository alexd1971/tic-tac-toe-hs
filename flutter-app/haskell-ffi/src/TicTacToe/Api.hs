module TicTacToe.Api
  ( GameHandle
  , bestMove
  , cellAt
  , currentPlayer
  , freeGame
  , gameState
  , makeMove
  , newGame
  )
where

import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import Foreign.C.Types (CInt)
import Foreign.StablePtr (StablePtr, deRefStablePtr, freeStablePtr, newStablePtr)
import TicTacToe
  ( BoardState (..)
  , Difficulty (..)
  , Game
  , GameError (..)
  , Mark (..)
  , Player (..)
  , PlayerKind (..)
  )
import qualified TicTacToe as Core

type GameHandle = IORef Game

newGame :: CInt -> IO (StablePtr GameHandle)
newGame humanMarkCode =
  newStablePtr
    =<< newIORef
      ( case decodeMark humanMarkCode of
          O -> Core.withPlayers (Player X AI) (Player O Human)
          X -> Core.withPlayers (Player X Human) (Player O AI)
      )

freeGame :: StablePtr GameHandle -> IO ()
freeGame = freeStablePtr

currentPlayer :: StablePtr GameHandle -> IO CInt
currentPlayer gamePtr = do
  game <- readGame gamePtr
  pure (encodeMark (Core.playerMark (Core.currentPlayer game)))

cellAt :: StablePtr GameHandle -> CInt -> IO CInt
cellAt gamePtr index = do
  game <- readGame gamePtr
  pure (maybe 0 encodeMark (Core.markAt (Core.board game) (fromIntegral index)))

gameState :: StablePtr GameHandle -> IO CInt
gameState gamePtr = do
  game <- readGame gamePtr
  pure (encodeBoardState (Core.gameState (Core.board game)))

makeMove :: StablePtr GameHandle -> CInt -> IO CInt
makeMove gamePtr index = do
  gameRef <- deRefStablePtr gamePtr
  game <- readIORef gameRef
  case Core.makeMove (fromIntegral index) game of
    Left err -> pure (encodeGameError err)
    Right nextGame -> do
      writeIORef gameRef nextGame
      pure 0

bestMove :: StablePtr GameHandle -> CInt -> IO CInt
bestMove gamePtr difficultyCode = do
  game <- readGame gamePtr
  let mark = Core.playerMark (Core.currentPlayer game)
      difficulty = decodeDifficulty difficultyCode
  pure $
    case Core.bestMove (Core.board game) mark difficulty of
      Nothing -> -1
      Just index -> fromIntegral index

readGame :: StablePtr GameHandle -> IO Game
readGame gamePtr = readIORef =<< deRefStablePtr gamePtr

decodeMark :: CInt -> Mark
decodeMark 2 = O
decodeMark _ = X

encodeMark :: Mark -> CInt
encodeMark X = 1
encodeMark O = 2

decodeDifficulty :: CInt -> Difficulty
decodeDifficulty 1 = Easy
decodeDifficulty 2 = Medium
decodeDifficulty _ = Hard

encodeBoardState :: BoardState -> CInt
encodeBoardState InProgress = 0
encodeBoardState Draw = 1
encodeBoardState (Win X) = 2
encodeBoardState (Win O) = 3

encodeGameError :: GameError -> CInt
encodeGameError OutOfBounds = 1
encodeGameError Occupied = 2
encodeGameError GameOver = 3

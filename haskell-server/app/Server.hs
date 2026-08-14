module Server
  ( GameStore
  , application
  , emptyGameStore
  )
where

import Control.Concurrent.STM (TVar, atomically, modifyTVar', readTVar, stateTVar)
import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString.Lazy.Char8 as LBS
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe)
import Network.Wai (Application)
import Network.Wai.Middleware.Cors
  ( CorsResourcePolicy (..)
  , cors
  , simpleCorsResourcePolicy
  )
import Servant
  ( Handler
  , NoContent (..)
  , Proxy (..)
  , Server
  , ServerError (errBody)
  , err404
  , serve
  , throwError
  , type (:<|>) (..)
  )
import Servant.Server.StaticFiles (serveDirectoryWith)
import System.FilePath ((</>))
import TicTacToe
  ( Game
  , Mark (..)
  , Player (..)
  , PlayerKind (..)
  )
import qualified TicTacToe as Core
import WaiAppStatic.Storage.Filesystem (defaultWebAppSettings)
import Server.Types
  ( API
  , BestMoveRequest (..)
  , BestMoveResponse (..)
  , ErrorResponse (..)
  , GameAPI
  , IntResponse (..)
  , MoveRequest (..)
  , NewGameRequest (..)
  , NewGameResponse (..)
  , decodeDifficulty
  , decodeMark
  , encodeBoardState
  , encodeGameError
  , encodeMark
  )

data GameStore = GameStore
  { nextGameId :: Int
  , games :: Map Int Game
  }

emptyGameStore :: GameStore
emptyGameStore = GameStore 1 Map.empty

application :: FilePath -> TVar GameStore -> Application
application staticDir store =
  cors (const (Just corsPolicy)) (serve (Proxy :: Proxy API) (server staticDir store))

corsPolicy :: CorsResourcePolicy
corsPolicy =
  simpleCorsResourcePolicy
    { corsMethods = ["GET", "POST", "DELETE", "OPTIONS"]
    , corsRequestHeaders = ["Content-Type"]
    }

server :: FilePath -> TVar GameStore -> Server API
server staticDir store =
  apiServer store
    :<|> indexHandler staticDir
    :<|> serveDirectoryWith (defaultWebAppSettings staticDir)

indexHandler :: FilePath -> Handler LBS.ByteString
indexHandler staticDir =
  liftIO (LBS.readFile (staticDir </> "index.html"))

apiServer :: TVar GameStore -> Server GameAPI
apiServer store =
  newGameHandler
    :<|> freeGameHandler
    :<|> currentPlayerHandler
    :<|> cellAtHandler
    :<|> gameStateHandler
    :<|> makeMoveHandler
    :<|> bestMoveHandler
 where
  newGameHandler :: NewGameRequest -> Handler NewGameResponse
  newGameHandler request = liftIO . atomically $ do
    gameId <- stateTVar store $ \gameStore ->
      let newId = nextGameId gameStore
          game = initialGame (humanMark request)
       in ( newId
          , gameStore
              { nextGameId = newId + 1
              , games = Map.insert newId game (games gameStore)
              }
          )
    pure (NewGameResponse gameId)

  freeGameHandler :: Int -> Handler NoContent
  freeGameHandler gameId = do
    liftIO . atomically $
      modifyTVar' store $ \gameStore ->
        gameStore {games = Map.delete gameId (games gameStore)}
    pure NoContent

  currentPlayerHandler :: Int -> Handler IntResponse
  currentPlayerHandler gameId = do
    game <- lookupGame store gameId
    pure . IntResponse . encodeMark . Core.playerMark $ Core.currentPlayer game

  cellAtHandler :: Int -> Int -> Handler IntResponse
  cellAtHandler gameId index = do
    game <- lookupGame store gameId
    pure . IntResponse . maybe 0 encodeMark $
      Core.markAt (Core.board game) index

  gameStateHandler :: Int -> Handler IntResponse
  gameStateHandler gameId = do
    game <- lookupGame store gameId
    pure . IntResponse . encodeBoardState $ Core.gameState (Core.board game)

  makeMoveHandler :: Int -> MoveRequest -> Handler ErrorResponse
  makeMoveHandler gameId (MoveRequest moveIndex) =
    liftIO . atomically $ do
      gameStore <- readTVar store
      case Map.lookup gameId (games gameStore) of
        Nothing -> pure (ErrorResponse 1)
        Just game ->
          case Core.makeMove moveIndex game of
            Left err -> pure (ErrorResponse (encodeGameError err))
            Right nextGame -> do
              modifyTVar' store $ \currentStore ->
                currentStore {games = Map.insert gameId nextGame (games currentStore)}
              pure (ErrorResponse 0)

  bestMoveHandler :: Int -> BestMoveRequest -> Handler BestMoveResponse
  bestMoveHandler gameId request = do
    game <- lookupGame store gameId
    let mark = Core.playerMark (Core.currentPlayer game)
        move = Core.bestMove (Core.board game) mark (decodeDifficulty (difficulty request))
    pure . BestMoveResponse $ fromMaybe (-1) move

lookupGame :: TVar GameStore -> Int -> Handler Game
lookupGame store gameId = do
  maybeGame <- liftIO . atomically $ Map.lookup gameId . games <$> readTVar store
  case maybeGame of
    Just game -> pure game
    Nothing ->
      throwError $
        err404
          { errBody = LBS.pack ("Unknown game id: " <> show gameId)
          }

initialGame :: Int -> Game
initialGame humanMarkCode =
  case decodeMark humanMarkCode of
    O -> Core.withPlayers (Player X AI) (Player O Human)
    X -> Core.withPlayers (Player X Human) (Player O AI)

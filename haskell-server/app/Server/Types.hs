module Server.Types
  ( API
  , GameAPI
  , HTML
  , BestMoveRequest (..)
  , BestMoveResponse (..)
  , ErrorResponse (..)
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
where

import Data.Aeson (FromJSON, ToJSON)
import qualified Data.ByteString.Lazy as LBS
import GHC.Generics (Generic)
import Network.HTTP.Media ((//), (/:))
import Servant
  ( Accept (..)
  , Capture
  , DeleteNoContent
  , Get
  , JSON
  , MimeRender (..)
  , Post
  , Raw
  , ReqBody
  , type (:<|>)
  , type (:>)
  )
import TicTacToe
  ( BoardState (..)
  , Difficulty (..)
  , GameError (..)
  , Mark (..)
  )

type API =
  "api" :> GameAPI
    :<|> Get '[HTML] LBS.ByteString
    :<|> Raw

type GameAPI =
  "games"
    :> ReqBody '[JSON] NewGameRequest
    :> Post '[JSON] NewGameResponse
    :<|> "games"
      :> Capture "gameId" Int
      :> DeleteNoContent
    :<|> "games"
      :> Capture "gameId" Int
      :> "current-player"
      :> Get '[JSON] IntResponse
    :<|> "games"
      :> Capture "gameId" Int
      :> "cells"
      :> Capture "index" Int
      :> Get '[JSON] IntResponse
    :<|> "games"
      :> Capture "gameId" Int
      :> "state"
      :> Get '[JSON] IntResponse
    :<|> "games"
      :> Capture "gameId" Int
      :> "moves"
      :> ReqBody '[JSON] MoveRequest
      :> Post '[JSON] ErrorResponse
    :<|> "games"
      :> Capture "gameId" Int
      :> "best-move"
      :> ReqBody '[JSON] BestMoveRequest
      :> Post '[JSON] BestMoveResponse

newtype NewGameRequest = NewGameRequest
  { humanMark :: Int
  }
  deriving stock (Generic, Show)

instance FromJSON NewGameRequest

newtype NewGameResponse = NewGameResponse
  { gameId :: Int
  }
  deriving stock (Generic, Show)

instance ToJSON NewGameResponse

newtype IntResponse = IntResponse
  { value :: Int
  }
  deriving stock (Generic, Show)

instance ToJSON IntResponse

newtype MoveRequest = MoveRequest
  { index :: Int
  }
  deriving stock (Generic, Show)

instance FromJSON MoveRequest

newtype ErrorResponse = ErrorResponse
  { errorCode :: Int
  }
  deriving stock (Generic, Show)

instance ToJSON ErrorResponse

newtype BestMoveRequest = BestMoveRequest
  { difficulty :: Int
  }
  deriving stock (Generic, Show)

instance FromJSON BestMoveRequest

newtype BestMoveResponse = BestMoveResponse
  { index :: Int
  }
  deriving stock (Generic, Show)

instance ToJSON BestMoveResponse

data HTML

instance Accept HTML where
  contentType _ = "text" // "html" /: ("charset", "utf-8")

instance MimeRender HTML LBS.ByteString where
  mimeRender _ = id

decodeMark :: Int -> Mark
decodeMark 2 = O
decodeMark _ = X

encodeMark :: Mark -> Int
encodeMark X = 1
encodeMark O = 2

decodeDifficulty :: Int -> Difficulty
decodeDifficulty 1 = Easy
decodeDifficulty 2 = Medium
decodeDifficulty _ = Hard

encodeBoardState :: BoardState -> Int
encodeBoardState InProgress = 0
encodeBoardState Draw = 1
encodeBoardState (Win X) = 2
encodeBoardState (Win O) = 3

encodeGameError :: GameError -> Int
encodeGameError OutOfBounds = 1
encodeGameError Occupied = 2
encodeGameError GameOver = 3

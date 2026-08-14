module Main (main) where

import Control.Concurrent.STM (newTVarIO)
import Network.Wai.Handler.Warp (run)
import Server (application, emptyGameStore)
import System.Directory (doesFileExist, getCurrentDirectory, makeAbsolute)
import System.Environment (lookupEnv)
import System.FilePath ((</>))
import Text.Read (readMaybe)

main :: IO ()
main = do
  port <- maybe 8081 (maybe 8081 id . readMaybe) <$> lookupEnv "PORT"
  staticDir <-
    maybe "flutter-gui/flutter-app/build/web" id
      <$> lookupEnv "STATIC_DIR"
  currentDir <- getCurrentDirectory
  staticDirAbsolute <- makeAbsolute staticDir
  indexExists <- doesFileExist (staticDirAbsolute </> "index.html")
  if indexExists
    then pure ()
    else
      fail $
        "Could not find Flutter web index.html in "
          <> staticDirAbsolute
          <> "\nCurrent directory: "
          <> currentDir
          <> "\nSet STATIC_DIR to the Flutter build/web directory."
  store <- newTVarIO emptyGameStore
  putStrLn ("tic-tac-toe-server listening on http://127.0.0.1:" <> show port)
  putStrLn ("serving Flutter static files from " <> staticDirAbsolute)
  run port (application staticDirAbsolute store)

module TicTacToe.FFI where

import Foreign.C.Types (CInt (..))
import qualified TicTacToe.Api as Api

import Bridge.FFI.TH

$( deriveForeignExports
    [ foreignExport "tic_tac_toe_new_game" 'Api.newGame
    , foreignExport "tic_tac_toe_free_game" 'Api.freeGame
    , foreignExport "tic_tac_toe_current_player" 'Api.currentPlayer
    , foreignExport "tic_tac_toe_cell_at" 'Api.cellAt
    , foreignExport "tic_tac_toe_game_state" 'Api.gameState
    , foreignExport "tic_tac_toe_make_move" 'Api.makeMove
    , foreignExport "tic_tac_toe_best_move" 'Api.bestMove
    ]
 )

# The Flutter tooling requires CMake 3.10 or later.
cmake_minimum_required(VERSION 3.10)

project(tic_tac_toe_bridge LANGUAGES CXX)

file(GLOB tic_tac_toe_bridge_haskell_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/lib/*.so*"
)

set(tic_tac_toe_bridge_bundled_libraries
  ${tic_tac_toe_bridge_haskell_libraries}
  PARENT_SCOPE
)

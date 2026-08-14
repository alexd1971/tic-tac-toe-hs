{ aeson
, base
, bytestring
, containers
, directory
, filepath
, http-media
, lib
, servant
, servant-server
, stm
, tic-tac-toe-core
, wai
, wai-app-static
, wai-cors
, warp
, mkDerivation
}:
mkDerivation {
  pname = "tic-tac-toe-server";
  version = "0.1.0.0";
  src = ../..;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson
    base
    bytestring
    containers
    directory
    filepath
    http-media
    servant
    servant-server
    stm
    tic-tac-toe-core
    wai
    wai-app-static
    wai-cors
    warp
  ];
  license = lib.meta.getLicenseFromSpdxId "BSD-3-Clause";
  mainProgram = "tic-tac-toe-server";
}

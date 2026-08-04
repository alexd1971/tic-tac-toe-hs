{ mkDerivation, base, lib, tic-tac-toe-core }:
mkDerivation {
  pname = "tic-tac-toe-cli";
  version = "0.1.0.0";
  src = ../..;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base tic-tac-toe-core ];
  license = lib.licenses.mit;
}

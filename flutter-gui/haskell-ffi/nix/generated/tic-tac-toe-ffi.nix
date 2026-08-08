{ mkDerivation, base, haskell-ffi-th, lib, tic-tac-toe-core }:
mkDerivation {
  pname = "tic-tac-toe-ffi";
  version = "0.1.0.0";
  src = ../..;
  libraryHaskellDepends = [ base haskell-ffi-th tic-tac-toe-core ];
  license = lib.meta.getLicenseFromSpdxId "MIT";
}

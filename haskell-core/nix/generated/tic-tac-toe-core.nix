{ mkDerivation, base, lib }:
mkDerivation {
  pname = "tic-tac-toe-core";
  version = "0.1.0.0";
  src = ../..;
  libraryHaskellDepends = [ base ];
  testHaskellDepends = [ base ];
  license = lib.meta.getLicenseFromSpdxId "MIT";
}

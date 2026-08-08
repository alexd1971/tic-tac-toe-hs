{
  localHaskellPackages = {
    tic-tac-toe-core = {
      packageFile = ../haskell-core/nix/generated/tic-tac-toe-core.nix;
    };
  };

  regeneratePackages = [
    {
      packageDir = "../haskell-core";
      outputFile = "tic-tac-toe-core.nix";
    }
    {
      packageDir = "haskell-ffi";
      outputFile = "tic-tac-toe-ffi.nix";
    }
  ];
}

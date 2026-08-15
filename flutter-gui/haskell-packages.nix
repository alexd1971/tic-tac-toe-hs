{
  ffiAdapterPackage = {
    packageDir = "haskell-ffi";
    packageFile = ./haskell-ffi/nix/generated/tic-tac-toe-ffi.nix;
  };

  ffiDependencyPackages = {
    tic-tac-toe-core = {
      packageDir = "../haskell-core";
      packageFile = ../haskell-core/nix/generated/tic-tac-toe-core.nix;
    };
  };
}

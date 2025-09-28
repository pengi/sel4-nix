let
  nixpkgs = import <nixpkgs> { };
  microkit = import ./nix/microkit { inherit nixpkgs; };
in
microkit.doc

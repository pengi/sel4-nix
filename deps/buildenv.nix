{ nixpkgs }:
{
  target.aarch64 = {
    bintools = nixpkgs.pkgsCross.aarch64-embedded.stdenv.cc.bintools;
    cc = nixpkgs.pkgsCross.aarch64-embedded.stdenv.cc;
  };

  inherit (nixpkgs) qemu gnumake curl;

  tools = {
    inherit (nixpkgs) fetchzip;
  };
}

{ nixpkgs, system }:
let

  microkit-version = "2.0.1";
  microkit-platform =
    {
      aarch64-darwin = "macos-aarch64";
      x86_64-darwin = "macos-x86-64";
      x86_64-linux = "linux-x86-64";
      aarch64-linux = "linux-aarch64";
    }
    .${system};
in
nixpkgs.fetchzip {
  url = "https://github.com/seL4/microkit/releases/download/${microkit-version}/microkit-sdk-${microkit-version}-${microkit-platform}.tar.gz";
  name = "microkit-sdk-${microkit-version}-${microkit-platform}";
  hash =
    {
      aarch64-darwin = "sha256-bFFyVBF2E3YDJ6CYbfCOID7KGREQXkIFDpTD4MzxfCE=";
      x86_64-darwin = "sha256-tQWrI5LRp05tLy/HIxgN+0KFJrlmOQ+dpws4Fre+6E0=";
      x86_64-linux = "sha256-YpgIAXWB8v4Njm/5Oo0jZpRt/t+e+rVTwFTJ8zr2Hn4=";
      aarch64-linux = "sha256-GwWDRJalJOpAYCP/qggFOHDh2e2J1LspWUsyjopECYA=";
    }
    .${system};
}

{
  nixpkgs,
  system ? builtins.currentSystem,
}:
let

  microkit-src = nixpkgs.fetchgit {
    url = "https://github.com/seL4/microkit.git";
    rev = "d7da977bab18d206ed071fa4bf8fcd35162f5934";
    hash = "sha256-uwiGZx06uZMNLrWuFlL3xVWca9VnGiDRe1Q3MMEvhEY=";
  };

  sel4-src = nixpkgs.fetchgit {
    url = "https://github.com/seL4/seL4.git";
    rev = "f5e45a24531ad9ed28c56efb8346ab7398895fff";
    hash = "sha256-cWMulMMe1+HFWokmroIZdpvM253P2gxbEWOBj3EDYHU=";
  };

  microkit-tool = nixpkgs.rustPlatform.buildRustPackage rec {
    pname = "microkit-tool";
    version = microkit-version;

    src = microkit-src;
    sourceRoot = "${src.name}/tool/microkit";

    cargoHash = "sha256-LL4SMrm1tXyOPqsT7Tj4xCYKIi2MQYfZbz7zxiFYDkI=";
  };

  board-configs = import ./config.nix {
    inherit nixpkgs;
  };

  microkit-version = "2.0.1-d7da977";
  sel4-version = "sel4-f5e45a2";

  sdk-version = "${microkit-version}-${sel4-version}";

  build-sdk = import ./sdk.nix;

in
{
  sdk = builtins.mapAttrs (
    board: configs:
    builtins.mapAttrs (
      config: attrs:
      build-sdk {
        inherit (nixpkgs.stdenvNoCC) mkDerivation;
        inherit nixpkgs;
        inherit board config attrs;
        inherit microkit-src sel4-src;
        inherit sdk-version;
      }
    ) configs
  ) board-configs;

  doc = nixpkgs.stdenvNoCC.mkDerivation {
    name = "microkit-doc-${sdk-version}";

    buildInputs = with nixpkgs; [
      pandoc
      (texliveSmall.withPackages (
        ps: with ps; [
          collection-latexextra # TODO: slim down a lot
          roboto
        ]
      ))
    ];

    TEXINPUTS = "style:";

    src = microkit-src;

    patchPhase = ''
      patchShebangs .
    '';

    buildPhase = ''
      pushd docs
      pandoc manual.md -o ../microkit_user_manual.pdf
      popd
    '';

    installPhase = ''
      mkdir $out
      cp microkit_user_manual.pdf $out/
    '';

    fixupPhase = ":";
  };

  example = nixpkgs.stdenvNoCC.mkDerivation {
    name = "microkit-example-${sdk-version}";

    buildInputs = [ ];

    src = microkit-src;

    buildPhase = ":";

    installPhase = ''
      cp -r example $out
    '';

    fixupPhase = ":";
  };
}

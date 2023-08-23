{
  description = "Audiobookshelf flake";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";

    alejandra.url = "https://flakehub.com/f/kamadorueda/alejandra/3.0.0.tar.gz";
    nixd.url = "https://flakehub.com/f/nix-community/nixd/1.2.2.tar.gz";
  };

  outputs = {
    self,
    nixpkgs,
    nixd,
    flake-parts,
    alejandra,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        pname = "tone";
        version = "0.1.5";
        description = "tone is a cross platform audio tagger and metadata editor to dump and modify metadata for a wide variety of formats, including mp3, m4b, flac and more. It has no dependencies and can be downloaded as single binary for Windows, macOS, Linux and other common platforms.";

        systemMap = {
          "aarch64-linux" = {
            name = "linux-arm64";
            sha256 = "1jblf0r1m95y9wb3caaj8yfz3xjh7nbmmrq97yifyrk1r6r0c7nm";
          };
          "x86_64-linux" = {
            name = "linux-x64";
            sha256 = "0c1k3xsxrhbdny4kf28gfjnzmrwbrxw3059x41mdv4g9mcjgc4qg";
          };
          "aarch64-darwin" = {
            name = "osx-arm64";
            sha256 = "1fm95bb258129wrmxbs8j8kx28xakdr56x0axj6icn20w5dkzzjz";
          };
          "x86_64-darwin" = {
            name = "osx-x64";
            sha256 = "0wg6zlq7ifjmj87da0xvgxm55zp7z81w37pjin81rwvxbh8y5bxw";
          };
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          inherit pname version description;

          src = builtins.fetchTarball {
            url = "https://github.com/sandreas/tone/releases/download/v${version}/tone-${version}-${systemMap.${system}.name}.tar.gz";
            sha256 = systemMap.${system}.sha256;
          };

          phases = ["unpackPhase" "installPhase"];

          installPhase = ''
            mkdir -p $out/bin
            mv tone $out/bin/tone
          '';

          meta = {
            inherit description;
            license = pkgs.lib.licenses.asl20;
          };
        };

        formatter = inputs.alejandra.packages.${system}.default;

        devShells.default = pkgs.mkShell {
          packages = [
            inputs.nixd.packages.${system}.default
            inputs.alejandra.packages.${system}.default
          ];
        };
      };
    };
}

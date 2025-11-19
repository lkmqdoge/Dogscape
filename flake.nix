{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs lib.systems.flakeExposed;
  in
  {
    devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          deps = [
            pkgs.dotnetCorePackages.dotnet_9.sdk
          ];
        in
        {
          default = pkgs.mkShell{
            nativeBuildInputs = with pkgs; [
              # aot
              nix-ld
            ] ++ deps;

            NIX_LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath ([
              # aot
              stdenv.cc.cc
            ] ++ deps);

            env.LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [
              skia 
              fontconfig
              xorg.libX11
              xorg.libICE
              xorg.libSM
              xorg.libXi
            ] ++ deps );

            NIX_LD = "${pkgs.stdenv.cc.libc_bin}/bin/ld.so";
          };
        }
    );
  };
}

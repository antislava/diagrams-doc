{ pkgs ? import <nixpkgs> { config = { allowBroken = true; }; }
# { pkgs ? import (import ./nix/nixpkgs-src) {}
, compiler ? "default"
, root ? ./.
, name ? "diagrams-doc"
, source-overrides ? {}
, ...
}:
let
  haskellPackages =
    if compiler == "default"
      then pkgs.haskellPackages
      else pkgs.haskell.packages.${compiler};
in
haskellPackages.developPackage {
  root = root;
  name = name;
  source-overrides = {
    docutils = pkgs.fetchFromGitHub {
      owner = "diagrams";
      repo = "docutils";
      rev = "c3179124445ba8e8f2fc80ff735634bd92c999f2";
      sha256 = "1izdjq40km78p4ggzjy3m00r18mbf1nbdisavp4c78g0gpwm3zci";
    };
    diagrams-doc = ./.;
  } // source-overrides;

  overrides = self: super: with pkgs.haskell.lib; {
    # clay = dontCheck super.clay;
    diagrams-builder = doJailbreak super.diagrams-builder;
    docutils = doJailbreak super.docutils;
  };

  modifier = drv: pkgs.haskell.lib.overrideCabal drv (attrs: {
    buildTools = with haskellPackages; (attrs.buildTools or [])
    ++ [cabal-install ghcid pkgs.rst2html5]
    ;
    shellHook = ''
      echo "*Project shell*"
    '';
  });
}


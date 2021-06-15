let
  pkgs = import ./sources.nix;
  getEnvWithDefault = var: defaultValue:
    let envValue = builtins.getEnv var;
    in if envValue != "" then envValue else defaultValue;
in
with pkgs;
mkShell {
  buildInputs = [
    # Elm
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-analyse
    elmPackages.elm-test
    elmPackages.elm-review
    # Nix
    nixfmt
    # Node
    nodejs-16_x
    yarn
  ];
  PORT = getEnvWithDefault "PORT" 3131;
}

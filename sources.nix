let
  pkgs = import (fetchTarball {
    name = "nixpkgs_master_2021_11_02";
    url =
      "https://github.com/NixOS/nixpkgs/archive/57ad6db7c7ba42052795e321b66750c8355d51a6.tar.gz";
    sha256 = "04vkx079rcvdaxlk34csq4vjpbd3wqfnd7qh4a4s24y70napqirf";
  }) { config.allowUnfree = true; };

in pkgs


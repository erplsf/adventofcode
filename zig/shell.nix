{ pkgs ? import (fetchTarball
  "https://github.com/NixOS/nixpkgs/archive/0e304ff0d9db453a4b230e9386418fd974d5804a.tar.gz")
  { } }:

pkgs.mkShell { buildInputs = with pkgs; [ zig zls ]; }

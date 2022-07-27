{ pkgs ? import (fetchTarball
  "https://github.com/NixOS/nixpkgs/archive/5bd14b3cfe2f87a2e2b074645aba39c69563e4bc.tar.gz")
  { } }:

pkgs.mkShell { buildInputs = with pkgs; [ zig ]; }

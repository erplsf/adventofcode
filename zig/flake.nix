{
  description = "Fresh zig development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zig.url = "github:mitchellh/zig-overlay";

    # needed for shell shim: see NixOS Flakes wiki page
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, zig, ... }@inputs: { };
}

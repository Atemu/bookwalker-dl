{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    bash
    cacert
    curl
    jq
  ];
}

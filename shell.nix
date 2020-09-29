{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    unrar
    p7zip
    bzip2
    xz
    libreoffice
    poppler_utils
  ];
}

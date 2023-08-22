with import <nixpkgs> {};

stdenv.mkDerivation {
    name = "hugo";
    buildInputs = [
        hugo
    ];
}

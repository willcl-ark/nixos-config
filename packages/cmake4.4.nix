{
  cmake,
  fetchurl,
  lib,
  runCommand,
}:

let
  cmake4_4 = cmake.overrideAttrs (oldAttrs: {
    version = "4.4.0";
    src = fetchurl {
      url = "https://cmake.org/files/v4.4/cmake-4.4.0.tar.gz";
      hash = "sha256-ZXV/RC/dJC4n8XKPwm3Ay6QWT3oHkaXHiGMcAAgDabw=";
    };
    patches = map (
      patch:
      if baseNameOf (toString patch) == "remove-impure-search-paths.patch" then
        fetchurl {
          url = "https://raw.githubusercontent.com/NixOS/nixpkgs/ec262409d653dd70b1850b32b90a5ed66c7675e8/pkgs/by-name/cm/cmake/remove-impure-search-paths.patch";
          hash = "sha256-gbpMNZFHFmHwaB8w+npCKm0wLscLbtXLIyt8dOW6EeQ=";
        }
      else
        patch
    ) oldAttrs.patches;
  });
in
runCommand "cmake4.4-${cmake4_4.version}"
  {
    meta = cmake4_4.meta // {
      mainProgram = "cmake4.4";
    };
    passthru.cmake = cmake4_4;
  }
  ''
    mkdir -p $out/bin
    ln -s ${lib.getExe cmake4_4} $out/bin/cmake4.4
    ln -s ${lib.getExe' cmake4_4 "ctest"} $out/bin/ctest4.4
  ''

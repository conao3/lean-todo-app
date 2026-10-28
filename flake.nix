{
  description = "Verified Todo backend in Lean 4 with a TanStack Start + React frontend";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.lean4
            pkgs.elan
            pkgs.nodejs_latest
            pkgs.git
          ];

          shellHook = ''
            echo "lean-todo-app dev shell"
            echo "  lean : $(lean --version 2>/dev/null | head -1)"
            echo "  lake : $(lake --version 2>/dev/null | head -1)"
            echo "  node : $(node --version 2>/dev/null)"
          '';
        };
      });
}

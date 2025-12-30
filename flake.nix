{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, rust-overlay, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      overlays = [
        (import rust-overlay)
        (self: super: {
          rustToolchain = super.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "rustfmt"
            ];
          };
        })
      ];
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs systems (system: function (import nixpkgs { inherit system overlays; }));
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          buildInputs = builtins.attrValues {
            inherit (pkgs)
              rustToolchain
              rust-analyzer-unwrapped
              ;
          };
          RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
        };
      });
    };
}

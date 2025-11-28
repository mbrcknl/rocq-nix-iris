{
  description = "A higher-order concurrent separation logic framework with support for interactive proofs";

  inputs = {
    rocq-nix.url = "github:mbrcknl/rocq-nix";

    rocq-nix-stdpp.url = "github:mbrcknl/rocq-nix-stdpp";
    rocq-nix-stdpp.inputs.rocq-nix.follows = "rocq-nix";

    iris.url = "gitlab:iris/iris?host=gitlab.mpi-sws.org";
    iris.flake = false;
  };

  outputs =
    inputs:
    inputs.rocq-nix.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        treefmt.programs.nixfmt.enable = true;

        rocq.dev.sources."iris".input = "iris";

        rocq.versions.default = "9.1.0";
        rocq.versions.supported = {
          "9.0.1" = true;
          "9.1.0" = true;
        };

        rocq.versions.foreach =
          { inputs', rocq, ... }:
          let
            inherit (rocq.rocqPackages) stdlib;
            inherit (inputs') rocq-nix-stdpp;
            inherit (rocq-nix-stdpp.packages) stdpp;

            mkIrisDerivation =
              { subdir, buildInputs }:
              rocq-nix-stdpp.lib.mkIrisProjDerivation {
                src = inputs.iris;
                inherit subdir buildInputs;
                meta.description = "A higher-order concurrent separation logic framework with support for interactive proofs";
              };

            iris = mkIrisDerivation {
              subdir = "iris";
              buildInputs = [
                stdlib
                stdpp
              ];
            };

            iris-deprecated = mkIrisDerivation {
              subdir = "iris_deprecated";
              buildInputs = [
                stdlib
                stdpp
                iris
              ];
            };

            iris-heap-lang = mkIrisDerivation {
              subdir = "iris_heap_lang";
              buildInputs = [
                stdlib
                stdpp
                iris
              ];
            };

            iris-unstable = mkIrisDerivation {
              subdir = "iris_unstable";
              buildInputs = [
                stdlib
                stdpp
                iris
                iris-heap-lang
              ];
            };

            iris-test = rocq-nix-stdpp.lib.mkIrisTestDerivation {
              name = "iris-test";
              src = inputs.iris;
              paths = {
                tests = "iris.tests";
              };
              buildInputs = [
                stdlib
                stdpp
                iris
                iris-deprecated
                iris-heap-lang
                iris-unstable
              ];
            };
          in
          {
            packages = {
              inherit
                iris
                iris-deprecated
                iris-heap-lang
                iris-unstable
                ;
            };

            checks = {
              inherit iris-test;
            };

            dev.env.lib = [
              stdlib
              stdpp
            ];
          };
      }
    );
}

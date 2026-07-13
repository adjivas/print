{
  description = "Print CI with nix-gitlab-ci";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-gitlab-ci.url = "gitlab:TECHNOFAB/nix-gitlab-ci/3.1.2?dir=lib";
  };

  outputs = inputs@{
    flake-parts,
    nixpkgs,
    nix-gitlab-ci,
    ...
  }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      nix-gitlab-ci.flakeModule
    ];

    systems = [ "x86_64-linux" ];

    perSystem = { pkgs, lib, config, ... }: let
      buildDirs = [
        "Blog"
        "Blog/Article00"
        "Blog/Article01"
        "Blog/Article02"
        "Blog/Article03"
        "Blog/Article04"
        "Blog/Article05"
        "Blog/Article06"
        "Blog/Article07"
        "Blog/Article08"
        "Resume"
        "Contact"
        "Gallery"
      ];

      jobNameFor = dir: "build:${lib.replaceStrings ["/"] [":"] dir}";

      mkBuildJob = dir: {
        stage = "build";

        rules = [
          {
            "if" = ''$FORCE_REBUILD == "1"'';
          }
          {
            changes = [ "${dir}/**/*" ];
          }
        ];

        variables.buf_size = "900000";

        nix.deps = with pkgs; [
          texliveFull
          hevea
          svg2tikz
          sourceHighlight
          babashka
          bbin
          (writeShellScriptBin "atomize.bb" ''
            exec "$HOME/.local/bin/atomize" "$@"
          '')
        ];

        script = [
          "cd ${dir}"
          "./build.clj"
        ];

        artifacts = {
          when = "always";
          expire_in = "1 week";
          paths = [ "${dir}/public" ];
        };
      };

       pagesJob = {
        stage = "pages";

        needs = map (dir: {
          job = jobNameFor dir;
          artifacts = true;
          optional = true;
        }) buildDirs;

        cache = {
          key = "pages-public";
          paths = [ "public" ];
          policy = "pull-push";
        };

        
        script = [ "mkdir -p public" ] ++ map (dir: ''
          if [ -d "${dir}/public" ]; then
            cp -r "${dir}/public/." public/
          fi
          rm -f public/*/gallery.*.pdf
        '') buildDirs;

        artifacts.paths = [ "public" ];

        rules = [
          { when = "on_success"; }
        ];
      };
    in {
      ci = {
        config = { };
        pipelines.default = {
          stages = [ "build" "pages" ];
          jobs = (lib.listToAttrs (map (dir: {
            name = "build:${lib.replaceStrings ["/"] [":"] dir}";
            value = mkBuildJob dir;
          }) buildDirs)) // {
            pages = pagesJob;
          };
        };
      };
    };
  };
}

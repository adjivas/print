# IDENT=... sudo --preserve-env=IDENT nix build ./#packages.x86_64-linux.dreaminstall --impure
packages.x86_64-linux.dreaminstall = (nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";

  specialArgs = {
    inherit inputs self;
    secretsSystem = inputs.secrets;
    secretsUser = inputs.secretsHomeAdjivas;
  };

  modules = [
    ./hosts/dreaminstall/configuration.nix
    ({ lib, ident, modulesPath, ... }: {
      imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
      ];

      environment.etc."ident-red.txt".text = builtins.readFile (builtins.getEnv "IDENT");
    })
  ];
}).config.system.build.isoImage;

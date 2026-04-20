# pixiecore boot "${build.kernel}/bzImage" "${build.netbootRamdisk}/initrd" --cmdline "init=${build.toplevel}/init" ...
build = (nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs self;
    secretsSystem = inputs.secrets;
    secretsUser = inputs.secretsHomeAdjivas;
  };
  modules = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
    (self + /hosts/dreaminstall/configuration.nix)
    ({ ... }: {
      boot.postBootCommands = ''
        if [[ " $(</proc/cmdline) " =~ \ RED_IDENT=([^[:space:]]+) ]]; then
          ident="''${BASH_REMATCH[1]}"

          ${pkgs.coreutils}/bin/printf '%s' "$ident" > /etc/ident-red.txt
        fi
      '';
    })
  ];
}).config.system.build;

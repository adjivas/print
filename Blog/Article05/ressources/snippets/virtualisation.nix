{ nixvirt, lib, pkgs, config, ... }: {
  options = {
    virtualisation.enable = lib.mkEnableOption "enable virtualisation";
    virtualisation.user = lib.mkOption {
      type = lib.types.str;
    };
    virtualisation.machines = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  config = lib.mkIf config.virtualisation.enable {
    programs.virt-manager.enable = true;

    virtualisation.libvirt = {
      enable = true;
      swtpm.enable = false;
    };

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${config.virtualisation.user} qemu-libvirtd -"
      "z /dev/kvmfr0 0660 ${config.virtualisation.user} qemu-libvirtd -"
      "d /var/lib/libvirt/images 0755 root qemu-libvirtd -"
    ];

    users.groups.qemu-libvirtd = { };
    users.users.qemu-libvirtd.group = "qemu-libvirtd";
    users.extraGroups.libvirtd.members = [ config.virtualisation.user ];
    users.extraGroups.kvm.members = [ config.virtualisation.user ];
    users.extraGroups.qemu-libvirtd.members = [ config.virtualisation.user ];

    virtualisation = {
      libvirtd = {
        enable = true;
        onBoot = "start";
        onShutdown = "shutdown";

        qemu = {
          package = pkgs.qemu_full;
          runAsRoot = true;
          swtpm.enable = true;
        };

        deviceACL = [
          "/dev/vfio/vfio"
          "/dev/kvm"
          "/dev/null"
          "/dev/full"
          "/dev/zero"
          "/dev/random"
          "/dev/urandom"
          "/dev/pts"
          "/dev/ptmx"
          "/dev/shm/looking-glass"
          "/dev/kvmfr0"
          "/dev/input/by-id/usb-ErgoDox_EZ_ErgoDox_EZ_0-event-kbd"
          "/dev/input/by-id/usb-Apple_Inc._Magic_Trackpad_2_CC2929200Z7J5R9AM-if01-event-mouse"
        ];
      };
      kvmfr = {
        enable = true;
        devices = [{
          size = 67108864;

          permissions = {
            user = config.virtualisation.user;
            group = "qemu-libvirtd";
            mode = "0660";
          };
        }];
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;

    environment.etc."looking-glass-client.ini".text = ''
      [win]
      fullScreen=yes
      borderless=yes
      title=Looking Glass

      [app]
      shmFile=/dev/kvmfr0
      cursorPollInterval = 3000;
      framePollInterval = 3000;

      [spice]
      enable=yes
      input=no

      [audio]
      micDefault=allow
      micShowIndicator=no

      [input]
      escapeKey=KEY_SCROLLLOCK
    '';

    virtualisation.libvirt.connections."qemu:///system".domains = config.virtualisation.machines;
    virtualisation.libvirt.connections."qemu:///system".pools = [
      {
        active = true;
        definition = nixvirt.lib.pool.writeXML {
          name = "default";
          uuid = "074f8b64-e825-432e-8da6-2843ff9d96bb";
          type = "dir";
          target.path = "/var/lib/libvirt/images";
        };
        volumes = [];
      }
    ];
    virtualisation.libvirt.connections."qemu:///system".networks = [
      {
        active = true;
        definition = nixvirt.lib.network.writeXML (nixvirt.lib.network.templates.bridge {
          uuid = "70b08691-28dc-4b47-90a1-45bbeac9ab5a";
          subnet_byte = 71;
        });
      }
    ];
  };
}

{ lib, nixvirt, pkgs, config, ... }: {
  options = {
    windows.enable = lib.mkEnableOption "enable virtualisation";
    windows.windowsInstall = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Path to the Windows ISO file";
      default = pkgs.fetchurl {
        url = "https://archive.org/download/windows11_20220930/Win11_22H2_English_x64v1.iso";
        sha256 = "sha256-DfLxc9hNAHQ9wI7YJPvRdNlykpvYS4f+OE7ZUPW9qyI=";
        name = "Win11_22H2_English_x64v1.iso";
      };
    };

    windows.unattendedWinstall = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "unattend.iso result";
      default = pkgs.runCommand "unattend-iso" { } ''
        mkdir -p "$out/iso"
        cp ${./autounattend.xml} autounattend.xml
        ${pkgs.cdrkit}/bin/genisoimage -Jr -o $out/iso/unattendName.iso autounattend.xml
      '';
    };
  };
  config = lib.mkIf config.windows.enable {
    system.activationScripts.copyNvramWindows.text = ''
      dst="/var/lib/libvirt/qemu/nvram/windows_VARS.fd"
      [ -e "$dst" ] || {
        mkdir -p "$(dirname "$dst")"
        cp "${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd" "$dst"
        chown qemu-libvirtd:kvm "$dst"
        chmod 660 "$dst"
      }
    '';

    virtualisation.machines = lib.mkAfter [
      {
        definition = let base = nixvirt.lib.domain.templates.windows ({
          name = "windows";
          uuid = "def734bb-e2ca-44ee-80f5-0ea0f2593aaa";
          memory = { count = 24; unit = "GiB"; };
          install_virtio = true;
          nvram_path = "/var/lib/libvirt/qemu/nvram/windows_VARS.fd";
          virtio_net = true;
          virtio_drive = true;
          networks = [
            (nixvirt.lib.mkBridgeNetwork {
              bridge = "br-inf";
              mac = "ba:e0:37:d0:62:71";
            })
          ];

          bridge_name = "virbr0";
          no_graphics = false;
        }); in nixvirt.lib.domain.writeXML (lib.recursiveUpdate base {
          vcpu = {
            placement = "static";
            count = 3;
          };
          cpu = {
            mode = "host-passthrough";
            check = "full";
            migratable = true;
            topology = {
              sockets = 1;
              dies = 1;
              cores = 3;
              threads = 1;
            };
            feature = {
              policy = "require";
              name = "topoext";
            };
          };
          iothreads = { count = 1; };
          cputune = {
            emulatorpin = { cpuset = "0"; };
            iothreadpin = { iothread = 1; cpuset = "0"; };
            vcpupin = [
              { vcpu = 0; cpuset = "0"; }
              { vcpu = 1; cpuset = "1"; }
              { vcpu = 2; cpuset = "2"; }
            ];
          };
          devices = {
            watchdog = { model = "itco"; action = "reset"; };
            memballoon.model = "none";
            channel = [
              {
                type = "spicevmc";
                target = { type = "virtio"; name = "com.redhat.spice.0"; };
              }
            ];
            graphics = {
              type = "spice";
              autoport = true;
              listen = { type = "address"; };
              image = { compression = false; };
            };
            video = {
              model = {
                type = "vga";
                vram = 65536;
                heads  = 1;
                primary = true;
              };
            };
            input = [
              { # ErgoDox EZ ErgoDox EZ
                type = "evdev";
                source = {
                  dev = "/dev/input/by-id/usb-ErgoDox_EZ_ErgoDox_EZ_0-event-kbd";
                  grab = "all";
                  grabToggle = "ctrl-ctrl";
                  repeat = true;
                };
              }
              { # Apple, Inc. Magic Trackpad 2
                type = "evdev";
                source = {
                  dev = "/dev/input/by-id/usb-Apple_Inc._Magic_Trackpad_2_CC2929200Z7J5R9AM-if01-event-mouse";
                };
              }
            ];
            console = {
              type = "pty";
              target = {
                type = "virtio";
                port = 0;
              };
            };
            disk = [
              {
                type = "file";
                device = "cdrom";
                driver = {
                  name = "qemu";
                  type = "raw";
                };
                source.file = config.windows.windowsInstall;
                target = {
                  dev = "sda";
                  bus = "sata";
                };
                address = {
                  type = "drive";
                  controller = 1;
                  bus = 0;
                  target = 0;
                  unit = 0;
                };
              }
              {
                type = "file";
                device = "cdrom";
                driver = {
                  name = "qemu";
                  type = "raw";
                };
                source.file = "${config.windows.unattendedWinstall}/iso/unattendName.iso";
                target = {
                  dev = "sdb";
                  bus = "sata";
                };
                address = {
                  type = "drive";
                  controller = 1;
                  bus = 0;
                  target = 0;
                  unit = 1;
                };
              }
              {
                type = "block";
                device = "disk";
                source.dev = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_2TB_S5RPNJ0X904225Y";
                driver = {
                  name = "qemu";
                  type = "raw";
                  cache = "none";
                  io = "native";
                  discard = "unmap";
                };
                target = {
                  dev = "sdd";
                  bus = "sata";
                };
                serial = "WIN-S5RPNJ0X904225Y";
                address = {
                  type = "drive";
                  controller = 0;
                  bus = 0;
                  target = 0;
                  unit = 0;
                };
              }
            ];
            hostdev = [
              {
                mode = "subsystem";
                type = "pci";
                managed = true;
                source = {
                  address = {
                    domain = 0;
                    bus = 3;
                    slot = 0;
                    function = 0;
                    multifunction = true;
                  };
                };
              }
              {
                mode = "subsystem";
                type = "pci";
                managed = true;
                source = {
                  address = {
                    domain = 0;
                    bus = 3;
                    slot = 0;
                    function = 1;
                  };
                };
              }
              { # Wacom Co., Ltd PTH-660 [Intuos Pro (M)]
                mode = "subsystem";
                type = "usb";
                managed = true;
                source = {
                  startupPolicy = "optional";
                  vendor.id = 1386;
                  product.id = 855;
                };
              }
            ];
          };
          qemu-override = {
            device = {
              alias = "hostdev0";
              frontend = {
                property = {
                  name = "x-vga";
                  type = "bool";
                  value = "true";
                };
              };
            };
          };
          qemu-commandline = {
            arg = [
              # Audio
              {value = "-device";}
              {value = "{\"driver\":\"ich9-intel-hda\"}";}
              # {value = "-device";}
              # {value = "{\"driver\":\"hda-micro\",\"audiodev\":\"hda\"}";}
              {value = "-audiodev";}
              {value = "{\"driver\":\"pa\",\"id\":\"hda\",\"server\":\"unix:/run/user/1000/pulse/native\"}";}
              # Lookingglass
              {value = "-device";}
              {value = "{\"driver\":\"ivshmem-plain\",\"id\":\"shmem0\",\"memdev\":\"looking-glass\"}";}
              {value = "-object";}
              {value = "{\"qom-type\":\"memory-backend-file\",\"id\":\"looking-glass\",\"mem-path\":\"/dev/kvmfr0\",\"size\":67108864,\"share\":true}";}
            ];
          };
        });
      }
    ];
  };
}

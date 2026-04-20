virtualisation.libvirt.connections."qemu:///system".domains = [
  {
    domains = [{
      definition = let base = nixvirt.lib.domain.templates.windows ({
        name = "windows";
        uuid = "def734bb-e2ca-44ee-80f5-0ea0f2523aaa";
        memory = { count = 8; unit = "GiB"; };
        storage_vol = { pool = "default"; volume = "windows.qcow2"; };
        install_vol = "\${config.windows.iso}";
        install_virtio = true;
        nvram_path = "/var/lib/libvirt/qemu/nvram/windows_VARS.fd";
        no_graphics = false;

        networks = [
          (nixvirt.lib.mkBridgeNetwork {
            bridge = "br-inf";
            mac = "ba:e0:37:d0:62:42";
          })
        ];

        bridge_name = "br0";

        virtio_net = true;
        virtio_drive = true;
      }); in nixvirt.lib.domain.writeXML (lib.recursiveUpdate base {
        # nos surcharges du template
      });
    }]
  }
];

virtualisation = {
  # Active les services libvirtd de systemd
  libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";

    qemu = {
      package = pkgs.qemu_full;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # Active les outils/libs dans l'espace utilisateur
  libvirt = {
    enable = true;
    swtpm.enable = true;
  };
};

specialisation.vfio-passthrough.configuration = {
  virtualisation = {
    vfio = {
      enable = true;
      IOMMUType = "intel";
      ignoreMSRs = true;
      devices = [
        # GPU RX7900 GRE
        "1002:744c"
        # Navi 31
        "1002:ab30"
      ];
    };
    kvmfr = { # Looking-glass
      # ...
    };
  };
};

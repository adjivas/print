hostdev = [
  { # GPU RX7900 GRE
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
  { # Navi 31
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
];

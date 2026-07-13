services.xserver.displayManager.lightdm = {
  extraConfig = lib.mkForce ''
    [Seat:*]
    greeter-session=lightdm-gtk-greeter
    user-session=sway

    [Seat:seat0]
    autologin-user=adjivas
    autologin-session=sway

    [Seat:seat1]
    autologin-user=kad
    autologin-session=sway
  '';
};

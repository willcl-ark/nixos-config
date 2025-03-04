{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "gb";
      variant = "";
    };
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # TODO: Get my ComicCode font in here as set it as monospace
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      font-awesome
      noto-fonts
      noto-fonts-emoji
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };

  # Sound with pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}

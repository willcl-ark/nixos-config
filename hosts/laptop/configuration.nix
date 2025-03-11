{ ... }: {
  # Import common configuration
  imports = [ ../../modules/common.nix ];

  # Host-specific configuration
  networking.hostName = "nix-laptop";
}
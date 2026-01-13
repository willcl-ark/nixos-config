{
  config,
  pkgs,
  ...
}:
{
  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
    homedir = "${config.home.homeDirectory}/.gnupg";
    settings = {
      use-agent = true;
      default-key = "67AA5B46E7AF78053167FE343B8F814A784218F8";
    };
  };
}

{
  config,
  pkgs,
  inputs,
  ...
}:
{
  disabledModules = [ "services/misc/paperless.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/paperless.nix" ];

  services.paperless = {
    enable = true;
    package = pkgs.unstable.paperless-ngx;
    port = 28981;
    domain = "paperless.home";
    environmentFile = config.sops.secrets."paperless/env".path;
    passwordFile = config.sops.secrets."paperless/password".path;
    consumptionDirIsPublic = true;
    configureNginx = true;
    settings = {
      PAPERLESS_DBENGINE = "sqlite";
      PAPERLESS_ADMIN_USER = "vhqkze";
      PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = false;
      PAPERLESS_OCR_LANGUAGE = "chi_sim+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_POST = true;
      PAPERLESS_DISABLE_REGULAR_LOGIN = true;
      PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
      PAPERLESS_SOCIAL_ACCOUNT_SYNC_GROUPS = true;
      PAPERLESS_SOCIAL_AUTO_SIGNUP = true;
    };
    exporter = {
      enable = true;
      onCalendar = "04:50:00";
      settings = {
        compare-checksums = true;
        delete = true;
        no-color = true;
        no-progress-bar = true;
      };
    };
  };

  systemd.services."paperless-exporter" = {
    onSuccess = [ "restic-backups-paperless.service" ];
  };

  services.restic.backups.paperless = {
    paths = [ config.services.paperless.exporter.directory ];
  };
}

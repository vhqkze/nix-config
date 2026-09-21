{
  config,
  lib,
  ...
}:
let
  rootConfig = config;
in
{
  imports = [
    {
      options.services.restic.backups = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, config, ... }:
            {
              options.tag = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Restic backup tag. Defaults to the backup attribute name.";
              };

              config = {
                repositoryFile = lib.mkDefault rootConfig.sops.secrets."service/restic/repo".path;
                passwordFile = lib.mkDefault rootConfig.sops.secrets."service/restic/password".path;
                initialize = lib.mkDefault true;

                extraBackupArgs = lib.mkDefault [
                  "--tag auto"
                  "--tag"
                  config.tag
                  "--retry-lock 60m"
                  "--quiet"
                ];

                pruneOpts = lib.mkDefault [
                  "--tag auto"
                  "--tag"
                  config.tag
                  "--keep-last 5"
                  "--keep-daily 30"
                  "--keep-weekly 20"
                  "--keep-monthly 12"
                  "--retry-lock 60m"
                  "--quiet"
                ];

                timerConfig = lib.mkDefault {
                  OnCalendar = "04:00";
                  Persistent = true;
                  RandomizedDelaySec = "1h";
                };
              };
            }
          )
        );
      };
    }
  ];
}

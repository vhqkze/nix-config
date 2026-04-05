{
  config,
  pkgs,
  ...
}:
{
  systemd.services = {
    "service_fail_notify@" = {
      description = "服务失败通知";
      scriptArgs = "%i";
      script = ''
        ${pkgs.curl}/bin/curl \
          --fail \
          --show-error --silent \
          --max-time 10 \
          --retry 3 \
          https://api.day.app/$BARK_TOKEN/NixOS服务失败/$1
      '';
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.sops.secrets."service/bark_me".path;
      };
    };
    zhangle_me = {
      script = ''
        cd ${config.users.users.vhqkze.home}/Developer/minitools
        ${pkgs.poetry}/bin/poetry run python gupiao/newgu.py
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "vhqkze";
        RemainAfterExit = false;
        EnvironmentFile = config.sops.secrets."service/bark_me".path;
      };
      startAt = [
        "Mon..Fri *-*-* 10:05:00"
      ];
      onFailure = [ "service_fail_notify@%n.service" ];
    };
    zhangle_xz = {
      script = ''
        cd ${config.users.users.vhqkze.home}/Developer/minitools
        ${pkgs.poetry}/bin/poetry run python gupiao/newgu.py
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "vhqkze";
        RemainAfterExit = false;
        EnvironmentFile = config.sops.secrets."service/bark_xz".path;
      };
      startAt = [
        "Mon..Fri *-*-* 09:00:00"
      ];
      onFailure = [ "service_fail_notify@%n.service" ];
    };
    weather = {
      script = ''
        cd ${config.users.users.vhqkze.home}/Developer/minitools
        ${pkgs.poetry}/bin/poetry run python weather.py $WEATHER_LOCATION $CHECK_TIME
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "vhqkze";
        RemainAfterExit = false;
        EnvironmentFile = config.sops.secrets."service/weather".path;
      };
      startAt = [
        "Mon..Fri,Sun *-*-* 9:15:00"
      ];
      onFailure = [ "service_fail_notify@%n.service" ];
    };
    healthcheckio = {
      script = ''
        ${pkgs.curl}/bin/curl \
          --fail \
          --show-error --silent \
          --max-time 10 \
          --retry 3 \
          $CHECK_URL
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "vhqkze";
        RemainAfterExit = false;
        EnvironmentFile = config.sops.secrets."service/healthcheckio".path;
      };
      startAt = [
        "*-*-* *:*:00"
      ];
      onFailure = [ "service_fail_notify@%n.service" ];
    };
  };
}

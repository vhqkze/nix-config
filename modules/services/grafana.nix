{
  config,
  ...
}:
{
  # 屏蔽初始管理员账号创建(security.disable_initial_admin_creation=true)与后续账号
  # 创建(users.allow_sign_up=false)、账号密码登录(auth.disable_login_form=true)，
  # 完全使用 Pocket-ID 来创建账号，并通过 role_attribute_path 将 Pocket-ID 的 admin 组
  # 用户映射为 Grafana 的管理员。
  # 在 Pocket-ID 创建 OIDC Client 后需要配置 Callback URL 为 https://grafana.home/login/generic_oauth

  services.grafana = {
    enable = true;
    settings = {
      server = {
        protocol = "http";
        http_addr = "127.0.0.1";
        http_port = 3500;
        domain = "grafana.home";
        enforce_domain = true;
        root_url = "https://grafana.home/";
      };
      security = {
        disable_initial_admin_creation = true;
        cookie_secure = true;
        disable_brute_force_login_protection = true;
        x_xss_protection = true;
        secret_key = "$__env{GF_SECURITY_SECRET_KEY}";
      };
      users = {
        allow_sign_up = false;
        default_language = "zh-Hans";
        default_theme = "system";
      };
      auth = {
        disable_login_form = true;
      };
      "auth.generic_oauth" = {
        enabled = true;
        name = "Pocket ID";
        allow_sign_up = true;
        client_id = "grafana";
        client_secret = "$__env{GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET}";
        scopes = "openid email profile groups";
        skip_org_role_sync = false;
        role_attribute_path = "contains(groups, 'admin') && 'Admin' || contains(groups, 'editor') && 'Editor' || 'Viewer'";
        allow_assign_grafana_admin = true;
        auth_url = "https://pocket-id.home/authorize";
        token_url = "https://pocket-id.home/api/oidc/token";
        api_url = "https://pocket-id.home/api/oidc/userinfo";
        signout_redirect_url = "https://pocket-id.home/api/oidc/end-session";
        auto_login = true;
      };
    };
    provision = {
      enable = true;
      datasources.settings = {
        prune = true;
        datasources = [
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
            isDefault = true;
          }
        ];
      };
    };
  };

  sops.secrets.grafana.owner = "grafana";

  systemd.services.grafana.serviceConfig.EnvironmentFile = config.sops.secrets.grafana.path;

  services.nginx.virtualHosts."grafana.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };
}

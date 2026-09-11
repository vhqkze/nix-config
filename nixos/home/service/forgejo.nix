{
  config,
  pkgs,
  ...
}:
{
  services.forgejo = {
    enable = true;
    settings = {
      server = {
        PROTOCOL = "http+unix";
        DOMAIN = "git.home";
        HTTP_ADDR = "/run/forgejo/forgejo.sock";
        ROOT_URL = "https://git.home/";
        DISABLE_SSH = true;
      };
      "repository.editor" = {
        LINE_WRAP_EXTENSIONS = ".adoc,.asciidoc,.txt,.md,.markdown,.mdown,.mkd,.livemd";
        PREVIEWABLE_FILE_MODES = "markdown,asciidoc";
      };
      openid = {
        ENABLE_OPENID_SIGNIN = false;
        ENABLE_OPENID_SIGNUP = false;
      };
      oauth2_client = {
        ENABLE = true;
        ENABLE_AUTO_REGISTRATION = true;
        REGISTER_EMAIL_CONFIRM = false;
        ACCOUNT_LINKING = "auto";
        UPDATE_AVATAR = true;
      };
      service = {
        DISABLE_REGISTRATION = true;
        SHOW_REGISTRATION_BUTTON = false;
        ENABLE_INTERNAL_SIGNIN = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        ENABLE_BASIC_AUTHENTICATION = false;
      };
      cron = {
        ENABLED = true;
      };
      "markup.asciidoc" = {
        ENABLED = true;
        NEED_POSTPROCESS = true;
        FILE_EXTENSIONS = ".adoc,.asciidoc";
        RENDER_COMMAND = builtins.concatStringsSep " " [
          "${pkgs.asciidoctor-with-extensions}/bin/asciidoctor"
          "--embedded"
          "--safe-mode=secure"
          "--attribute=compat-mode"
          "--attribute=env=github"
          "--attribute=env-github=true"
          "--out-file=-"
          "-"
        ];
        IS_INPUT_FILE = false;
      };
      session = {
        COOKIE_SECURE = true;
      };
    };
  };

  services.nginx.virtualHosts."git.home" = {
    locations."/" = {
      proxyPass = "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}";
    };
  };

  services.restic.backups.forgejo = {
    paths = [ config.services.forgejo.stateDir ];
    backupPrepareCommand = "systemctl stop forgejo.service";
    backupCleanupCommand = "systemctl start forgejo.service";
  };
}

# 首次部署，下面四个字段的值应该设置如下：
# DISABLE_REGISTRATION = false; # 首次部署时，这里应该设置为 false，待管理员账号注册后，再改为 true
# SHOW_REGISTRATION_BUTTON = true;
# ENABLE_INTERNAL_SIGNIN = true; # 屏蔽帐密登录页面，可以通过网页临时使用帐密登录: https://你的Forgejo域名/user/login?auth_with_credentials=1
# ALLOW_ONLY_EXTERNAL_REGISTRATION = false; # 仅允许 OIDC 注册
# 在注册登录后，进入 设置->安全->已绑定的账号，链接账户，在成功绑定 pocket-id 账户
# 后，再恢复上面四个字段的值，屏蔽注册，但是允许 OIDC 注册。

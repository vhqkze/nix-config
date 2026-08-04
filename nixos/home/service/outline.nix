{
  config,
  ...
}:
{
  services.outline = {
    enable = true;
    port = 9050;
    publicUrl = "https://outline.home";
    defaultLanguage = "zh_CN";
    databaseUrl = "local";
    redisUrl = "local";
    maximumImportSize = 5120000;
    secretKeyFile = config.sops.secrets."outline/secretKey".path;
    utilsSecretFile = config.sops.secrets."outline/utilsSecret".path;
    storage = {
      storageType = "local";
    };
    oidcAuthentication = {
      authUrl = "https://pocket-id.home/authorize";
      clientId = "outline";
      clientSecretFile = config.sops.secrets."outline/oidcSecret".path;
      displayName = "PocketID";
      tokenUrl = "https://pocket-id.home/api/oidc/token";
      userinfoUrl = "https://pocket-id.home/api/oidc/userinfo";
    };
  };
}

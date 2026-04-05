{
  config,
  pkgs,
  inputs,
  ...
}:

{
  services.gatus = {
    enable = true;
    settings = {
      web.port = 7020;
      storage = {
        type = "sqlite";
        path = "/var/lib/gatus/data.db";
      };
      endpoints = [
        {
          name = "home";
          url = "https://home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "beszel";
          url = "https://beszel.home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "grimmory";
          url = "https://book.home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "calibre";
          url = "https://calibre.home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "kavita";
          url = "https://kavita.home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "link";
          url = "https://link.home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "memos";
          url = "https://memos.home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "plex";
          url = "https://plex.home/web/index.html";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "reader";
          url = "https://reader.home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == any(200, 401)" ];
        }
        {
          name = "ezbookkeeping";
          url = "https://money.home";
          interval = "10s";
          client.insecure = true;
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "network";
          url = "https://baidu.com";
          interval = "10s";
          conditions = [ "[STATUS] == 200" ];
        }
      ];
    };
  };
}

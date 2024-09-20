{ config, ... }:
{
  age.secrets."homepage.env".file = ../../../secrets/homepage.env.age;

  services.homepage-dashboard = {
    enable = true;
    settings = {
      title = "Dashboard - jsmart.dev";
      base = "dashboard.jsmart.dev";
      theme = "dark";
      layout = {
        "Group A" = {
          header = false;
        };
      };
    };
    environmentFile = config.age.secrets."homepage.env".path;
    services = [
      {
        "Group A" = [
          {
            "Adguard" = {
              description = "DNS Adblocker";
              icon = "adguard-home";
              href = "http://adguard.home";
              widget = {
                type = "adguard";
                url = "http://localhost:3000";
                username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
                password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
              };
            };
          }
          {
            "Vaultwarden" = rec {
              description = "Password Manager";
              icon = "bitwarden";
              href = "https://bitwarden.jsmart.dev";
              siteMonitor = href;
            };
          }
          {
            "Paperless" = rec {
              description = "Document Manager";
              icon = "paperless";
              href = "https://paperless.jsmart.dev";
              siteMonitor = href;
            };
          }
          {
            "Nextcloud" = rec {
              description = "Remote File Server";
              icon = "nextcloud-white";
              href = "https://files.jsmart.dev";
              siteMonitor = href;
            };
          }
          {
            "Hompage Dashboard" = rec {
              description = "Service Monitor";
              icon = "homepage";
              href = "https://dashboard.jsmart.dev";
              siteMonitor = href;
            };
          }
        ];
      }
    ];
    bookmarks = [ ];
    widgets = [
      {
        resources = {
          cpu = true;
          disk = "/";
          memory = true;
        };
      }
    ];
  };

  services.nginx.proxyHosts."dashboard.jsmart.dev".port =
    config.services.homepage-dashboard.listenPort;
}

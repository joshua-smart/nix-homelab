{ config, ... }: {
  users.users."github-runner" = {
    isSystemUser = true;
    group = "github-runner";
  };
  users.groups."github-runner" = { };

  sops.secrets."github-runners/portfolio/token".owner = "github-runner";
  sops.secrets."github-runners/resume/token".owner = "github-runner";

  services.github-runners = {
    portfolio = {
      enable = true;
      name = "portfolio";
      tokenFile = config.sops.secrets."github-runners/portfolio/token".path;
      url = "https://github.com/joshua-smart/portfolio";
      user = "github-runner";
      group = "github-runner";
    };
    resume = {
      enable = true;
      name = "resume";
      tokenFile = config.sops.secrets."github-runners/resume/token".path;
      url = "https://github.com/joshua-smart/resume";
      user = "github-runner";
      group = "github-runner";
    };
  };
}

{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    programs = {
      fish.enable = true;

      powerline-go = {
        enable = true;
        newline = true;
        modules = [ "nix-shell" ];
        pathAliases = { "\\~/project/foo" = "prj-foo"; };
        settings = {
          ignore-repos = [ "/home/me/project1" "/home/me/project2" ];
        };
      };
    };

    # Needed to avoid error with dummy fish package.
    xdg.dataFile."fish/home-manager_generated_completions".source =
      mkForce (builtins.toFile "empty" "");

    nixpkgs.overlays = [
      (self: super:
        let dummy = pkgs.writeScriptBin "dummy" "";
        in {
          powerline-go = dummy;
          fish = dummy;
        })
    ];

    nmt.script = ''
      assertFileExists home-files/.config/fish/config.fish
      assertFileContains \
        home-files/.config/fish/config.fish \
        '/bin/powerline-go -error $status -jobs (count (jobs -p)) -modules nix-shell -newline -path-aliases \~/project/foo=prj-foo -ignore-repos /home/me/project1,/home/me/project2'
    '';
  };
}

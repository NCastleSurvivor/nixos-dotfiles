{ config, pkgs, ... }:

{
   programs = {
      kitty.enable = true;

      git = {
         enable = true;
         settings = {
            user = {
               name = "NCastleSurvivor";
               email = "1439345229@qq.com";
            };

            init.defaultBranch = "main";
            pull.rebase = true;
            push.autoSetupRemote = true;
            core = {
               editor = "nvim";
               pager = "delta";
            };
            interactive.diffFilter = "delta --color-only";
            delta = {
               navigate = true;
               light = false;
               side-by-side = true;
               line-numbers = true;
            };
            alisas = {
               st = "status";
               co = "checkout";
               br = "branch";
               last = "log -1 HEAD --";
               unstage = "reset HEAD --";
               graph = "log --oneline --all --graph --decorate";
            };
         };
      };
    };

}

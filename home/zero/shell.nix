{ config, pkgs, ... }:
{
  # ===== Fish Shell 配置 =====
  programs.fish = {
    enable = true;
#    sessionVariables = {
#	MANPAGER = "less -R";
#	PNPM_HOME = "$HOME/.local/share/pnpm";
#	GOPATH = "$HOME/go";
#	GOBIN = "$HOME/go/bin";
#    };

    shellInit = ''
      set -gx XMODIFIERS "@im=fcitx"
      set -gx GTK_IM_MODULE "fcitx"
      set -gx QT_IM_MODULE "fcitx"

      fish_add_path $HOME/go/bin
      fish_add_path $HOME/.local/share/pnpm
      fish_add_path $HOME/.local/bin
      fish_add_path $HOME/bin
      fish_add_path $HOME/.nix-profile/bin
    '';
    
    shellAliases = {
      lla = "eza -la -icons=auto --git";
      lt = "eza -tree -icons=auto ";
      vi = "nvim";
      vim = "nvim";

      reboot = "doas reboot";
      poweroff = "doas poweroff";
      shutdown = "doas shutdown now";

      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -Iv";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      h = "history";
      c = "clear";
      q = "exit";

      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gf = "git fetch";

    };

    # 交互式配置
    interactiveShellInit = ''
       fish_vi_key_bindings
       bind -M insert \cr history-search-backward
       bind -M default \cr history-search-backward

       function fish_greetinh
          set -l user_name (whomi)
	  set -l sys_info (uname -srm)
	  set -l fish_ver (string split " " (fish --version))[3]
	  set -l date_info (date '+%Y-%m-%d %H:%M:%S')

	  echo "Welcome back, $user_name!"
	  echo "System: $sys_info"
	  echo "Shell: fish $fish_ver"
	  echo "Date: $date_info"
	  echo ""
	end

	function reloadfish
	  source ~/.config/fish/config.fish
	  echo "Fish config reloaded!"
	end
    '';

    # ===== 函数 =====
    functions = {
      # 提取各种压缩包
      extract = ''
        if test -f $argv[1]
            switch $argv[1]
                case "*.tar.bz2" "*.tbz2"
                    tar xjf $argv[1]
                case "*.tar.gz" "*.tgz"
                    tar xzf $argv[1]
                case "*.tar.xz" "*.txz"
                    tar xJf $argv[1]
                case "*.tar.zst"
                    tar --zstd -xf $argv[1]
                case "*.bz2"
                    bunzip2 $argv[1]
                case "*.rar"
                    unrar x $argv[1]
                case "*.gz"
                    gunzip $argv[1]
                case "*.tar"
                    tar xf $argv[1]
                case "*.zip"
                    unzip $argv[1]
                case "*.Z"
                    uncompress $argv[1]
                case "*.7z"
                    7z x $argv[1]
                case "*"
                    echo "'$argv[1]' cannot be extracted via extract()"
            end
        else
            echo "'$argv[1]' is not a valid file"
        end
      '';

      mkcd = ''
        mkdir -p $argv[1]
        cd $argv[1]
      '';

      ports = ''
        doas lsof -iTCP -sTCP:LISTEN -P -n
      '';

      myip = ''
        curl -s ifconfig.me
        echo ""
      '';
    };
  };
}

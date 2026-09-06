{ config, pkgs, ... }:
{
  # ===== 使用 doas 替代 sudo =====
  # doas 是 OpenBSD 的特权提升工具，配置更简洁、攻击面更小
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        persist = true;    # 认证后记住一段时间（默认 5 分钟）
        keepEnv = true;    # 保留用户环境变量
      }
      # 无需密码执行特定命令（示例，按需取消注释）
       {
         groups = [ "wheel" ];
         noPass = true;
         cmd = "${pkgs.systemd}/bin/systemctl";
         args = [ "suspend" ];
       }
    ];
  };

  # ===== 禁用 sudo =====
  security.sudo.enable = false;

  # ===== sudo 兼容包装 =====
  # 让脚本中写了 sudo 的命令自动转发到 doas
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "sudo" ''
      exec ${pkgs.doas}/bin/doas "$@"
    '')
  ];

  # fish shell 中的 sudo 别名（在 home/zero/shell.nix 中也设置了）
  environment.shellAliases = {
    reboot = "doas reboot";
    poweroff = "doas poweroff";
  };
}

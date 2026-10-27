{ ... }:
{
  # 只需要主机密钥给 agenix 使用，不运行 sshd，避免暴露 22 端口。
  # 如需远程 SSH：把 enable 改为 true、在防火墙放行 22，并配置 authorizedKeys。
  services.openssh = {
    enable = false;
    generateHostKeys = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}

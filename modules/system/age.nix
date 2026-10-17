{ config, pkgs, ... }:
{
  age = {
    # SSH 主机密钥作为 age 解密私钥（与 sops 用法一致）
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      zero_password = {
        file = ../../secrets/zero_password.age;
        mode = "0400";
        owner = "root";
        group = "root";
      };
    };
  };
}

{
  config,
  pkgs,
  inputs,
  ...
}:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    #设定开机读取本机私钥
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      "zero_password" = {
        #在创建/校验用户阶段完成解密
        neededForUsers = true;
      };
    };
  };
}

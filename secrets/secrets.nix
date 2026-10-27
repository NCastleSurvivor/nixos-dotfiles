let
  # 替换为主机的 age 公钥：
  #   ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
  # 这是 agenix CLI 的加密规则文件；不要把私钥写进来。
  hostKey = "age197gfgj83z2z0hmt5negrzznnt8kcuhajjn66yr5ajtu5eswqeanqj4ndr0";
in
{
  "zero_password.age".publicKeys = [ hostKey ];
}

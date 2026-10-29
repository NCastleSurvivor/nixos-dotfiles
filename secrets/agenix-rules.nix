let
  # 替换为主机的 age 公钥：
  #   ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGzfHdhSpnMy2ku8dQp8X9rZjxlGUfXq7qwwRZuJeqA root@NCastleSurvivor";
in
{
  "zero_password.age".publicKeys = [ hostKey ];
}

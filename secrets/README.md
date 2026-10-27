# secrets

这个目录只放 age 加密后的秘密和公钥规则。

- `secrets.nix`：agenix 的 recipient 列表，**只含公钥**。当前是占位符，必须替换：
  ```bash
  ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
  ```
- `zero_password.age`：`zero` 用户的密码哈希（yescrypt），用主机 age 公钥加密。

不要提交：

- SSH 私钥；
- 明文密码/哈希；
- `age` 私钥或 `age-keygen` 生成的 identity 文件。

重新加密：

```bash
cd secrets
mkpasswd --method=yescrypt | agenix -e zero_password.age
```

`modules/system/users.nix` 设置了 `users.mutableUsers = false`，所以密码以本目录的 secret 为准。

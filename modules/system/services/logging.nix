# 日志策略
{ ... }:
{
  services.journald.settings = {
    Journal = {
      SystemMaxUse = "500M";
      Storage = "persistent";
    };
  };
}

# Rime 数据映射（用户要求：语法模型路径与数据保持原样）
{
  config,
  configsDir,
  ...
}:
{
  xdg.dataFile = {
    "fcitx5/rime" = {
      source = "${configsDir}/rime";
      force = true;
      recursive = true;
    };
    "fcitx5/rime/wangxiang-lts-zh-hans.gram" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/zero/Workspace/wanxiang-lts-zh-hans.gram";
      force = true;
    };
  };
}

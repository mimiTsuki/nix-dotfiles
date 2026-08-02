{ ... }:
{
  aeroSpace.extraFloatingBundleIds = [
    "jp.co.celsys.CLIPSTUDIOPAINT" # CLIP STUDIO PAINT
  ];

  # 起動時のworkspace自動配置
  aeroSpace.workspaceAssignments = [
    {
      bundleId = "com.github.wez.wezterm";
      workspace = "1";
    } # WezTerm
    {
      bundleId = "com.google.Chrome";
      workspace = "2";
    } # Chrome
    {
      bundleId = "md.obsidian";
      workspace = "4";
    } # Obsidian
    {
      bundleId = "com.anthropic.claudefordesktop";
      workspace = "8";
    } # Claude Desktop
    {
      bundleId = "com.microsoft.VSCode";
      workspace = "9";
    } # VSCode
  ];
}

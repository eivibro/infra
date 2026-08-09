{inputs, ...}: {
  flake.modules.homeManager.graphical = {
    imports = [
      inputs.self.modules.homeManager.media
    ];
  };

  flake.modules.homeManager.media = {
    config,
    lib,
    pkgs,
    ...
  }: let
    preferredVideoCodecs =
      lib.optional config.media.av1.enable "av01"
      ++ [
        "vp9"
        "hev1"
        "avc1"
      ];

    onlineVideoFormat =
      lib.concatMapStringsSep "/" (
        codec: "bv[height<=?1080][vcodec^=${codec}]+ba"
      )
      preferredVideoCodecs;
  in {
    options.media.av1.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether mpv and yt-dlp may select AV1 when choosing an online
        video format.
      '';
    };

    config = {
      stylix.targets.mpv.enable = true;

      programs.mpv = {
        enable = true;
        scripts = [pkgs.mpvScripts.sponsorblock];
        config = {
          autofit-larger = "14%x14%";
          geometry = "0%:0%";
          gpu-api = "vulkan";
          hwdec = "auto-safe";
          profile = "gpu-hq";
          vo = "gpu-next";
          ytdl-format = onlineVideoFormat;
        };
      };

      programs.yt-dlp = {
        enable = true;
        settings = {
          cookies-from-browser = "firefox";
          format = onlineVideoFormat;
        };
      };
    };
  };
}

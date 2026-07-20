{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeDesktopItem,
  pkg-config,
  wayland-scanner,
  scdoc,
  glib,
  gdk-pixbuf,
  pango,
  cairo,
  gtk4,
  wayland,
  wayland-protocols,
  ffmpeg,
  x264,
  libpulseaudio,
  pipewire,
  mesa,
  wrapGAppsHook4,
  libxkbcommon,
  vulkan-loader,
}:

rustPlatform.buildRustPackage rec {
  pname = "wf-recorder-gui";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ali205412";
    repo = "wf-recorder-gui";
    rev = "v0.4.0";
    hash = "sha256-/7ZtklccG6mnx0h73Zy9QkQzOyhSBRMvjExzxlzuppY=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-rZOv00udcaNDmfv9ScYPf0nfFvBoi+gce2RAvCakx50=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    scdoc
  ];

  buildInputs = [
    wayland
    wayland-protocols
    ffmpeg
    x264
    libpulseaudio
    pipewire
    mesa
    glib
    gdk-pixbuf
    pango
    cairo
    gtk4
    wrapGAppsHook4
  ];

  desktopEntry = [
    (makeDesktopItem {
      name = "WF-Recorder-GUI";
      comment = "Modern GUI for wf-recorder screen recorder";
      exec = "wf-recorder-gui";
      icon = "camera-video-symbolic";
      desktopName = "WF Recorder GUI";
      terminal = false;
      type = "Application";
      categories = [
        "AudioVideo"
        "Video"
        "Recorder"
        "GTK"
      ];
      keywords = [
        "screen"
        "recorder"
        "wayland"
        "capture"
      ];
      startupNotify = true;
    })
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    for entry in ${toString desktopEntry}; do
      cp $entry/share/applications/*.desktop $out/share/applications/
    done
  '';

  postFixup = ''
    wrapProgram $out/bin/wf-recorder-gui \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          wayland
          libxkbcommon
          vulkan-loader
        ]
      }
  '';

  meta = {
    description = "wf-recorder GUI (GTK)";
    homepage = "https://github.com/ali205412/wf-recorder-gui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ myamusashi ];
  };
}

{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, dbus
, alsa-lib

  # customizations
, withStreaming ? true
, withAudioBackend ? "rodio"
, withMediaControl ? true
, withLyrics ? false
, withImage ? false
, withNotify ? false
, withSixel ? false
, withDaemon ? false
}:

rustPlatform.buildRustPackage rec {
  pname = "spotify-player";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-SA2JtCJj6F7IUhBVgpUYQpPjTi1P3Dbe4ZMT0djcJzo=";
  };

  cargoHash = "sha256-fIDCYV5hu1GXkbpcU48DB1n8y92UvmdQi5fpUGyvles=";

  buildNoDefaultFeatures = true;

  buildFeatures = [ ]
    ++ lib.optionals withStreaming [ "streaming" ]
    ++ lib.optionals (withAudioBackend != "") [ "${withAudioBackend}-backend" ]
    ++ lib.optionals withMediaControl [ "media-control" ]
    ++ lib.optionals withLyrics [ "lyric-finder" ]
    ++ lib.optionals withImage [ "image" ]
    ++ lib.optionals withNotify [ "notify" ]
    ++ lib.optionals withSixel [ "sixel" ]
    ++ lib.optionals withDaemon [ "daemon" ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ]
    ++ lib.optionals stdenv.isLinux [ openssl dbus alsa-lib ];
  meta = with lib;
    {
      description = "A fast, easy to use, and configurable terminal music player";
      homepage = "https://github.com/aome510/spotify-player";
      license = licenses.mit;
      maintainers = with maintainers; [ dit7ya Xyven1 ];
      mainProgram = "spotify_player";
    };
}

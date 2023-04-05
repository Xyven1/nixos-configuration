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
}:

rustPlatform.buildRustPackage rec {
  pname = "spotify-player";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-c+CbIDg4WlzRStiA+yBkjfSmMJ183tLBGiK340bZgnA=";
  };

  cargoHash = "sha256-nhRXFxSrzkq3SdJ4ZmWlKl7SwxwOz6ZYboIsBmgdFJ8=";

  buildNoDefaultFeatures = true;

  buildFeatures = [ ]
    ++ lib.optionals withStreaming [ "streaming" ]
    ++ lib.optionals (withAudioBackend != "") [ "${withAudioBackend}-backend" ]
    ++ lib.optionals withMediaControl [ "media-control" ]
    ++ lib.optionals withLyrics [ "lyric-finder" ]
    ++ lib.optionals withImage [ "image" ]
    ++ lib.optionals withNotify [ "notify" ]
    ++ lib.optionals withSixel [ "sixel" ];

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

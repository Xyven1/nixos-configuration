{
  description = "Xyven's NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    rust-overlay.url = "github:oxalica/rust-overlay";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    neovim-config = {
      flake = false;
      url = "github:xyven1/neovim-config";
    };

    wpi-wireless-install.url = "github:xyven1/wpi-wireless-install";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    backgrounds = {
      flake = false;
      url = "github:xyven1/nixos-backgrounds";
    };

    home-management.url = "github:xyven1/home-management";

    sops-nix.url = "github:Mic92/sops-nix";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    forAllPkgs = f: forAllSystems (system: f nixpkgs.legacyPackages.${system});
    hosts = builtins.attrNames (nixpkgs.lib.filterAttrs
      (n: v:
        (n != "common")
        && v == "directory"
        && builtins.hasAttr "default.nix" (builtins.readDir ./hosts/${n}))
      (builtins.readDir ./hosts));
  in {
    lib = import ./lib {
      inherit inputs outputs;
      lib = nixpkgs.lib;
    };
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    packages = forAllPkgs (pkgs: import ./pkgs {inherit pkgs;});
    devShells = forAllPkgs (pkgs: import ./shell.nix {inherit pkgs;});
    formatter = forAllPkgs (pkgs: pkgs.nixpkgs-fmt);

    nixosConfigurations = builtins.listToAttrs (builtins.map
      (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs host;};
          modules = [./hosts/${host}];
        };
      })
      hosts);

    homeConfigurations = builtins.listToAttrs (builtins.map
      (hostUser: {
        name = "${hostUser.user}@${hostUser.host}";
        value = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [hostUser.config_path] ++ builtins.attrValues outputs.homeManagerModules;
        };
      })
      (nixpkgs.lib.flatten (builtins.map outputs.lib.getHostUsers hosts)));
  };
}

{
  description = "Home Manager configuration of colawithsauce";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-23.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs.url = "github:nix-community/emacs-overlay";

    # emacs inputs
    rime-regexp = {
      url = "github:colawithsauce/rime-regexp.el";
      flake = false;
    };
    wubi98-data = {
      url = "github:yanhuacuo/98wubi";
      flake = false;
    };

    # fish
    fish-ssh-agent = {
      url = "github:danhper/fish-ssh-agent";
      flake = false;
    };

    nixGL = {
      url = "github:nix-community/nixGL/310f8e49a149e4c9ea52f1adf70cdc768ec53f8a";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # neovim
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    # mynixvim = { url = "git+file:./modules/nixvim/"; inputs.nixpkgs.follows = "nixpkgs"; inputs.neovim-nightly.follows = "neovim-nightly"; };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        inputs.emacs.overlays.default
        inputs.neovim-nightly.overlays.default
      ];
      pkgs = import nixpkgs { inherit system; inherit overlays; config.allowUnfree = true; };
    in
    {
      homeConfigurations."colabrewsred" = home-manager.lib.homeManagerConfiguration rec {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit inputs; };
      };
    };
}

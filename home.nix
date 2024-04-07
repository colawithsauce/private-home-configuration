{ config, pkgs, lib, ... }:

let
  myvim_config = import ./dotfiles/vim/vim.nix { inherit pkgs; };
  myemacs =
    pkgs.emacs29-pgtk.overrideAttrs (attrs: {
      postInstall = (attrs.postInstall or "") + ''
        rm $out/share/applications/emacs.desktop
      '';
    })
  ;
  rime-regexp = with pkgs;
    emacsPackages.trivialBuild {
      pname = "rime-regexp";
      version = "master";
      src = fetchFromGitHub {
        owner = "colawithsauce";
        repo = "rime-regexp.el";
        rev = "99558c033d5c8d4cc4d452959445a099fc71f898";
        hash = "sha256-6its2dwdWXmcSPsYQI1L9FtppsZhraajKIx24HX213Y=";
      };
      buildInputs = with emacsPackages; [
        rime
      ];
    };
in
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "colawithsauce";
  home.homeDirectory = "/home/colawithsauce";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    zsh
    hstr
    starship
    xonsh

    emacs-lsp-booster

    llvm
    clang
    clang-tools
    lldb
    llvmPackages.mlir
    ccls

    ffmpegthumbnailer
    unar
    jq
    poppler
    fd
    ripgrep
    fzf
    zoxide
    nurl

    universal-ctags

    nix-output-monitor
    nixpkgs-fmt
    nixd

    typst
    typstfmt
    typst-lsp
    typst-live

    # lsp configurations
    mdl
    proselint
    discount

    virtualbox
  ] ++ [
    # (vim_configurable.customize myvim_config)
    jetbrains-toolbox
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = { };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.config/emacs/bin"
    "$HOME/.cargo/bin"
    "$HOME/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "google-chrome-stable";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;

  imports = [
    ./dotfiles/nvim/nvim.nix
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-configtool
      fcitx5-rime
      fcitx5-gtk
      librime
    ];
  };

  programs.emacs = {
    enable = true;
    package = myemacs;

    extraPackages = epkgs: with epkgs; [
      vterm
      rime
      emacsql-sqlite
      pdf-tools

      rime-regexp
    ];

    overrides = self: super: {
      rime = with pkgs;
        (self.melpaPackages.rime.overrideAttrs (old: {
          recipe = pkgs.writeText "recipe" ''
            (rime :repo "DogLooksGood/emacs-rime"
                              :files (:defaults "lib.c" "Makefile" "librime-emacs.so")
                                                :fetcher github)
          '';
          postPatch = old.postPatch or "" + ''
            emacs --batch -Q -L . \
                            --eval "(progn (require 'rime) (rime-compile-module))"
          '';
          buildInputs = old.buildInputs ++ (with pkgs; [ librime ]);
        }))
      ;
    };
  };
  services.emacs = {
    enable = true;
  };

  programs.autojump = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    plugins = with pkgs; [
      {
        name = "fish-ssh-agent";
        src = fetchFromGitHub {
          owner = "danhper";
          repo = "fish-ssh-agent";
          rev = "fd70a2afdd03caf9bf609746bf6b993b9e83be57";
          hash = "sha256-e94Sd1GSUAxwLVVo5yR6msq0jZLOn2m+JZJ6mvwQdLs=";
        };
      }
    ];
    shellAliases = {
      mg = "emacsclient -t --eval '(magit)'";
      e = "emacsclient -t 2>/dev/null";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = lib.fileContents dotfiles/bashrc + ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
    profileExtra = lib.fileContents dotfiles/bash_profile;
    shellAliases = {
      mg = "emacs -nw --eval '(magit)'";
      e = "emacs -nw 2>/dev/null";
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      mgt19937.typst-preview
      nvarner.typst-lsp
    ];
  };
}


# vim:tabstop=2:shiftwidth=2

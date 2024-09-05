{ config, pkgs, inputs, lib, ... }:

let
  # wubi98-data = pkgs.rime-data.overrideAttrs { src = inputs.wubi98-data; };
  myemacs =
    pkgs.emacs-git.overrideAttrs (old: {
      buildInputs = lib.lists.remove pkgs.xorg.libXi old.buildInputs;
      configureFlags = lib.lists.remove "--with-xinput2" old.configureFlags ++ [ "--without-xim" ];
      patches =
        (old.patches or [ ]) ++
        [
          (pkgs.fetchpatch2 {
            url = "https://lists.gnu.org/archive/html/emacs-devel/2023-12/txtiV7CV4R_cz.txt";
            sha256 = "sha256-0oyQHzDY9kk5nwFBb3xnMJBL/I9ln5OAZb9uWyYtGmk=";
          })
        ];
    })
  ;
  rime-regexp =
    pkgs.emacsPackages.trivialBuild {
      pname = "rime-regexp";
      version = "master";
      src = inputs.rime-regexp;
      buildInputs = with pkgs.emacsPackages; [
        rime
      ];
    };
  nixGLIntel = inputs.nixGL.packages."${pkgs.system}".nixGLIntel;
in
{
  nixpkgs.overlays = [
  ];

  imports = [
    ./dotfiles/nixvim.nix
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/Smona/home-manager/nixgl-compat/modules/misc/nixgl.nix";
      sha256 = "01dkfr9wq3ib5hlyq9zq662mp0jl42fw3f6gd2qgdf8l8ia78j7i";
    })
  ];

  nixGL.prefix = "${nixGLIntel}/bin/nixGLIntel";

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "colabrewsred";
  home.homeDirectory = "/home/colabrewsred";

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
  home.packages = 
  let
    nixGLwrap = pkg: config.lib.nixGL.wrap pkg;
  in
  with pkgs; [
    zsh
    hstr
    starship
    xonsh
    # todoist

    emacs-lsp-booster

    # llvm
    # clang
    clang-tools
    # lldb
    # llvmPackages.mlir
    # ccls
    # ccache
    sccache
    bear

    # ffmpegthumbnailer
    unar
    jq
    poppler
    fd
    ripgrep
    fzf
    zoxide
    nurl
    grc
    bat
    fastfetch

    universal-ctags

    nix-output-monitor
    # nixpkgs-fmt
    nixd

    typst
    typstfmt
    typst-lsp
    typst-live

    # lsp configurations
    mdl
    proselint
    discount
    dockerfile-language-server-nodejs

    # vmware-workstation
  ] ++ [
    nixGLIntel
    # (nixGLwrap neovide)
    # (nixGLwrap zed-editor)
    # (nixGLwrap kitty)
    # jetbrains-toolbox
    # anki-bin
    # calibre
    # obsidian
    # logseq
  ] ++ [
    # Beautify
  ] ++ [
    # libs
    jsoncpp
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # "rime-data" = {
    #   source = "${inputs.wubi98-data}";
    #   target = ".local/share/rime";
    #   recursive = false;
    #   onChange = "rime_deployer --build ${inputs.wubi98-data}";
    # };
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.config/emacs/bin"
    "$HOME/.cargo/bin"
    "$HOME/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    # BROWSER = "google-chrome-stable";
    OPENAI_API_URL = "https://api.moonshot.cn/v1/chat/completions";
    LSP_USE_PLISTS = "true";
  };

  home.shellAliases = {
    mg = "emacsclient -nw --eval '(magit)' 2>/dev/null";
    e = "emacsclient -nw 2>/dev/null";
    ee = "emacs -nw 2>/dev/null";
    ec = "emacsclient -c 2>/dev/null";
    # vi = "nix run ~/.config/home-manager/modules/nixvim -- ";
    # vim = "nix run ~/.config/home-manager/modules/nixvim -- ";
    # nvrun = "DRI_PRIME=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;

  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-rime ];

  programs.emacs = {
    enable = true;
    package = myemacs;

    extraPackages = epkgs: with epkgs; [
      vterm
      rime
      emacsql-sqlite
      pdf-tools
      csv-mode
      # telega

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

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  # programs.nix-index = {
  #   enable = true;
  #   enableBashIntegration = true;
  #   enableFishIntegration = true;
  # };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    plugins = with pkgs; [
      # {
      #   name = "tide";
      #   src = fishPlugins.tide.src;
      # }
      {
        name = "grc";
        src = fishPlugins.grc.src;
      }
    ];
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = lib.fileContents dotfiles/bash_profile;
  };

}


# vim:tabstop=2:shiftwidth=2

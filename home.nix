{ config, pkgs, inputs, lib, ... }:

let
  myvim_config = import ./dotfiles/vim/vim.nix { inherit pkgs; };
  # wubi98-data = pkgs.rime-data.overrideAttrs { src = inputs.wubi98-data; };
  myemacs =
    pkgs.emacs-pgtk.overrideAttrs (old: {
      patches =
        (old.patches or [ ]) ++
        [
          (pkgs.fetchpatch2 {
            url = "https://lists.gnu.org/archive/html/emacs-devel/2023-12/txtiV7CV4R_cz.txt";
            sha256 = "sha256-0oyQHzDY9kk5nwFBb3xnMJBL/I9ln5OAZb9uWyYtGmk=";
          })
        ];
    })
    # (pkgs.emacs-pgtk.overrideAttrs (attrs: {
    #   postInstall = (attrs.postInstall or "") + ''
    #     rm $out/share/applications/emacsclient.desktop
    #   '';
    # })) #.override { stdenv = pkgs.ccacheStdenv; }  # NOTE: this still buggy?
  ;
  rime-regexp = with pkgs;
    emacsPackages.trivialBuild {
      pname = "rime-regexp";
      version = "master";
      src = inputs.rime-regexp;
      buildInputs = with emacsPackages; [
        rime
      ];
    };
in
{
  nixpkgs.overlays = [
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
    todoist

    emacs-lsp-booster

    llvm
    clang
    clang-tools
    lldb
    llvmPackages.mlir
    ccls
    ccache
    sccache

    ffmpegthumbnailer
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
    (vim_configurable.customize myvim_config)
    jetbrains-toolbox
  ] ++ [
    # Beautify
    kde-rounded-corners
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
    BROWSER = "google-chrome-stable";
  };

  home.shellAliases = {
    mg = "emacsclient -nw --eval '(magit)' 2>/dev/null";
    e = "emacsclient -nw -a 'emacs -nw' 2>/dev/null";
    nvrun = "DRI_PRIME=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;

  imports = [
    ./dotfiles/nvim/nvim.nix
  ];

  programs.emacs = {
    enable = true;
    package = myemacs;

    extraPackages = epkgs: with epkgs; [
      vterm
      rime
      emacsql-sqlite
      pdf-tools
      csv-mode

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
        name = "tide";
        src = fishPlugins.tide.src;
      }
      {
        name = "grc";
        src = fishPlugins.grc.src;
      }
      {
        name = "fish-ssh-agent";
        src = inputs.fish-ssh-agent;
      }
    ];
    shellAbbrs = {
      td = "todoist";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = lib.fileContents dotfiles/bashrc + ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
    profileExtra = lib.fileContents dotfiles/bash_profile;
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

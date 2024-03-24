{ config, pkgs, lib, ... }:

let 
  myvim_config = import ./dotfiles/vim/vim.nix { inherit; };
  myemacs = pkgs.emacs29.overrideAttrs (attrs: {
    postInstall = (attrs.postInstall or "") + ''
    rm $out/share/applications/emacsclient*.desktop
	'';
  });
in
{
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
    firefox

    zsh

    yazi
    ffmpegthumbnailer
    unar
    jq
    poppler
    fd ripgrep fzf zoxide

    universal-ctags

    nix-output-monitor

    typst
    typstfmt
    typst-lsp
    typst-live

    # lsp configurations
    mdl
    proselint
    discount
  ] ++ [
    (vim_configurable.customize myvim_config)
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
  };

  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "google-chrome-stable";
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = lib.fileContents dotfiles/bashrc;
    profileExtra = lib.fileContents dotfiles/bash_profile;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      mgt19937.typst-preview
      nvarner.typst-lsp
    ];
  };

  programs.emacs = {
    enable = true;
    package = myemacs;
    extraPackages = epkgs:
      with epkgs; [
        vterm
        # install all treesitter grammars
        (treesit-grammars.with-grammars (p: builtins.attrValues p))

        # emacs-rime
        (epkgs.melpaPackages.rime.overrideAttrs (old: {
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

      ];
  };
}


# vim:tabstop=2:shiftwidth=2

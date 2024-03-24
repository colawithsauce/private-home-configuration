{ pkgs ? import <nixpkgs> { }, ... }:
let
  pretty-folds = pkgs.vimUtils.buildVimPlugin {
    name = "vim-pretty-folds";
    src = pkgs.fetchFromGitHub {
      owner = "luisdavim";
      repo = "pretty-folds";
      rev = "d17fbd125c282bc811ab161d95607f895b5ec51a";
      hash = "sha256-Bc3i3MeD8LpfxnlW6GhOzH7ZtULGcUFROHVg7Zp8Uco=";
    };
  };
  vim-cppman = pkgs.vimUtils.buildVimPlugin {
    name = "vim-cppman";
    src = pkgs.fetchFromGitHub {
      owner = "gauteh";
      repo = "vim-cppman";
      rev = "de1318252b68fba9b8249254475b6e050d160b73";
      hash = "sha256-e1fDnHARqiWcLcLH+SIPP1xTaO/PZE99bR9IFiwdtlg=";
    };
  };
  vim-info = pkgs.vimUtils.buildVimPlugin {
    name = "vim-info";
    src = pkgs.fetchFromGitHub {
      owner = "HiPhish";
      repo = "info.vim";
      rev = "b1acda75344f36b91d9c51a33201eada38cf33e9";
      hash = "sha256-135+bK9w63Cl4nHQ+DgO2wUHqqUdWDif3Ahiu2YUvfk=";
    };
  };
in
  {
    name = "vim";
    vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
      start = [ 
        airline
        auto-pairs
        tcomment_vim
        fzf-vim
        catppuccin-vim
        vim-gutentags
        codeium-vim
        gitgutter
        surround
        vim-wayland-clipboard

        vim-cppman
        vim-info

        nerdtree

        haskell-vim
        vim-markdown
        csv
        vim-nix 
        vim-lastplace 
      ] ++ [ pretty-folds ];
    };
    vimrcConfig.customRC = pkgs.lib.fileContents ./init-core.vim;
  }

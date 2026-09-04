# My dotfiles

> [!NOTE]
> `./setup install` only works on Arch and Gentoo at the moment.

## Setup

To setup everything just run:
```bash
./setup everything
```

This will install all programs and link the configs to `~/.config`.

If you wish to just install or link, you can run:
```bash
./setup install all
# or
./setup link all
```

If you just want to install or link certain programs and their configs, run:
```bash
./setup install # zsh nvim hypr tmux ghostty fonts extras
# or
./setup link # zsh nvim hypr tmux ghostty fonts extras
```

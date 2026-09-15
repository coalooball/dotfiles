# dotfiles

Personal dotfiles. Configuration files live in this repository, and `install.sh`
symlinks them into place under `$HOME`.

## Layout

```
.
├── install.sh                        # clone/update Emacs, then create symlinks
├── .emacs.d/
│   ├── post-init.el                  # user config loaded after minimal-emacs.d
│   ├── post-early-init.el            # user config loaded after early-init
│   ├── cyan/                         # personal Emacs packages
│   └── resolve.org                   # troubleshooting notes
└── ...
```

## Install

Run the installer (safe to run repeatedly):

```sh
./install.sh
```

It performs two steps:

1. Sync `~/.emacs.d` with the upstream `jamescherti/minimal-emacs.d`:
   - if `~/.emacs.d` is not a repository, clone it (shallow);
   - if it already is, fetch and hard-reset it to upstream (shallow).
2. Create symlinks from this repository into `$HOME`:
   - `~/.emacs.d/post-init.el`
   - `~/.emacs.d/post-early-init.el`
   - `~/.emacs.d/cyan`

`~/.emacs.d` itself is upstream's repository and is never committed here. Only the
files listed above are tracked and symlinked.

## Emacs upstream mirror

Because GitHub is slow to reach directly, the installer fetches `minimal-emacs.d`
through a China-friendly mirror by default:

```
https://ghproxy.net/https://github.com/jamescherti/minimal-emacs.d.git
```

Override it with the `EMACS_MIRROR` environment variable:

```sh
EMACS_MIRROR=https://github.com/jamescherti/minimal-emacs.d.git ./install.sh
```

When `install.sh` runs, it sets `origin` of `~/.emacs.d` to the mirror URL, keeps
the clone shallow (`--depth=1`), and hard-resets the local branch to the fetched
upstream tip. Since `~/.emacs.d` holds no local commits, this always matches
upstream without merge conflicts.

## Adding a new dotfile

1. Put the file in this repository (for example `.zshrc`).
2. Add a line to `install.sh`:

   ```sh
   link .zshrc .zshrc
   ```

3. Re-run `./install.sh`.

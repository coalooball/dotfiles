# Personal Emacs Modules

`post-init.el` keeps the baseline settings and package configuration: appearance,
history, built-in editing modes, project discovery, shell environment, completion,
Flymake, Eglot and Magit. Additional features belong in this directory.

| File | Responsibility |
| --- | --- |
| `cyan-editing.el` | Copy file location, select string contents, move lines and multiple cursors |
| `cyan-macos.el` | macOS frame handling and window shortcuts |
| `cyan-workspaces.el` | Tabspaces, session settings and the Consult workspace buffer source |
| `cyan-terminal.el` | Ghostel settings and project-aware terminal commands |
| `cyan-codex.el` | Codex terminal commands, buffer switching and CJK redisplay settings |
| `cyan-hurl.el` | Automatic mode selection for `.hurl` files |
| `cyan-treesit.el` | Automatic selection of installed Tree-sitter modes; manual grammar installation |
| `hurl-ts-mode.el` | Tree-sitter Hurl highlighting; requires a manually installed grammar |

`post-init.el` adds this directory to `load-path` relative to its own location
and loads modules explicitly with `require`. The terminal module depends on the
workspace module; the Codex module depends on the terminal module. Hurl's major
mode is loaded on demand when a `.hurl` file opens.

Tree-sitter grammars are never downloaded automatically. To install one, run
`M-x treesit-install-language-grammar`, select a language (for example, `bash`
or `hurl`), and accept the default installation directory. Reload
`cyan-treesit.el` or restart Emacs afterward to refresh file associations.
Without a grammar, existing ordinary modes remain available; Hurl reports
the manual installation command if its required grammar is missing.

Keep existing command names and key bindings when moving configuration. For a
new feature, add a `cyan-NAME.el` file with lexical binding, declare dependencies
with `require`, end with `(provide 'cyan-NAME)`, and require it from `post-init.el`.
To apply changes to an already loaded module, evaluate its buffer or restart
Emacs; evaluating a `require` again does not reload the module.

Session files, history and other generated state remain in their existing
locations outside this directory.

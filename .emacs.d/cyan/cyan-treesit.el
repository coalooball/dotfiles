;;; cyan-treesit.el --- Native Tree-sitter modes -*- lexical-binding: t; -*-

(require 'use-package)
(require 'treesit)

(setq treesit-font-lock-level 4)

(use-package treesit-auto
  :if (treesit-available-p)
  :demand t
  :custom
  (treesit-auto-install nil)
  :config
  ;; Make recipes available to M-x treesit-install-language-grammar.
  (setq treesit-language-source-alist
        (treesit-auto--build-treesit-source-alist))
  ;; Use Tree-sitter modes only when their grammars are already installed.
  (treesit-auto-add-to-auto-mode-alist)
  (global-treesit-auto-mode 1))

(provide 'cyan-treesit)
;;; cyan-treesit.el ends here

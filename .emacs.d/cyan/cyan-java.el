;;; cyan-java.el --- Java support via eglot + jdtls -*- lexical-binding: t; -*-

;; jdtls comes from the official Eclipse tarball unpacked at
;; ~/tools/jdtls (see `cyan-java-jdtls-home').  No Homebrew needed.

(require 'eglot)
(require 'project)
(require 'treesit)

(defgroup cyan-java nil
  "Java editing with eglot and jdtls."
  :group 'tools
  :prefix "cyan-java-")

(defcustom cyan-java-jdtls-home
  (expand-file-name "~/tools/jdtls")
  "Directory holding the unpacked jdtls distribution."
  :type 'directory
  :group 'cyan-java)

(defcustom cyan-java-jdtls-executable
  (expand-file-name "bin/jdtls" cyan-java-jdtls-home)
  "Official jdtls launcher wrapper from the tarball.
It picks the platform config, validates Java and derives a
per-directory -data workspace unless one is given explicitly."
  :type 'file
  :group 'cyan-java)

(defun cyan-java-workspace-dir ()
  "Per-project jdtls workspace under `user-emacs-directory'/var/jdtls.
Falls back to a \"global\" workspace outside any project, so two
projects never share a jdtls data directory."
  (let ((proj (project-current)))
    (expand-file-name
     (format "var/jdtls/%s"
             (if proj
                 (file-name-nondirectory
                  (directory-file-name (project-root proj)))
               "global"))
     user-emacs-directory)))

(defun cyan-java-server-contact (_interactive)
  "Eglot contact for jdtls with an explicit per-project -data dir."
  (list cyan-java-jdtls-executable
        "-data" (cyan-java-workspace-dir)))

(add-to-list 'eglot-server-programs
             '((java-mode java-ts-mode) . cyan-java-server-contact))

(add-hook 'java-mode-hook #'eglot-ensure)
(add-hook 'java-ts-mode-hook #'eglot-ensure)

;; Prefer the Tree-sitter mode once its grammar is installed
;; (M-x treesit-install-language-grammar, or a libtree-sitter-java
;; already present in `treesit-extra-load-path').
(when (treesit-ready-p 'java t)
  (add-to-list 'major-mode-remap-alist '(java-mode . java-ts-mode)))

(provide 'cyan-java)
;;; cyan-java.el ends here

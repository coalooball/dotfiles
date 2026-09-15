;;; cyan-opencode.el --- Opencode terminal commands -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;;; Personal configuration loaded from post-init.el.

;;; Code:

(require 'use-package)
(require 'cyan-terminal)

(defun opencode (&optional directory)
  "Run the Opencode TUI in a Ghostel terminal.

Use DIRECTORY when supplied; otherwise use the current tabspace project
root, or prompt for a directory when the tabspace has no project."
  (interactive)
  (require 'ghostel)
  (let* ((project-root (my/tabspaces-project-root))
         (directory (file-name-as-directory
                     (expand-file-name
                      (or directory
                          project-root
                          (my/read-terminal-directory
                           "Opencode directory: ")))))
         (program (or (executable-find "opencode")
                      "/usr/local/bin/opencode"))
         (buffer (generate-new-buffer
                  (format "%s[opencode]"
                          (file-name-nondirectory
                           (directory-file-name directory))))))
    (unless (file-executable-p program)
      (user-error "Cannot find the opencode executable"))
    (with-current-buffer buffer
      (setq default-directory directory)
      (ghostel-mode)
      (setq-local ghostel-buffer-name-function nil))
    (my/ghostel-display-buffer buffer)
    (ghostel-exec buffer program nil)
    buffer))

(provide 'cyan-opencode)
;;; cyan-opencode.el ends here
